#!/bin/bash

# OmniMind Environment Setup Script

echo "Setting up OmniMind development environment..."

# Create Python virtual environment
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
    echo "Virtual environment created."
else
    echo "Virtual environment already exists."
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -e ".[dev]"

# Create necessary directories
echo "Creating project directories..."
mkdir -p frontend/mobile
mkdir -p frontend/web
mkdir -p frontend/mini_program
mkdir -p server/api
mkdir -p server/realtime
mkdir -p ai/content_extraction
mkdir -p ai/ocr
mkdir -p ai/speech
mkdir -p ai/video
mkdir -p ai/nlp
mkdir -p ai/learning
mkdir -p docs

# Create basic configuration files
echo "Creating configuration files..."

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    cat > .env << EOF
# OmniMind Environment Variables

# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/omnimind
MONGODB_URL=mongodb://localhost:27017/omnimind

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AI Services
OPENAI_API_KEY=your-openai-api-key-here

# Storage
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_URL=http://localhost:9000
EOF
    echo ".env file created."
else
    echo ".env file already exists."
fi

# Create docker-compose.yml file
if [ ! -f "docker-compose.yml" ]; then
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: omnimind
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  minio:
    image: minio/minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"

volumes:
  postgres_data:
  mongodb_data:
  minio_data:
EOF
    echo "docker-compose.yml file created."
else
    echo "docker-compose.yml file already exists."
fi

# Create a basic FastAPI app structure
if [ ! -f "server/api/main.py" ]; then
    mkdir -p server/api/app/api/v1
    mkdir -p server/api/app/core
    mkdir -p server/api/app/db
    mkdir -p server/api/app/schemas
    mkdir -p server/api/app/services

    # Create main.py
    cat > server/api/main.py << EOF
"""
OmniMind API main entry point.

Always activate virtual environment before running:
source .venv/bin/activate
"""

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="OmniMind API",
    description="API for OmniMind knowledge management application",
    version="0.1.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    """
    Root endpoint.
    
    Returns
    -------
    dict
        Welcome message
    """
    return {"message": "Welcome to OmniMind API"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
EOF
    echo "Basic FastAPI app structure created."
else
    echo "FastAPI app structure already exists."
fi

# Create Celery app
if [ ! -f "server/api/app/core/celery_app.py" ]; then
    mkdir -p server/api/app/core
    
    # Create celery_app.py
    cat > server/api/app/core/celery_app.py << EOF
"""
Celery application configuration.

Always activate virtual environment before running:
source .venv/bin/activate
"""

from celery import Celery

# Create Celery app
celery_app = Celery("omnimind")

# Load configuration
celery_app.config_from_object("app.core.celery_config")

# Auto-discover tasks
celery_app.autodiscover_tasks(["app.services"])

# Define a simple test task
@celery_app.task(bind=True)
def debug_task(self):
    """
    Debug task to test Celery setup.
    
    Returns
    -------
    str
        Task information
    """
    print(f"Request: {self.request!r}")
    return "Hello from Celery!"
EOF

    # Create celery_config.py
    cat > server/api/app/core/celery_config.py << EOF
"""
Celery configuration.

Always activate virtual environment before running:
source .venv/bin/activate
"""

# Broker settings
broker_url = "redis://localhost:6379/0"
result_backend = "redis://localhost:6379/1"

# Task settings
task_serializer = "json"
accept_content = ["json"]
result_serializer = "json"
timezone = "UTC"
enable_utc = True

# Task execution settings
worker_concurrency = 8
worker_prefetch_multiplier = 1
task_acks_late = True
task_reject_on_worker_lost = True

# Task routing
task_routes = {
    "app.services.content.*": {"queue": "content"},
    "app.services.ai.*": {"queue": "ai"},
    "app.services.media.*": {"queue": "media"},
}

# Beat schedule
beat_schedule = {
    "cleanup-expired-content": {
        "task": "app.services.scheduled.cleanup_expired_content",
        "schedule": 60 * 60 * 24,  # Daily
    },
}
EOF
    echo "Celery app created."
else
    echo "Celery app already exists."
fi

echo "Environment setup complete!"
echo "To activate the virtual environment, run: source .venv/bin/activate"
echo "To start the development services, run: docker-compose up -d"
echo "To start the API server, run: cd server/api && uvicorn main:app --reload"
