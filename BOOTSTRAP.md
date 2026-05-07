# Vault OS - First Launch Setup

Welcome to your PARA-based Obsidian vault with a built-in AI agent.

This guide walks you through personalizing the vault on first launch. Run it by opening a Claude Code session in this directory and saying: **"Run bootstrap"**.

---

## Step 1: Name your agent

Your agent lives in `_agent/` and operates as your knowledge worker. Pick a name for it.

> **Default:** Noa

**What this changes:**
- `CLAUDE.md` - root instructions (agent name reference)
- `_agent/context/IDENTITY.md` - agent's self-concept

> You can change the agent name anytime by editing `_agent/context/IDENTITY.md`.

---

## Step 2: Agent personality

Choose a communication style for your agent.

| Style | Description |
|---|---|
| **direct** (default) | Short sentences. No filler. Leads with the answer. |
| **conversational** | Warmer tone. Still concise but more collaborative. |
| **technical** | Precise language. Assumes domain expertise. Minimal hand-holding. |
| **custom** | Describe your own style and the agent will write it. |

**What this changes:**
- `_agent/context/SOUL.md` - tone, communication rules, boundaries

> You can tweak the agent's personality anytime by editing `_agent/context/SOUL.md`.

---

## Step 3: About you

Tell the agent who you are so it can tailor its work to you. All fields are optional.

| Field | Example | Why it helps |
|---|---|---|
| **Name** | Alex | So the agent knows how to address you |
| **Role** | Founder, engineer, student, etc. | Adjusts depth and framing of answers |
| **Interests / domains** | AI, cooking, fitness, finance | Helps prioritize research and connections |
| **How you use this vault** | Daily journaling, project tracking, research | Focuses the agent on your actual workflows |
| **Anything else** | "I prefer bullet points over paragraphs" | Any preference that shapes how the agent works |

**What this changes:**
- `_agent/context/USER.md` - agent's understanding of who it's working with

> You can update your profile anytime by editing `_agent/context/USER.md`.

---

## Step 4: Agent knowledge base seeding

Optionally give the agent some starting topics to research. This kickstarts the wiki so you're not starting from zero.

> Examples:
> - "Research PARA method best practices"
> - "Research GTD and how it compares to PARA"
> - "Research [your industry/domain]"

The agent will create wiki articles in `_agent/wiki/` and you can query them anytime with "What do you know about X?"

---

## Step 5: Review and apply

After collecting your answers, the agent will:

1. Update `_agent/context/IDENTITY.md` with the agent name
2. Update `_agent/context/SOUL.md` with personality settings
3. Update `_agent/context/USER.md` with your profile
4. Update `CLAUDE.md` with the agent name
5. Log the setup to `_agent/log.md`
6. Run any seed research you requested

All changes are visible as plain Markdown. You own everything. Edit any file anytime.

---

## After setup

Here's what you can do:

| Say this | What happens |
|---|---|
| "Research [topic]" | Agent researches and builds wiki articles |
| "What do you know about X?" | Agent answers from its knowledge base |
| "Health check" | Agent audits the wiki for gaps and issues |
| "Daily brief" | Summary of today's notes and active projects |
| "Weekly digest" | Week-in-review output |
| "Graduate [file]" | Move agent content into your personal vault |

Your agent's workspace is `_agent/`. It won't touch your personal folders unless you ask.

---

*This file can be deleted after setup is complete.*
