#!/bin/bash

# RAG System Stop Script
# This script stops all RAG system services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[RAG-SYSTEM]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check Docker Compose (supports both v1 and v2)
check_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    else
        return 1
    fi
    return 0
}

# Initialize Docker Compose command
check_docker_compose

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_status "Stopping RAG system services..."

# Stop services
if $COMPOSE_CMD ps | grep -q "Up"; then
    print_status "Stopping containers..."
    $COMPOSE_CMD stop
    
    print_status "Removing containers..."
    $COMPOSE_CMD down
    
    print_success "RAG system services stopped successfully"
else
    print_warning "No running services found"
fi

# Display final status
print_status "Final status:"
$COMPOSE_CMD ps

print_success "RAG system shutdown complete"
print_status "Data volumes are preserved. To completely remove all data, run:"
print_status "  $COMPOSE_CMD down -v --remove-orphans"