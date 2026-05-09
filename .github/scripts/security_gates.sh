#!/usr/bin/env bash
set -euo pipefail

echo "Running security gates..."

CRITICAL_VULNS=0
HIGH_VULNS=0

# Check for OWASP Dependency-Check report
if [ -f "backend-spring-boot/target/dependency-check-report.html" ]; then
    echo "Checking OWASP Dependency-Check report..."
    
    # Try to extract severity from HTML report
    if command -v grep &> /dev/null; then
        CRITICAL_VULNS=$(grep -oP 'Critical' backend-spring-boot/target/dependency-check-report.html 2>/dev/null | wc -l || echo 0)
        HIGH_VULNS=$(grep -oP 'High' backend-spring-boot/target/dependency-check-report.html 2>/dev/null | wc -l || echo 0)
    fi
    
    echo "Found $CRITICAL_VULNS critical and $HIGH_VULNS high severity vulnerabilities"
fi

# Also check for JSON report if available (more reliable)
if [ -f "backend-spring-boot/target/dependency-check-report.json" ]; then
    echo "Checking OWASP Dependency-Check JSON report..."
    
    if command -v jq &> /dev/null; then
        CRITICAL_VULNS=$(jq '[.dependencies[]?.vulnerabilities[]? | select(.severity == "CRITICAL")] | length' backend-spring-boot/target/dependency-check-report.json 2>/dev/null || echo 0)
        HIGH_VULNS=$(jq '[.dependencies[]?.vulnerabilities[]? | select(.severity == "HIGH")] | length' backend-spring-boot/target/dependency-check-report.json 2>/dev/null || echo 0)
        echo "JSON report: $CRITICAL_VULNS critical, $HIGH_VULNS high"
    fi
fi

# Security gate thresholds
MAX_CRITICAL_VULNS=0
MAX_HIGH_VULNS=5

if [ "$CRITICAL_VULNS" -gt "$MAX_CRITICAL_VULNS" ]; then
    echo "Security gate FAILED: $CRITICAL_VULNS critical vulnerabilities found (max allowed: $MAX_CRITICAL_VULNS)"
    exit 1
fi

if [ "$HIGH_VULNS" -gt "$MAX_HIGH_VULNS" ]; then
    echo "Security gate WARNING: $HIGH_VULNS high vulnerabilities found (max allowed: $MAX_HIGH_VULNS)"
    echo "Consider addressing these before production deployment."
fi

echo "Security gates PASSED."
exit 0
