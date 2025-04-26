# OmniMind Celery Architecture for Task Processing

## Overview

Celery is a distributed task queue system that will be used in OmniMind to handle asynchronous processing, background tasks, and scheduled operations. This document outlines the architecture, configuration, and best practices for implementing Celery in the OmniMind application.

## Architecture Components

### 1. Celery Application

The Celery application is the entry point for task definition and configuration.

```python
# celery_app.py
from celery import Celery

# Always activate virtual environment before running:
# source .venv/bin/activate

app = Celery('omnimind')
app.config_from_object('omnimind.config.celery_config')

# Auto-discover tasks in all registered app modules
app.autodiscover_tasks(['omnimind.content', 'omnimind.ai', 'omnimind.media'])
```

### 2. Message Broker

Redis will be used as the message broker for its performance and reliability.

**Configuration**:
```python
# celery_config.py
broker_url = 'redis://localhost:6379/0'
result_backend = 'redis://localhost:6379/1'
```

### 3. Worker Pools

Multiple worker pools will be configured for different types of tasks:

- **Default Workers**: For general tasks
- **AI Workers**: For AI-intensive tasks (potentially GPU-enabled)
- **Media Workers**: For media processing tasks
- **Scheduled Workers**: For periodic tasks

**Worker Configuration**:
```bash
# Default workers
celery -A omnimind.celery_app worker -Q default -n default@%h -c 4

# AI workers
celery -A omnimind.celery_app worker -Q ai -n ai@%h -c 2 --concurrency=2

# Media workers
celery -A omnimind.celery_app worker -Q media -n media@%h -c 4

# Scheduled workers
celery -A omnimind.celery_app beat -S redbeat.RedBeatScheduler
```

### 4. Task Routing

Tasks will be routed to appropriate worker pools based on their type:

```python
# celery_config.py
task_routes = {
    'omnimind.content.*': {'queue': 'default'},
    'omnimind.ai.*': {'queue': 'ai'},
    'omnimind.media.*': {'queue': 'media'},
    'omnimind.scheduled.*': {'queue': 'default'},
}
```

### 5. Result Backend

Redis will also be used as the result backend for storing task results:

```python
# celery_config.py
result_backend = 'redis://localhost:6379/1'
result_expires = 60 * 60 * 24  # Results expire after 24 hours
```

### 6. Monitoring

Flower will be used for monitoring Celery tasks and workers:

```bash
# Start Flower monitoring
celery -A omnimind.celery_app flower --port=5555
```

## Task Organization

### 1. Task Modules

Tasks will be organized by functional area:

```
omnimind/
├── content/
│   ├── tasks.py  # Content-related tasks
├── ai/
│   ├── tasks.py  # AI-related tasks
├── media/
│   ├── tasks.py  # Media processing tasks
├── scheduled/
│   ├── tasks.py  # Scheduled/periodic tasks
```

### 2. Task Definition

Tasks will be defined with clear documentation and typed signatures:

```python
# content/tasks.py
from omnimind.celery_app import app
from typing import Dict, Any, Optional

@app.task(bind=True, 
          name='content.process_web_content',
          retry_backoff=True,
          retry_kwargs={'max_retries': 3})
def process_web_content(self, url: str, options: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Process web content from a URL.
    
    Parameters
    ----------
    url : str
        The URL to process
    options : Dict[str, Any], optional
        Processing options
        
    Returns
    -------
    Dict[str, Any]
        Processed content data
    """
    try:
        # Processing logic here
        return {'status': 'success', 'data': {...}}
    except Exception as exc:
        self.retry(exc=exc)
```

## Task Prioritization

Tasks will be prioritized to ensure critical operations are processed first:

```python
# High priority task
@app.task(bind=True, priority=9)
def critical_notification(self, user_id: int, message: str):
    # Send critical notification
    pass

# Normal priority task (default is 5)
@app.task(bind=True)
def regular_update(self, data: Dict[str, Any]):
    # Process regular update
    pass

# Low priority task
@app.task(bind=True, priority=1)
def background_cleanup(self):
    # Perform background cleanup
    pass
```

## Concurrency Control

### 1. Rate Limiting

Rate limiting will be applied to prevent overloading external services:

```python
# Rate limited task (max 10 per minute)
@app.task(bind=True, rate_limit='10/m')
def external_api_call(self, api_endpoint: str, params: Dict[str, Any]):
    # Call external API
    pass
```

### 2. Resource Control

Resource-intensive tasks will be controlled to prevent system overload:

```python
# Resource-intensive task with custom pool
@app.task(bind=True, pool_limit=2)
def video_transcoding(self, video_id: str, options: Dict[str, Any]):
    # Transcode video
    pass
```

## Error Handling and Retries

### 1. Automatic Retries

Tasks will be configured with automatic retry logic:

```python
@app.task(bind=True, 
          autoretry_for=(ConnectionError, TimeoutError),
          retry_kwargs={'max_retries': 5, 'countdown': 60})
def fetch_external_data(self, source_id: str):
    # Fetch data from external source
    pass
```

### 2. Custom Retry Logic

Complex retry scenarios will use custom logic:

```python
@app.task(bind=True)
def process_payment(self, payment_id: str, amount: float):
    try:
        # Process payment
        pass
    except TransientError as exc:
        # Retry with exponential backoff
        retry_in = min(2 ** self.request.retries, 3600)  # Max 1 hour
        self.retry(exc=exc, countdown=retry_in)
    except PermanentError:
        # Log and report permanent failure
        pass
```

### 3. Dead Letter Queue

Failed tasks will be sent to a dead letter queue for later analysis:

```python
# celery_config.py
task_routes = {
    # ... other routes
    'omnimind.tasks.dead_letter': {'queue': 'dead_letter'},
}

# tasks.py
@app.task(name='tasks.dead_letter')
def dead_letter_task(task_id, task_name, args, kwargs, exception):
    # Log failed task for later analysis
    pass
```

## Scheduled Tasks

### 1. Periodic Tasks

Regular maintenance and update tasks will be scheduled:

```python
# celery_config.py
beat_schedule = {
    'cleanup-expired-content': {
        'task': 'omnimind.scheduled.cleanup_expired_content',
        'schedule': 60 * 60 * 24,  # Daily
    },
    'update-ai-models': {
        'task': 'omnimind.scheduled.update_ai_models',
        'schedule': 60 * 60 * 24 * 7,  # Weekly
    },
    'user-activity-summary': {
        'task': 'omnimind.scheduled.generate_user_activity_summary',
        'schedule': 60 * 60,  # Hourly
    },
}
```

### 2. Dynamic Scheduling

Some tasks will be scheduled dynamically based on application state:

```python
from celery.schedules import schedule

def get_learning_reminder_schedule(user_id):
    # Get user's preferred reminder times
    return schedule
    
app.conf.beat_schedule[f'learning-reminder-{user_id}'] = {
    'task': 'omnimind.scheduled.send_learning_reminder',
    'schedule': get_learning_reminder_schedule(user_id),
    'args': (user_id,),
}
```

## Task Workflows

### 1. Task Chaining

Complex workflows will use task chaining:

```python
from celery import chain

# Define a workflow for content processing
workflow = chain(
    extract_content.s(url),
    clean_content.s(),
    analyze_content.s(),
    store_content.s(user_id)
)

# Execute the workflow
result = workflow.apply_async()
```

### 2. Task Groups

Parallel tasks will use task groups:

```python
from celery import group

# Process multiple items in parallel
urls = ['url1', 'url2', 'url3']
parallel_tasks = group(process_url.s(url) for url in urls)
result = parallel_tasks.apply_async()
```

### 3. Canvas Combinations

Complex workflows will combine chains and groups:

```python
from celery import chord

# Process multiple items in parallel, then aggregate results
urls = ['url1', 'url2', 'url3']
workflow = chord(
    group(process_url.s(url) for url in urls),
    aggregate_results.s(user_id)
)
result = workflow.apply_async()
```

## Deployment Considerations

### 1. Worker Scaling

Workers will be scaled based on load:

- **Horizontal Scaling**: Add more worker instances
- **Vertical Scaling**: Increase resources per worker
- **Auto-scaling**: Dynamically adjust worker count based on queue size

### 2. Monitoring and Alerting

Comprehensive monitoring will be implemented:

- **Flower Dashboard**: Real-time monitoring of tasks and workers
- **Prometheus Metrics**: Collect performance metrics
- **Grafana Dashboards**: Visualize metrics
- **Alerts**: Notify on queue backlog, worker failures, etc.

### 3. High Availability

The Celery infrastructure will be designed for high availability:

- **Multiple Brokers**: Redis sentinel or cluster
- **Multiple Workers**: Distributed across servers
- **Supervisor**: Automatic worker restart on failure

## Development Workflow

### 1. Local Development

For local development:

```bash
# Always activate virtual environment first
source .venv/bin/activate

# Start Redis
docker-compose up -d redis

# Start Celery worker
celery -A omnimind.celery_app worker --loglevel=info

# Start Celery beat for scheduled tasks
celery -A omnimind.celery_app beat

# Start Flower for monitoring
celery -A omnimind.celery_app flower
```

### 2. Testing

Celery tasks will be tested with:

- **Unit Tests**: Test task logic in isolation
- **Integration Tests**: Test task execution with mocked broker
- **End-to-End Tests**: Test complete workflows

```python
# Example test with pytest
def test_process_web_content(mocker):
    # Mock dependencies
    mock_fetch = mocker.patch('omnimind.content.services.fetch_url')
    mock_fetch.return_value = '<html>Test content</html>'
    
    # Execute task synchronously for testing
    result = process_web_content.apply(args=['https://example.com']).get()
    
    # Assert results
    assert result['status'] == 'success'
    assert 'data' in result
```

## Conclusion

This Celery architecture provides a robust foundation for handling asynchronous processing, background tasks, and scheduled operations in the OmniMind application. By properly configuring worker pools, task routing, and error handling, we can ensure efficient and reliable task processing across the system.

Remember to always activate the Python virtual environment with `source .venv/bin/activate` before running any Celery-related commands.
