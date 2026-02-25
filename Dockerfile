# =============================================================================
# Dockerfile — Multi-Stage Production Build
# =============================================================================
#
# WHY MULTI-STAGE BUILDS:
#   Stage 1 (builder): Install build tools, compile dependencies
#   Stage 2 (runtime): Copy ONLY compiled artifacts — no build tools, no
#                      dev dependencies, no source caches.
#
#   Result: Final image is ~60% smaller than a single-stage build.
#   Smaller images = faster cold starts, less attack surface, lower registry costs.
#
# WHY python:3.12-slim (not alpine):
#   Alpine uses musl libc instead of glibc. Many Python scientific packages
#   (numpy, chromadb deps) don't have musl wheels and must compile from source,
#   making builds slow and fragile. Slim keeps glibc and stays small.
# =============================================================================

# ── Stage 1: Dependency Builder ───────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies for packages that compile C extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency manifest FIRST (Docker layer caching optimization)
# WHY: If requirements.txt doesn't change, Docker reuses this cached layer.
#      Only source code changes rebuild this layer. Dramatically speeds up CI.
COPY requirements.txt .

# Install to a local directory for clean copying to runtime stage
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt


# ── Stage 2: Production Runtime ───────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Security: Run as non-root user
# WHY: If a dependency has an RCE vulnerability, attacker gets user-level
#      access rather than root. Defense in depth.
RUN groupadd -r agentflow && useradd -r -g agentflow agentflow

WORKDIR /app

# Copy compiled dependencies from builder
COPY --from=builder /install /usr/local

# Copy application source
COPY --chown=agentflow:agentflow . .

# Switch to non-root user
USER agentflow

# ── Environment ───────────────────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app

# ── Health Check ──────────────────────────────────────────────────────────────
# Docker and Kubernetes use this to determine container health.
# Checks every 30s; 3 consecutive failures → container marked unhealthy.
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import httpx; r = httpx.get('http://localhost:8000/api/v1/health/live'); r.raise_for_status()"

EXPOSE 8000

# ── Entrypoint ────────────────────────────────────────────────────────────────
# WHY NOT CMD ["python", "main.py"]:
#   uvicorn directly is more production-appropriate than running via Python.
#   --workers 4 uses 4 OS processes for CPU parallelism (adjust to 2× CPU cores).
#   --no-access-log in prod (use nginx/reverse-proxy logs instead).
CMD ["uvicorn", "main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "4", \
     "--loop", "uvloop", \
     "--log-level", "info"]
