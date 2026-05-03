# G-Blog X: Test Suite Documentation

## 1. Overview
This document defines the testing strategy for the blog platform, including unit, integration, end-to-end, performance, and security tests.

## 2. Test Plan
- Unit tests: cover business logic and utilities.
- Integration tests: API endpoints against a test database.
- End-to-end tests: API-driven end-to-end tests (Phase 3) and UI tests (Phase 4).
- Security tests: secret management, dependency checks, and vulnerability scanning.
- Performance tests: baseline load testing on critical read/write endpoints.
- Accessibility tests (where UI exists).

## 3. Phase 3: End-to-End (Phase 3)
- Phase 3 will introduce Java-based E2E tests using SpringBootTest + TestRestTemplate (for full path login -> CRUD) and/or Playwright/Cypress if UI-enabled.
