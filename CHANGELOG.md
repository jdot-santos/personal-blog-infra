# Changelog

All notable changes to this project will be documented in this file. 

## [0.1.0] - 2025-03-11
### Added
- Initial Infra Project

## [0.8.0] - 2025-03-11
### Added
- Dev, Staging, and Production Fastly services

## [0.8.1] - 2025-03-26
### Added
- Add more redirects to CDN


## [1.0.0] - 2025-04-07
### Added
- Add logging

## [1.1.0] - 2026-10-23
### Added
- Offline test suite: falco VCL tests, `terraform test` with mocked Fastly provider, CI steps, FEATURE smoke script
### Fixed
- add-www redirect always uses `https://` (was `req.protocol`, missing `+`)
