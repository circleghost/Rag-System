#!/bin/bash

# RAG System Startup Script
# This script starts the complete RAG system with Nginx, Neo4j, and Graphiti

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists docker; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command_exists docker-compose; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_success "Prerequisites checked successfully"

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_status "Working directory: $PROJECT_DIR"

# Check if .env file exists
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_warning "Please edit .env file with your actual API keys and configurations"
        print_warning "At minimum, you need to set OPENAI_API_KEY or ANTHROPIC_API_KEY"
    else
        print_error ".env.example file not found. Cannot create .env file."
        exit 1
    fi
fi

# Check if required environment variables are set
print_status "Checking environment variables..."
source .env

if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    print_error "Neither OPENAI_API_KEY nor ANTHROPIC_API_KEY is set in .env file"
    print_error "Please set at least one API key to use the RAG system"
    exit 1
fi

if [ -z "$NEO4J_PASSWORD" ] || [ "$NEO4J_PASSWORD" = "changeme123" ]; then
    print_warning "Using default Neo4j password. Consider changing it for security."
fi

print_success "Environment variables checked"

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p logs/nginx logs/graphiti neo4j/plugins neo4j/import

# Set proper permissions for log directories
chmod 755 logs/nginx logs/graphiti

print_success "Directories created"

# Pull latest images
print_status "Pulling latest Docker images..."
docker-compose pull

# Start services
print_status "Starting RAG system services..."
docker-compose up -d

# Wait for services to be healthy
print_status "Waiting for services to be healthy..."

# Function to wait for service health
wait_for_service() {
    local service_name=$1
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose ps | grep "$service_name" | grep -q "healthy\|Up"; then
            print_success "$service_name is ready"
            return 0
        fi
        
        print_status "Waiting for $service_name... (attempt $attempt/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to become healthy"
    return 1
}

# Wait for each service
wait_for_service "rag-neo4j"
wait_for_service "rag-graphiti"
wait_for_service "rag-nginx"

# Display service status
print_status "Service Status:"
docker-compose ps

# Display access information
print_success "RAG System started successfully!"
echo ""
print_status "Access Information:"
echo "  🌐 Main Application:     http://localhost"
echo "  🔗 Graphiti API:        http://localhost/api"
echo "  💾 Neo4j Browser:       http://localhost/browser"
echo "  📊 Health Check:        http://localhost/health"
echo ""
print_status "Neo4j Credentials:"
echo "  👤 Username: ${NEO4J_USERNAME:-neo4j}"
echo "  🔑 Password: ${NEO4J_PASSWORD}"
echo ""
print_warning "To stop the system, run: ./scripts/stop.sh"
print_warning "To view logs, run: docker-compose logs -f [service_name]"