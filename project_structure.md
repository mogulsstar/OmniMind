# OmniMind Project Structure

## Directory Structure

```
OmniMind/
├── frontend/                  # Frontend applications
│   ├── mobile/                # Flutter mobile application
│   │   ├── android/           # Android-specific code
│   │   ├── ios/               # iOS-specific code
│   │   ├── lib/               # Dart code for Flutter app
│   │   │   ├── api/           # API client code
│   │   │   ├── models/        # Data models
│   │   │   ├── screens/       # UI screens
│   │   │   ├── services/      # Business logic services
│   │   │   ├── utils/         # Utility functions
│   │   │   ├── widgets/       # Reusable UI components
│   │   │   └── main.dart      # Entry point
│   │   └── test/              # Tests for Flutter app
│   ├── web/                   # Web application (React)
│   │   ├── public/            # Static assets
│   │   ├── src/               # React source code
│   │   └── package.json       # Dependencies
│   └── mini_program/          # WeChat Mini Program (Taro)
│       ├── src/               # Taro source code
│       └── package.json       # Dependencies
├── server/                    # Backend services
│   ├── api/                   # FastAPI application
│   │   ├── app/               # Application code
│   │   │   ├── api/           # API endpoints
│   │   │   │   ├── v1/        # API version 1
│   │   │   │   └── deps.py    # Dependency injection
│   │   │   ├── core/          # Core functionality
│   │   │   │   ├── config.py  # Configuration
│   │   │   │   ├── security.py # Security utilities
│   │   │   │   └── errors.py  # Error handling
│   │   │   ├── db/            # Database models and repositories
│   │   │   │   ├── models/    # SQLAlchemy models
│   │   │   │   └── repositories/ # Data access layer
│   │   │   ├── schemas/       # Pydantic schemas
│   │   │   └── services/      # Business logic services
│   │   ├── tests/             # Tests for FastAPI app
│   │   ├── alembic/           # Database migrations
│   │   ├── pyproject.toml     # Python dependencies
│   │   └── main.py            # Entry point
│   ├── realtime/              # Express.js for real-time features
│   │   ├── src/               # Source code
│   │   └── package.json       # Dependencies
│   └── docker-compose.yml     # Docker services configuration
├── ai/                        # AI and processing services
│   ├── content_extraction/    # Web content extraction service
│   │   ├── app/               # Application code
│   │   └── Dockerfile         # Docker configuration
│   ├── ocr/                   # OCR service
│   │   ├── app/               # Application code
│   │   └── Dockerfile         # Docker configuration
│   ├── speech/                # Speech recognition service
│   │   ├── app/               # Application code
│   │   └── Dockerfile         # Docker configuration
│   ├── video/                 # Video processing service
│   │   ├── app/               # Application code
│   │   └── Dockerfile         # Docker configuration
│   ├── nlp/                   # NLP services (summarization, classification)
│   │   ├── app/               # Application code
│   │   └── Dockerfile         # Docker configuration
│   └── learning/              # Learning and memory features
│       ├── app/               # Application code
│       └── Dockerfile         # Docker configuration
├── docs/                      # Documentation
│   ├── api/                   # API documentation
│   ├── architecture/          # Architecture diagrams
│   └── development/           # Development guides
├── scripts/                   # Utility scripts
│   ├── setup.sh               # Setup script
│   └── deploy.sh              # Deployment script
├── .github/                   # GitHub configuration
│   └── workflows/             # GitHub Actions workflows
├── .gitignore                 # Git ignore file
└── README.md                  # Project overview
```

## Key Components

### Frontend

1. **Mobile Application (Flutter)**
   - Cross-platform mobile app for Android and iOS
   - Offline-first architecture with local storage
   - Material Design 3 UI with custom theming
   - State management with Provider or Riverpod

2. **Web Application (React)**
   - Progressive Web App (PWA) for browser access
   - Responsive design for desktop and mobile
   - State management with Redux or Context API
   - Material UI or Tailwind CSS for styling

3. **WeChat Mini Program (Taro)**
   - Mini program for WeChat platform
   - React-based syntax with Taro framework
   - Integration with WeChat APIs

### Backend

1. **API Service (FastAPI)**
   - RESTful API endpoints
   - Authentication and authorization
   - Database access layer
   - Business logic implementation
   - API documentation with Swagger/OpenAPI

2. **Realtime Service (Express.js)**
   - WebSocket connections for real-time updates
   - Notification system
   - Integration with third-party services

### AI and Processing Services

1. **Content Extraction Service**
   - Web scraping and content cleaning
   - HTML parsing and extraction
   - Ad and comment removal
   - Markdown conversion

2. **OCR Service**
   - Image text recognition
   - Document scanning
   - Handwriting recognition
   - Markdown conversion

3. **Speech Recognition Service**
   - Audio transcription
   - Speaker diarization
   - Timestamp generation
   - Markdown conversion

4. **Video Processing Service**
   - Video link parsing
   - Video downloading
   - Audio extraction
   - Transcription with timestamps
   - Video metadata extraction

5. **NLP Service**
   - Text summarization
   - Content classification
   - Tag generation
   - Semantic search
   - Entity recognition

6. **Learning Service**
   - Spaced repetition algorithm
   - Question generation
   - Learning analytics
   - Custom test creation

### Database

1. **PostgreSQL**
   - User data
   - Content metadata
   - Relationships
   - Learning data

2. **MongoDB**
   - Unstructured content
   - Document storage
   - Media metadata

3. **Redis**
   - Caching
   - Session management
   - Pub/sub messaging
   - Rate limiting

### Storage

1. **MinIO**
   - Object storage for files
   - S3-compatible API
   - Scalable and distributed

2. **Third-party Storage Integration**
   - Baidu Cloud
   - Alibaba Cloud
   - Quark Netdisk
   - Other cloud storage providers

## Development Workflow

1. **Local Development**
   - Docker Compose for local services
   - Hot reloading for frontend development
   - Automated testing with CI/CD

2. **Continuous Integration**
   - GitHub Actions for automated testing
   - Code quality checks
   - Security scanning

3. **Deployment**
   - Containerized deployment with Docker
   - Kubernetes for orchestration (if needed)
   - Cloud provider deployment (AWS, Azure, Alibaba Cloud)

4. **Monitoring and Maintenance**
   - Prometheus/Grafana for monitoring
   - Sentry for error tracking
   - ELK Stack for log management
