# Changelog

All notable changes to this project will be documented in this file.

## [1.2.3](https://github.com/open-horizon/vault-plugin-auth-openhorizon/pull/91) - 2025-03-25
- Set CGO_ENABLED to 0 for build.

## [1.2.2](https://github.com/open-horizon/vault-plugin-auth-openhorizon/pull/87) - 2025-03-06
- Fixed Vulnerability CVE-2025-27144.
- Fixed Vulnerability CVE-2025-22869.
- go-jose/go-jose/v4 v4.0.1 -> v4.0.5.
- x/crypto v0.31.0 -> v0.35.0.

## [1.2.1](https://github.com/open-horizon/vault-plugin-auth-openhorizon/pull/90) - 2025-03-04
- Fixed type in module reference.

## [1.2.0](https://github.com/open-horizon/vault-plugin-auth-openhorizon/compare/v1.1.5...open-horizon:vault-plugin-auth-openhorizon:v1.2.0?expand=1) - 2025-03-04
- Issue 84: Separated Out auth plugin for Vault into its own deliverables.
  - Naming convention changes to conform to other plugins in the community.
- github.com/hashicorp/vault/api v1.15.0 -> v1.16.0
- github.com/hashicorp/vault/sdk v1.13.0 -> v1.15.2
- golang 1.21 -> 1.23.6
- Added Maintainers markdown file.
- Added Changelog markdown file.
