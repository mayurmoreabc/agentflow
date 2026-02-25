"""
main.py — Application Entrypoint

This is the entry point for both local development and production.
Running this directly starts a Uvicorn ASGI server.

Usage:
    # Development
    python main.py

    # Production (via Docker CMD)
    uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
"""

import uvicorn
from app import create_app
from app.config.settings import get_settings

settings = get_settings()

# Create the FastAPI application
# The `app` variable is what uvicorn looks for by default
app = create_app()

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,         # Hot-reload in dev; disabled in prod
        log_level=settings.LOG_LEVEL.lower(),
        access_log=True,
        workers=1,                     # Single worker for dev; scale in prod
    )
