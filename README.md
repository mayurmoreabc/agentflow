# 🤖 AgentFlow — Enterprise-Grade Autonomous AI Agent Orchestrator

<div align="center">

![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![LangGraph](https://img.shields.io/badge/LangGraph-0.2-FF6B35?style=for-the-badge)
![ChromaDB](https://img.shields.io/badge/ChromaDB-0.6-7C3AED?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge)

**A production-ready multi-agent AI orchestration system built on Next-Gen Agentic AI principles.**

*Spawn a team of autonomous AI agents — Researcher, Writer, Reviewer — that collaboratively accomplish complex goals with self-reflection loops, vector memory, and web search.*

[Architecture](#architecture) • [Quick Start](#quick-start) • [API Docs](#api-reference) • [Tech Stack](#tech-stack)

</div>

---

## 📌 What Is AgentFlow?

AgentFlow is a flagship demonstration of **Agentic AI** — the most significant architectural shift in applied AI since transformers. Instead of a single LLM answering a question, AgentFlow orchestrates a **team of specialized autonomous agents** that reason, act, and collaborate to accomplish complex multi-step goals.

**You give it a goal. It figures out how to achieve it.**

```
User: "Research Anthropic's competitive position and write an investor report"
         │
         ▼
┌─────────────────────────────────────────────────────┐
│               AgentFlow Orchestrator                │
│           (LangGraph Stateful Pipeline)             │
└──────┬─────────────────────────────────────────┬────┘
       │                                         │
┌──────▼──────┐    ┌──────────┐    ┌─────────────▼──┐
│ RESEARCHER  │───▶│  WRITER  │───▶│   REVIEWER     │
│             │    │          │    │                │
│ Web search  │    │ Drafts   │    │ Scores 0-1.0   │
│ + RAG recall│    │ document │    │ Requests edits │
│ + memory    │    │ from     │    │ or approves    │
│   storage   │    │ research │    │ final output   │
└─────────────┘    └──────────┘    └────────────────┘
                                          │
                           score ≥ 0.75? YES → Final Output
                                          │
                           score < 0.75?  NO  → Writer revises
```

---

## 🏗️ Architecture

### Why LangGraph (Not Plain LangChain)?

Standard LangChain chains are **linear**: A → B → C. Real-world agent workflows require:
- **Cycles** (Reviewer sends output back to Writer for revision)
- **Conditional branching** (Route based on quality score)
- **Shared persistent state** (All agents read/write the same context)
- **Human-in-the-loop** interrupts at any node

LangGraph provides all of this as a first-class **stateful directed graph**. It's what companies like Elastic, Replit, and LinkedIn use in production agentic systems.

### The Self-Reflection Loop (Critic Pattern)

The Researcher → Writer → **Reviewer → Writer** cycle implements the academic "Reflexion" pattern: having a system critique its own output produces dramatically higher quality results than single-pass generation. The Reviewer scores output on 5 dimensions (accuracy, completeness, clarity, structure, actionability) and sends specific, actionable feedback for revision.

### Vector Memory (ChromaDB)

Agents don't start from zero — they **recall** relevant past research from ChromaDB before running. This implements:
- **Retrieval-Augmented Generation (RAG)**: Context from prior tasks enriches new ones
- **Semantic search**: Retrieved chunks are ranked by meaning, not keywords
- **Persistent organizational knowledge**: The system learns across tasks over time

### Project Structure

```
agentflow/
├── 📁 app/
│   ├── 📁 agents/
│   │   ├── base_agent.py        # Abstract base: LLM init, token tracking, retry
│   │   ├── researcher.py        # ReAct agent with Tavily web search
│   │   ├── writer.py            # Document synthesis agent
│   │   └── reviewer.py         # Quality evaluation + structured scoring
│   ├── 📁 orchestrator/
│   │   ├── graph.py             # LangGraph StateGraph definition + routing
│   │   └── state.py             # Typed shared state (AgentFlowState)
│   ├── 📁 memory/
│   │   └── vector_store.py     # ChromaDB abstraction (Repository Pattern)
│   ├── 📁 api/routes/
│   │   ├── tasks.py             # POST /tasks, GET /tasks/{id}, DELETE
│   │   └── health.py           # /health/live, /health/ready (K8s probes)
│   ├── 📁 models/
│   │   └── task.py              # Pydantic v2 domain models
│   └── 📁 config/
│       └── settings.py         # Pydantic BaseSettings (12-Factor config)
├── 📁 tests/
│   ├── test_api.py              # FastAPI integration tests
│   └── test_agents.py          # Agent unit tests (mocked LLM)
├── main.py                      # Uvicorn ASGI entrypoint
├── Dockerfile                   # Multi-stage production build
├── docker-compose.yml           # Full stack: API + ChromaDB
├── requirements.txt             # Pinned dependencies
└── .env.example                 # Config template
```

---

## 🛠️ Tech Stack

| Layer | Technology | Why This Choice |
|-------|-----------|----------------|
| **Agent Framework** | LangGraph 0.2 | Stateful graph for cycles + conditional routing |
| **LLM** | GPT-4o (OpenAI) | Best reasoning for agentic multi-step tasks |
| **Web Search** | Tavily API | AI-optimized search, clean output for LLM context |
| **Vector DB** | ChromaDB 0.6 | Zero-dependency embedded DB; swap to Pinecone in prod |
| **Embeddings** | text-embedding-3-small | Best cost/performance for RAG retrieval |
| **API Framework** | FastAPI 0.115 | Async-native, auto OpenAPI docs, Pydantic integration |
| **Containerization** | Docker + Compose | Reproducible builds, service orchestration |
| **Testing** | pytest + pytest-asyncio | Async-compatible unit + integration tests |

---

## 🚀 Quick Start

### Prerequisites

- Docker Desktop installed and running
- OpenAI API key (`gpt-4o` access)
- Tavily API key (free tier at [tavily.com](https://tavily.com))

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_GITHUB_ID/agentflow.git
cd agentflow
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Open `.env` and fill in your API keys:

```env
OPENAI_API_KEY=sk-your-openai-api-key
TAVILY_API_KEY=tvly-your-tavily-key
```

### 3. Launch with Docker Compose

```bash
# Build and start all services (API + ChromaDB)
docker compose up --build

# Or run in background
docker compose up --build -d
```

The API will be available at:
- **API**: http://localhost:8000
- **Interactive Docs**: http://localhost:8000/docs
- **ChromaDB**: http://localhost:8001

### 4. Create Your First Task

```bash
curl -X POST http://localhost:8000/api/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "goal": "Research the current state of open-source LLM alternatives to GPT-4 and write a comprehensive comparison report",
    "priority": "high"
  }'
```

**Response (202 Accepted):**
```json
{
  "task_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "pending",
  "goal": "Research the current state of...",
  "created_at": "2025-01-15T10:30:00Z"
}
```

### 5. Poll for Results

```bash
# Poll every 10 seconds until status = "completed"
curl http://localhost:8000/api/v1/tasks/550e8400-e29b-41d4-a716-446655440000
```

---

## 📡 API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/tasks` | Create and launch a new agent task |
| `GET` | `/api/v1/tasks/{id}` | Get full task status + results |
| `GET` | `/api/v1/tasks` | List all tasks (with pagination) |
| `DELETE` | `/api/v1/tasks/{id}` | Delete a completed task |
| `GET` | `/api/v1/health/live` | Liveness probe (K8s) |
| `GET` | `/api/v1/health/ready` | Readiness probe — checks all deps |

Full interactive docs at **http://localhost:8000/docs**

---

## 🧪 Running Tests

```bash
# Local (with venv)
python -m pytest tests/ -v --cov=app --cov-report=html

# Inside Docker
docker compose exec api pytest tests/ -v
```

---

## ⚙️ Configuration Reference

All configuration is managed via `.env` (see `.env.example`):

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENAI_MODEL` | `gpt-4o` | LLM model — swap to `gpt-4o-mini` to cut costs |
| `MAX_AGENT_ITERATIONS` | `10` | Hard limit on ReAct loop iterations |
| `TASK_TIMEOUT_SECONDS` | `300` | Pipeline timeout (5 minutes) |
| `ENABLE_HUMAN_IN_LOOP` | `false` | Pause before Writer for human review |
| `MAX_RESEARCH_RESULTS` | `5` | Number of web search results per query |

---

## 🔑 Key Design Patterns (For Interviewers)

| Pattern | Where Used | Why |
|---------|-----------|-----|
| **Template Method** | `BaseAgent` → subagents | Shared LLM lifecycle, each agent owns unique logic |
| **Repository Pattern** | `VectorMemory` over ChromaDB | Infrastructure isolated from business logic |
| **Facade Pattern** | `AgentOrchestrator.run()` | Hides LangGraph complexity behind simple interface |
| **Factory Function** | `create_app()` | Testable, configurable app initialization |
| **Dependency Injection** | FastAPI `Depends()` | Decoupled dependencies, easy to mock in tests |
| **Finite State Machine** | `TaskStatus` enum | Predictable, auditable task lifecycle |
| **Critic / Self-Reflection** | Reviewer → Writer loop | Industry pattern (Reflexion paper) for quality |
| **12-Factor Config** | `pydantic-settings` | Environment-based config, no hardcoded values |

---

## 🗺️ Roadmap

- [ ] **WebSocket streaming** — stream agent thoughts to the UI in real-time
- [ ] **Redis task queue** — replace in-memory store with persistent queue
- [ ] **Agent observability** — LangSmith / OpenTelemetry trace integration
- [ ] **React frontend** — visual agent execution dashboard
- [ ] **Kubernetes manifests** — production-grade K8s deployment
- [ ] **Multi-LLM support** — Claude 3.5, Gemini 1.5 as agent providers

---

## 📜 License

MIT © [YOUR_GITHUB_ID](https://github.com/YOUR_GITHUB_ID)

---

<div align="center">
Built to demonstrate mastery of <strong>Agentic AI</strong> — the next generation of AI engineering.
</div>
