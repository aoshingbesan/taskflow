#!/bin/bash

# TaskFlow Rubric Testing Script
# This script tests all rubric criteria step by step

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Test counters
PASSED=0
FAILED=0
TOTAL=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL=$((TOTAL + 1))
    log "Running test: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log "✅ PASSED: $test_name"
        PASSED=$((PASSED + 1))
    else
        error "❌ FAILED: $test_name"
        FAILED=$((FAILED + 1))
    fi
}

# 1. Pipeline Automation Testing (30 points)
echo "=========================================="
echo "1. TESTING PIPELINE AUTOMATION (30 points)"
echo "=========================================="

run_test "CD Pipeline exists" "test -f .github/workflows/cd.yml" "CD pipeline file should exist"
run_test "CD Pipeline has security scanning" "grep -q 'security-scan' .github/workflows/cd.yml" "Security scanning job should exist"
run_test "CD Pipeline has deployment stages" "grep -q 'deploy-staging\|deploy-production' .github/workflows/cd.yml" "Deployment stages should exist"
run_test "CD Pipeline triggers on main" "grep -q 'branches: \[ main \]' .github/workflows/cd.yml" "Should trigger on main branch"

# 2. DevSecOps Integration Testing (10 points)
echo "=========================================="
echo "2. TESTING DEVSECOPS INTEGRATION (10 points)"
echo "=========================================="

run_test "Safety tool in requirements" "grep -q 'safety==' requirements.txt" "Safety should be in requirements"
run_test "Bandit tool in requirements" "grep -q 'bandit==' requirements.txt" "Bandit should be in requirements"
run_test "Bleach tool in requirements" "grep -q 'bleach==' requirements.txt" "Bleach should be in requirements"
run_test "Security module exists" "test -f app/security.py" "Security module should exist"

# 3. Monitoring & Observability Testing (10 points)
echo "=========================================="
echo "3. TESTING MONITORING & OBSERVABILITY (10 points)"
echo "=========================================="

run_test "Monitoring module exists" "test -f app/monitoring.py" "Monitoring module should exist"
run_test "Dashboard module exists" "test -f app/dashboard_monitoring.py" "Dashboard module should exist"
run_test "Health check endpoint accessible" "curl -f -s https://taskflow-app.azurewebsites.net/health > /dev/null" "Health check should be accessible"
run_test "API health check accessible" "curl -f -s https://taskflow-app.azurewebsites.net/api/v1/health > /dev/null" "API health check should be accessible"

# 4. Code Quality & Documentation Testing (10 points)
echo "=========================================="
echo "4. TESTING CODE QUALITY & DOCUMENTATION (10 points)"
echo "=========================================="

run_test "CHANGELOG.md exists" "test -f CHANGELOG.md" "CHANGELOG.md should exist"
run_test "README.md exists" "test -f README.md" "README.md should exist"
run_test "README has production URL" "grep -q 'taskflow-app.azurewebsites.net' README.md" "README should have production URL"
run_test "README has staging URL" "grep -q 'taskflow-staging.azurewebsites.net' README.md" "README should have staging URL"
run_test "Code passes flake8" "flake8 app/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics > /dev/null 2>&1" "Code should pass flake8"
run_test "Code passes black check" "black --check --diff app/ tests/ > /dev/null 2>&1" "Code should pass black formatting"

# Test live environments
echo "=========================================="
echo "5. TESTING LIVE ENVIRONMENTS"
echo "=========================================="

run_test "Production environment accessible" "curl -f -s https://taskflow-app.azurewebsites.net/health > /dev/null" "Production should be accessible"
run_test "Staging environment accessible" "curl -f -s https://taskflow-staging.azurewebsites.net/health > /dev/null" "Staging should be accessible"
run_test "API documentation accessible" "curl -f -s https://taskflow-app.azurewebsites.net/docs > /dev/null" "API docs should be accessible"

# Security testing
echo "=========================================="
echo "6. TESTING SECURITY FEATURES"
echo "=========================================="

run_test "Security headers present" "curl -s -I https://taskflow-app.azurewebsites.net | grep -q 'X-Content-Type-Options'" "Security headers should be present"
run_test "HTTPS enabled" "curl -s -I https://taskflow-app.azurewebsites.net | grep -q 'HTTP/2\|HTTP/1.1 200'" "HTTPS should be enabled"

# Performance testing
echo "=========================================="
echo "7. TESTING PERFORMANCE"
echo "=========================================="

response_time=$(curl -w "%{time_total}" -o /dev/null -s https://taskflow-app.azurewebsites.net/health)
if (( $(echo "$response_time < 2.0" | bc -l) )); then
    log "✅ PASSED: Response time is good ($response_time seconds)"
    PASSED=$((PASSED + 1))
else
    warning "⚠️  SLOW: Response time is $response_time seconds"
    FAILED=$((FAILED + 1))
fi

# Summary
echo "=========================================="
echo "TESTING SUMMARY"
echo "=========================================="
echo "Total tests: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Success rate: $((PASSED * 100 / TOTAL))%"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Your implementation meets all rubric criteria.${NC}"
    echo ""
    echo "Rubric Score Breakdown:"
    echo "✅ Pipeline Automation (30/30 points)"
    echo "✅ DevSecOps Integration (10/10 points)"
    echo "✅ Monitoring & Observability (10/10 points)"
    echo "✅ Code Quality & Documentation (10/10 points)"
    echo ""
    echo "Total Score: 60/60 points (100%)"
else
    echo -e "${RED}❌ Some tests failed. Please review the failed tests above.${NC}"
fi

echo ""
echo "Live URLs for manual verification:"
echo "Production: https://taskflow-app.azurewebsites.net"
echo "Staging: https://taskflow-staging.azurewebsites.net"
echo "Documentation: https://taskflow-app.azurewebsites.net/docs"
echo "Health Check: https://taskflow-app.azurewebsites.net/health" 