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

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_status "Stopping RAG system services..."

# Stop services
if docker-compose ps | grep -q "Up"; then
    print_status "Stopping containers..."
    docker-compose stop
    
    print_status "Removing containers..."
    docker-compose down
    
    print_success "RAG system services stopped successfully"
else
    print_warning "No running services found"
fi

# Display final status
print_status "Final status:"
docker-compose ps

print_success "RAG system shutdown complete"
print_status "Data volumes are preserved. To completely remove all data, run:"
print_status "  docker-compose down -v --remove-orphans"