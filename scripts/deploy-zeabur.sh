#!/bin/bash

# Zeabur Deployment Script for RAG System
# This script prepares and deploys the RAG system to Zeabur cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[ZEABUR-DEPLOY]${NC} $1"
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
print_status "Checking prerequisites for Zeabur deployment..."

if ! command_exists git; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_status "Working directory: $PROJECT_DIR"

# Check if .env file exists and has required variables
if [ ! -f .env ]; then
    print_error ".env file not found. Please create it from .env.example first."
    exit 1
fi

source .env

if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    print_error "Neither OPENAI_API_KEY nor ANTHROPIC_API_KEY is set in .env file"
    exit 1
fi

# Create production docker-compose override
print_status "Creating production configuration..."
cat > docker-compose.prod.yml << EOF
version: '3.8'

services:
  nginx:
    environment:
      - DOMAIN=\${DOMAIN:-localhost}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ssl-certs:/etc/ssl/certs:ro
      - ssl-private:/etc/ssl/private:ro

  neo4j:
    environment:
      - NEO4J_server_default__advertised__address=\${DOMAIN:-localhost}
      - NEO4J_server_bolt_advertised__address=\${DOMAIN:-localhost}:7687
      - NEO4J_server_http_advertised__address=\${DOMAIN:-localhost}:7474

  graphiti:
    environment:
      - GRAPHITI_HOST=0.0.0.0
      - GRAPHITI_PORT=8000

volumes:
  ssl-certs:
    external: true
  ssl-private:
    external: true
EOF

print_success "Production configuration created"

# Create Zeabur template
print_status "Creating Zeabur template..."
cat > zeabur/template.yaml << EOF
apiVersion: zeabur.com/v1
kind: Template
metadata:
  name: rag-system
spec:
  description: RAG System with Nginx, Neo4j, and Graphiti
  icon: https://raw.githubusercontent.com/zeabur/zeabur/main/assets/icon.png
  tags:
    - ai
    - rag
    - neo4j
    - graphiti
    - nginx
  readme: |
    # RAG System Template

    This template deploys a complete RAG (Retrieval-Augmented Generation) system with:
    
    - **Nginx**: Reverse proxy and web server
    - **Neo4j**: Graph database for knowledge storage
    - **Graphiti**: RAG engine for AI-powered queries
    
    ## Required Environment Variables
    
    You must set at least one of these API keys:
    - \`OPENAI_API_KEY\`: Your OpenAI API key
    - \`ANTHROPIC_API_KEY\`: Your Anthropic API key
    
    ## Optional Configuration
    
    - \`NEO4J_USERNAME\`: Neo4j username (default: neo4j)
    - \`NEO4J_PASSWORD\`: Neo4j password (default: changeme123)
    - \`LOG_LEVEL\`: Application log level (default: INFO)

  services:
    - name: nginx
      icon: https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nginx/nginx-original.svg
      template: NGINX
      ports:
        - id: web
          port: 80
          type: HTTP
      volumes:
        - id: nginx-config
          dir: /etc/nginx/conf.d
      env:
        DOMAIN:
          default: \${ZEABUR_WEB_DOMAIN}

    - name: neo4j
      icon: https://cdn.jsdelivr.net/gh/devicons/devicon/icons/neo4j/neo4j-original.svg
      template: NEO4J
      ports:
        - id: http
          port: 7474
          type: HTTP
        - id: bolt
          port: 7687
          type: TCP
      volumes:
        - id: neo4j-data
          dir: /data
        - id: neo4j-logs
          dir: /logs
      env:
        NEO4J_USERNAME:
          default: neo4j
        NEO4J_PASSWORD:
          default: changeme123
        NEO4J_ACCEPT_LICENSE_AGREEMENT:
          default: "yes"

    - name: graphiti
      icon: https://avatars.githubusercontent.com/u/6442994?s=200&v=4
      template: PREBUILT
      source:
        image: zepai/graphiti:latest
      ports:
        - id: api
          port: 8000
          type: HTTP
      volumes:
        - id: graphiti-data
          dir: /app/data
      env:
        NEO4J_URI:
          default: bolt://neo4j:7687
        NEO4J_USERNAME:
          default: neo4j
        NEO4J_PASSWORD:
          default: changeme123
        OPENAI_API_KEY:
          type: SECRET
        ANTHROPIC_API_KEY:
          type: SECRET
        GRAPHITI_HOST:
          default: 0.0.0.0
        GRAPHITI_PORT:
          default: "8000"
        LOG_LEVEL:
          default: INFO

  variables:
    - key: OPENAI_API_KEY
      name: OpenAI API Key
      description: Your OpenAI API key for LLM functionality
      type: SECRET
      
    - key: ANTHROPIC_API_KEY
      name: Anthropic API Key
      description: Your Anthropic API key (alternative to OpenAI)
      type: SECRET
      
    - key: NEO4J_PASSWORD
      name: Neo4j Password
      description: Password for Neo4j database
      default: changeme123
      type: SECRET
      
    - key: DOMAIN
      name: Domain
      description: Your custom domain (optional)
      type: STRING
EOF

print_success "Zeabur template created"

# Create deployment instructions
print_status "Creating deployment instructions..."
cat > DEPLOY.md << 'EOF'
# Zeabur Deployment Guide

## Prerequisites

1. **Zeabur Account**: Sign up at [zeabur.com](https://zeabur.com)
2. **API Keys**: Obtain at least one of:
   - OpenAI API key from [platform.openai.com](https://platform.openai.com/api-keys)
   - Anthropic API key from [console.anthropic.com](https://console.anthropic.com/)

## Deployment Steps

### Option 1: Using Zeabur Template (Recommended)

1. Visit the Zeabur template gallery
2. Search for "RAG System" or use the template link
3. Click "Deploy" and configure:
   - **OPENAI_API_KEY** or **ANTHROPIC_API_KEY** (required)
   - **NEO4J_PASSWORD** (recommended to change from default)
   - **DOMAIN** (optional, for custom domain)

### Option 2: Manual Git Deployment

1. **Fork/Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd RAG
   ```

2. **Create Zeabur project**
   - Go to [dash.zeabur.com](https://dash.zeabur.com)
   - Create new project
   - Connect your Git repository

3. **Deploy services individually**
   - Deploy Neo4j service first
   - Deploy Graphiti service (depends on Neo4j)
   - Deploy Nginx service last

4. **Configure environment variables**
   - Set required API keys in Zeabur dashboard
   - Configure service URLs and ports

## Service Configuration

### Neo4j Configuration
- **Port**: 7474 (HTTP), 7687 (Bolt)
- **Memory**: Recommended 2GB+ for production
- **Storage**: Persistent volume required

### Graphiti Configuration
- **Port**: 8000
- **Dependencies**: Neo4j must be running
- **API Keys**: Required for LLM functionality

### Nginx Configuration
- **Port**: 80 (HTTP), 443 (HTTPS)
- **SSL**: Automatic with Zeabur domains
- **Proxy**: Routes traffic to backend services

## Post-Deployment

1. **Verify services**: Check all services are healthy
2. **Test API**: Send test requests to `/health` endpoint
3. **Neo4j Browser**: Access via `/browser/` path
4. **Monitor logs**: Use Zeabur dashboard for debugging

## Custom Domain (Optional)

1. **Add domain** in Zeabur project settings
2. **Configure DNS** to point to Zeabur
3. **SSL certificate** will be automatically provisioned

## Troubleshooting

- **Service startup issues**: Check environment variables
- **API connection errors**: Verify API keys are correct
- **Neo4j connection**: Ensure bolt://neo4j:7687 is accessible
- **Memory issues**: Increase service memory allocation

## Support

For issues:
1. Check service logs in Zeabur dashboard
2. Verify environment variable configuration
3. Review Neo4j and Graphiti documentation
4. Contact support if needed
EOF

print_success "Deployment instructions created"

# Initialize git repository if not exists
if [ ! -d .git ]; then
    print_status "Initializing git repository..."
    git init
    echo "node_modules/" > .gitignore
    echo ".env" >> .gitignore
    echo "logs/" >> .gitignore
    echo "data/" >> .gitignore
    git add .
    git commit -m "Initial RAG system setup for Zeabur deployment"
    print_success "Git repository initialized"
else
    print_status "Git repository already exists"
    
    # Check if there are changes to commit
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_status "Committing changes..."
        git add .
        git commit -m "Update RAG system configuration for Zeabur deployment"
        print_success "Changes committed"
    fi
fi

print_success "Zeabur deployment preparation complete!"
echo ""
print_status "Next Steps:"
echo "  1. Push your code to GitHub/GitLab/Bitbucket"
echo "  2. Go to dash.zeabur.com and create a new project"
echo "  3. Connect your Git repository"
echo "  4. Deploy services in this order: Neo4j → Graphiti → Nginx"
echo "  5. Set environment variables in Zeabur dashboard"
echo "  6. Access your RAG system via the Zeabur-provided URL"
echo ""
print_warning "Don't forget to set your API keys in the Zeabur environment variables!"
print_status "See DEPLOY.md for detailed deployment instructions"