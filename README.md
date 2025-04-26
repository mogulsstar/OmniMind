# OmniMind

OmniMind is a cross-platform knowledge management application with AI features, designed to help users capture, organize, and learn from various types of content.

## Features

- Transfer and save content from multiple platforms
- Parse and clean web content from various sources
- Upload and process documents, images, audio, and video
- AI-powered content analysis, summarization, and tagging
- Intelligent memory review system based on spaced repetition
- Cross-platform synchronization (mobile, web, WeChat mini program)
- Third-party cloud storage integration
- Custom AI model integration via OpenRouter

## Getting Started

### Prerequisites

- Python 3.11 or higher
- Node.js 18 or higher
- Flutter SDK 3.10 or higher
- Redis
- PostgreSQL
- MongoDB
- FFmpeg

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/omnimind.git
cd omnimind
```

2. Set up Python virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e ".[dev]"
```

3. Set up the backend:

```bash
cd server
# Always activate virtual environment first
source ../.venv/bin/activate  # On Windows: ..\.venv\Scripts\activate
# Set up database
alembic upgrade head
# Start the server
uvicorn app.main:app --reload
```

4. Set up Celery workers:

```bash
# Always activate virtual environment first
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
# Start Redis (if not already running)
docker-compose up -d redis
# Start Celery worker
celery -A omnimind.celery_app worker --loglevel=info
# Start Celery beat for scheduled tasks
celery -A omnimind.celery_app beat
# Start Flower for monitoring
celery -A omnimind.celery_app flower
```

5. Set up the Flutter app:

```bash
cd frontend/mobile
flutter pub get
flutter run
```

## Project Structure

```
OmniMind/
├── frontend/                  # Frontend applications
│   ├── mobile/                # Flutter mobile application
│   ├── web/                   # Web application
│   └── mini_program/          # WeChat Mini Program
├── server/                    # Backend services
│   ├── api/                   # FastAPI application
│   └── realtime/              # Express.js for real-time features
├── ai/                        # AI and processing services
│   ├── content_extraction/    # Web content extraction
│   ├── ocr/                   # OCR service
│   ├── speech/                # Speech recognition
│   ├── video/                 # Video processing
│   ├── nlp/                   # NLP services
│   └── learning/              # Learning features
└── docs/                      # Documentation
```

## Development

### Running Tests

```bash
# Always activate virtual environment first
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
# Run backend tests
pytest
# Run Flutter tests
cd frontend/mobile
flutter test
```

### Code Style

We follow PEP 8 for Python code and use NumPy-style docstrings. For Flutter/Dart code, we follow the official Dart style guide.

```bash
# Always activate virtual environment first
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
# Format Python code
black .
isort .
# Check Python code
flake8
mypy
```

## Deployment

### Backend Deployment

The backend services are containerized using Docker and can be deployed using Docker Compose or Kubernetes.

```bash
docker-compose up -d
```

### Mobile App Deployment

The Flutter mobile app can be built for Android and iOS:

```bash
cd frontend/mobile
# Build Android APK
flutter build apk
# Build iOS IPA
flutter build ios
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/)
- [Flutter](https://flutter.dev/)
- [Celery](https://docs.celeryq.dev/)
- [Hugging Face Transformers](https://huggingface.co/transformers/)
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)
- [FFmpeg](https://ffmpeg.org/)
