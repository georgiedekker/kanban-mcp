/**
 * License token introspection for kanban service.
 *
 * Validates license tokens by calling the central license service.
 * Results are cached for 5 minutes to reduce API calls.
 */

import { createHash } from "crypto";

const LICENSE_INTROSPECT_URL =
  process.env.LICENSE_INTROSPECT_URL ||
  "http://licenses.licenses.svc.cluster.local:8544/license/introspect";

export interface LicenseIntrospectResponse {
  active: boolean;
  tenant_id?: string;
  license_id?: string;
  subject_id?: string;
  app?: Record<string, unknown>;
  plan?: Record<string, unknown>;
  status?: string;
  starts_at?: string;
  expires_at?: string;
  region_id?: string;
  metadata?: Record<string, unknown>;
  reason?: string;
}

interface CacheEntry {
  data: LicenseIntrospectResponse;
  expires: number;
}

// Simple in-memory cache with 5 minute TTL
const licenseCache = new Map<string, CacheEntry>();
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

/**
 * Introspect a license token to validate it and get tenant context.
 *
 * @param token - The license token from Authorization header
 * @returns License data if valid, null if invalid or introspection failed
 */
export async function introspectLicense(
  token: string
): Promise<LicenseIntrospectResponse | null> {
  // Generate cache key from token hash (never store raw token)
  const cacheKey = createHash("sha256").update(token).digest("hex").slice(0, 16);

  // Check cache
  const cached = licenseCache.get(cacheKey);
  if (cached && cached.expires > Date.now()) {
    return cached.data;
  }

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 2000); // 2s timeout

    const resp = await fetch(LICENSE_INTROSPECT_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ token }),
      signal: controller.signal,
    });

    clearTimeout(timeout);

    if (resp.ok) {
      const data = (await resp.json()) as LicenseIntrospectResponse;
      // Only cache active licenses
      if (data.active) {
        licenseCache.set(cacheKey, {
          data,
          expires: Date.now() + CACHE_TTL_MS,
        });
      }
      return data;
    }

    // Token invalid or not found
    return null;
  } catch (err) {
    console.warn(`License introspection failed: ${err}`);
    return null;
  }
}

/**
 * Extract tenant ID from license introspection response.
 * Falls back to subject_id if tenant_id is not present.
 */
export function getTenantIdFromLicense(
  license: LicenseIntrospectResponse
): string | undefined {
  return license.tenant_id || license.subject_id;
}

/**
 * Clear the license cache (useful for testing)
 */
export function clearLicenseCache(): void {
  licenseCache.clear();
}
