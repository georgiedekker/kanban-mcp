import { jwtVerify, createRemoteJWKSet, JWTPayload } from "jose";
import {
  introspectLicense,
  getTenantIdFromLicense,
  LicenseIntrospectResponse,
} from "./license.js";

const PUBLIC_PATHS = [
  "/",
  "/health",
  "/health/live",
  "/health/ready",
  "/docs",
  "/openapi.json",
  "/swagger.json",
];

const PROTECTED_PREFIXES = ["/api", "/sse", "/messages"];

export type AuthMode = "jwt" | "license" | "both";

export interface AuthSettings {
  authEnabled: boolean;
  authMode: AuthMode;
  issuer?: string;
  audience?: string;
  jwksUrl?: string;
}

const DEFAULT_TENANT_ID = process.env.DEFAULT_TENANT_ID || "n8n-dev";

const TRUSTED_CIDRS_RAW =
  process.env.TRUSTED_CIDRS ||
  "127.0.0.1/32,::1/128,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8";

interface CidrEntry {
  addr: bigint;
  mask: bigint;
  isV6: boolean;
}

function parseIPv4(ip: string): bigint | null {
  const parts = ip.split(".");
  if (parts.length !== 4) return null;
  let result = 0n;
  for (const p of parts) {
    const n = parseInt(p, 10);
    if (isNaN(n) || n < 0 || n > 255) return null;
    result = (result << 8n) | BigInt(n);
  }
  return result;
}

function parseIPv6(ip: string): bigint | null {
  // Expand :: shorthand
  let parts: string[];
  if (ip.includes("::")) {
    const [left, right] = ip.split("::");
    const leftParts = left ? left.split(":") : [];
    const rightParts = right ? right.split(":") : [];
    const missing = 8 - leftParts.length - rightParts.length;
    parts = [...leftParts, ...Array(missing).fill("0"), ...rightParts];
  } else {
    parts = ip.split(":");
  }
  if (parts.length !== 8) return null;
  let result = 0n;
  for (const p of parts) {
    const n = parseInt(p, 16);
    if (isNaN(n) || n < 0 || n > 0xffff) return null;
    result = (result << 16n) | BigInt(n);
  }
  return result;
}

function parseCidr(cidr: string): CidrEntry | null {
  const [addrStr, prefixStr] = cidr.trim().split("/");
  if (!addrStr || !prefixStr) return null;
  const prefix = parseInt(prefixStr, 10);

  // Try IPv4
  const v4 = parseIPv4(addrStr);
  if (v4 !== null) {
    if (isNaN(prefix) || prefix < 0 || prefix > 32) return null;
    const mask = prefix === 0 ? 0n : ((1n << 32n) - 1n) << BigInt(32 - prefix);
    return { addr: v4 & mask, mask, isV6: false };
  }

  // Try IPv6
  const v6 = parseIPv6(addrStr);
  if (v6 !== null) {
    if (isNaN(prefix) || prefix < 0 || prefix > 128) return null;
    const mask = prefix === 0 ? 0n : ((1n << 128n) - 1n) << BigInt(128 - prefix);
    return { addr: v6 & mask, mask, isV6: true };
  }

  return null;
}

const TRUSTED_NETWORKS: CidrEntry[] = TRUSTED_CIDRS_RAW.split(",")
  .map((c) => parseCidr(c))
  .filter((c): c is CidrEntry => c !== null);

function isTrustedNetwork(host: string | undefined): boolean {
  if (!host) return false;

  // Strip IPv6-mapped IPv4 prefix (::ffff:x.x.x.x)
  let cleanHost = host;
  if (cleanHost.startsWith("::ffff:")) {
    cleanHost = cleanHost.slice(7);
  }

  // Try IPv4 first
  const v4 = parseIPv4(cleanHost);
  if (v4 !== null) {
    return TRUSTED_NETWORKS.some((n) => !n.isV6 && (v4 & n.mask) === n.addr);
  }

  // Try IPv6
  const v6 = parseIPv6(cleanHost);
  if (v6 !== null) {
    return TRUSTED_NETWORKS.some((n) => n.isV6 && (v6 & n.mask) === n.addr);
  }

  return false;
}

function isPublic(path: string): boolean {
  const clean = path.replace(/\/$/, "") || "/";
  if (PUBLIC_PATHS.includes(clean)) return true;
  return ["/docs", "/openapi.json", "/swagger.json"].some((p) => clean.startsWith(p));
}

function isProtected(path: string): boolean {
  const clean = path.replace(/\/$/, "") || "/";
  return PROTECTED_PREFIXES.some((p) => clean === p || clean.startsWith(p));
}

export async function requireJwt(
  req: import("express").Request,
  res: import("express").Response,
  next: import("express").NextFunction,
  settings: AuthSettings
) {
  const path = req.path;

  if (isPublic(path) || !isProtected(path)) {
    return next();
  }

  if (!settings.authEnabled) {
    return next();
  }

  // Extract Bearer token from Authorization or X-Tenant-Id header
  let token: string | undefined;
  const auth = req.headers["authorization"];
  if (auth && !Array.isArray(auth)) {
    const [scheme, t] = auth.split(" ");
    if (scheme?.toLowerCase() === "bearer" && t) {
      token = t;
    }
  }
  if (!token) {
    const xTenantId = req.headers["x-tenant-id"];
    if (xTenantId && !Array.isArray(xTenantId) && xTenantId.toLowerCase().startsWith("bearer ")) {
      token = xTenantId.slice(7).trim();
    }
  }

  // If a token is provided, always validate it (even from trusted networks)
  if (token) {
    // Try license introspection first (if enabled)
    if (settings.authMode === "license" || settings.authMode === "both") {
      const licenseResult = await tryLicenseAuth(req, token);
      if (licenseResult.success) {
        return next();
      }
      if (settings.authMode === "license") {
        return res.status(401).json({ error: licenseResult.error || "Invalid license token" });
      }
    }

    // Try JWT validation (if enabled)
    if (settings.authMode === "jwt" || settings.authMode === "both") {
      const jwtResult = await tryJwtAuth(req, token, settings);
      if (jwtResult.success) {
        return next();
      }
      return res.status(401).json({ error: jwtResult.error || "Authentication failed" });
    }

    return res.status(401).json({ error: "No valid authentication provided" });
  }

  // No token — check if request is from a trusted network
  const clientIp = req.socket?.remoteAddress;
  if (isTrustedNetwork(clientIp)) {
    // Allow plain X-Tenant-Id header (non-Bearer) to specify tenant
    const xTenantId = req.headers["x-tenant-id"];
    const tenantId =
      xTenantId && !Array.isArray(xTenantId) && !xTenantId.toLowerCase().startsWith("bearer ")
        ? xTenantId.trim()
        : DEFAULT_TENANT_ID;

    (req as any).tenant_id = tenantId;
    (req as any).user = { sub: tenantId, trusted_network: true };
    (req as any).license = null;
    return next();
  }

  // Not trusted, no token — reject
  return res.status(401).json({ error: "Authorization header is required" });
}

async function tryLicenseAuth(
  req: import("express").Request,
  token: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const license = await introspectLicense(token);
    if (license && license.active) {
      const tenantId = getTenantIdFromLicense(license);
      (req as any).license = license;
      (req as any).tenant_id = tenantId;
      (req as any).user = {
        sub: tenantId,
        license_id: license.license_id,
        app: license.app,
        plan: license.plan,
      };
      return { success: true };
    }
    return {
      success: false,
      error: license?.reason || "License token invalid or inactive",
    };
  } catch (err: any) {
    return { success: false, error: err?.message || "License validation failed" };
  }
}

async function tryJwtAuth(
  req: import("express").Request,
  token: string,
  settings: AuthSettings
): Promise<{ success: boolean; error?: string }> {
  try {
    const jwksUrl = settings.jwksUrl;
    if (!jwksUrl) {
      return { success: false, error: "JWKS URL not configured" };
    }

    const JWKS = createRemoteJWKSet(new URL(jwksUrl));
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: settings.issuer,
      audience: settings.audience,
    });

    (req as any).user = payload as JWTPayload;
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err?.message || "JWT validation failed" };
  }
}

export function getAuthSettings(): AuthSettings {
  // AUTH_MODE: "jwt" (default), "license", or "both"
  const authMode = (process.env.AUTH_MODE || "license") as AuthMode;

  return {
    authEnabled: process.env.AUTH_ENABLED !== "false",
    authMode,
    issuer: process.env.JWT_ISSUER,
    audience: process.env.JWT_AUDIENCE,
    jwksUrl:
      process.env.JWT_JWKS_URL ||
      (process.env.KEYCLOAK_URL && process.env.KEYCLOAK_REALM
        ? `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}/protocol/openid-connect/certs`
        : undefined),
  };
}
