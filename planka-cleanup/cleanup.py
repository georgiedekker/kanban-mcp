#!/usr/bin/env python3
"""Simple script to cleanup Planka projects and boards."""

import httpx
import os
import sys

# Configuration
BASE_URL = "http://localhost:3333/api"
EMAIL = "agent@gmail.com"
# ⚠️ SECURITY: Hardcoded password was removed
# Set environment variable: export PLANKA_PASSWORD=<your_password>
PASSWORD = os.getenv("PLANKA_PASSWORD")
PROTECTED_PROJECT_ID = "1573201067548608248"

if not PASSWORD:
    print("❌ ERROR: PLANKA_PASSWORD environment variable not set")
    print("Usage: export PLANKA_PASSWORD=<your_password> && python cleanup.py")
    sys.exit(1)


def main():
    """Main cleanup function."""

    # Step 1: Login
    print("Logging in...")
    response = httpx.post(
        f"{BASE_URL}/access-tokens",
        json={"emailOrUsername": EMAIL, "password": PASSWORD},
    )
    response.raise_for_status()
    token = response.json()["item"]
    print("✓ Logged in successfully")

    headers = {"Authorization": f"Bearer {token}", "accept": "application/json"}

    # Step 2: Get all projects
    print("\nFetching all projects...")
    response = httpx.get(f"{BASE_URL}/projects", headers=headers)
    response.raise_for_status()
    projects = response.json()["items"]
    print(f"✓ Found {len(projects)} projects")

    # Step 3: Process each project (except protected one)
    for project in projects:
        project_id = project["id"]
        project_name = project["name"]

        if project_id == PROTECTED_PROJECT_ID:
            print(f"\n⊘ Skipping protected project: {project_name} (ID: {project_id})")
            continue

        print(f"\n→ Processing project: {project_name} (ID: {project_id})")

        # Get project details to find boards
        response = httpx.get(f"{BASE_URL}/projects/{project_id}", headers=headers)
        response.raise_for_status()
        project_details = response.json()
        boards = project_details.get("included", {}).get("boards", [])

        # Delete each board
        if boards:
            print(f"  Found {len(boards)} board(s) to delete")
            for board in boards:
                board_id = board["id"]
                board_name = board["name"]
                print(f"    Deleting board: {board_name} (ID: {board_id})")
                response = httpx.delete(
                    f"{BASE_URL}/boards/{board_id}", headers=headers
                )
                response.raise_for_status()
                print("    ✓ Board deleted")
        else:
            print("  No boards found")

        # Delete the project
        print(f"  Deleting project: {project_name}")
        response = httpx.delete(f"{BASE_URL}/projects/{project_id}", headers=headers)
        response.raise_for_status()
        print("  ✓ Project deleted")

    print("\n✓ Cleanup completed!")


if __name__ == "__main__":
    main()
