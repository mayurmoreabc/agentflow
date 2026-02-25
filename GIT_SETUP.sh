#!/bin/bash
# =============================================================================
# GIT_SETUP.sh — Initialize Repo & Push to GitHub
# =============================================================================
# USAGE:
#   1. Replace YOUR_GITHUB_ID below with your actual GitHub username
#   2. Create an empty repo named "agentflow" on GitHub (no README, no .gitignore)
#   3. Run: chmod +x GIT_SETUP.sh && ./GIT_SETUP.sh
# =============================================================================

# ── CONFIGURATION — EDIT THIS ─────────────────────────────────────────────────
GITHUB_ID="YOUR_GITHUB_ID"        # ← Replace with your GitHub username
REPO_NAME="agentflow"
# ─────────────────────────────────────────────────────────────────────────────

echo "🚀 Initializing AgentFlow repository..."

# Step 1: Initialize git
git init
echo "✅ Git initialized"

# Step 2: Stage all files
git add .
echo "✅ All files staged"

# Step 3: Initial commit with a professional message
git commit -m "feat: initial commit — AgentFlow multi-agent orchestrator

Built with:
- LangGraph 0.2 for stateful multi-agent graph orchestration
- FastAPI 0.115 async REST API
- ChromaDB 0.6 vector memory with semantic retrieval
- Docker + Compose for containerized deployment
- Researcher → Writer → Reviewer self-reflection pipeline

Agents:
- ResearcherAgent: ReAct + Tavily web search + RAG memory
- WriterAgent: Document synthesis from structured research
- ReviewerAgent: Quality scoring (0-1.0) with revision feedback loop

Industrial patterns: Template Method, Repository, Facade,
Dependency Injection, 12-Factor Config, Finite State Machine"

echo "✅ Initial commit created"

# Step 4: Set main as default branch (modern standard)
git branch -M main

# Step 5: Add GitHub remote
git remote add origin "https://github.com/${GITHUB_ID}/${REPO_NAME}.git"
echo "✅ Remote origin set: https://github.com/${GITHUB_ID}/${REPO_NAME}.git"

# Step 6: Push to GitHub
git push -u origin main
echo ""
echo "🎉 Success! Your repo is live at:"
echo "   https://github.com/${GITHUB_ID}/${REPO_NAME}"
echo ""
echo "📌 Next steps:"
echo "   1. Add a description on GitHub: 'Enterprise-grade autonomous AI agent orchestrator built with LangGraph'"
echo "   2. Add topics: agentic-ai, langgraph, fastapi, chromadb, multi-agent, llm"
echo "   3. Star your own repo to boost visibility"
