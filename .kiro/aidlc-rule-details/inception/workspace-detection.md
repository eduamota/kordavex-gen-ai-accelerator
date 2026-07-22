# Workspace Detection

**Purpose**: Determine workspace state and check for existing AI-DLC projects

**Interaction Mode**: Delivery (see common/socratic-interaction.md)

## Step 1: Check for Existing AI-DLC Project

Check if `aidlc-docs/aidlc-state.md` exists:
- **If exists**: Resume from last phase (load context from previous phases)
- **If not exists**: Continue with new project assessment

## Step 2: Scan Workspace for Existing Code

**Determine if workspace has existing code:**
- Scan workspace for source code files (.java, .py, .js, .ts, .jsx, .tsx, .kt, .kts, .scala, .groovy, .go, .rs, .rb, .php, .c, .h, .cpp, .hpp, .cc, .cs, .fs, etc.)
- Check for build files (pom.xml, package.json, build.gradle, etc.)
- Look for project structure indicators
- Identify workspace root directory (NOT aidlc-docs/)

**Record findings:**
```markdown
## Workspace State
- **Existing Code**: [Yes/No]
- **Programming Languages**: [List if found]
- **Build System**: [Maven/Gradle/npm/etc. if found]
- **Project Structure**: [Monolith/Microservices/Library/Empty]
- **Workspace Root**: [Absolute path]
```

## Step 3: Git Repository Setup

**Check if a git repository exists:**
- Look for `.git/` directory in workspace root
- If found, check remote URL with `git remote -v`

**IF no git repository exists (greenfield accelerator)**:
1. Ask the user for the accelerator name (used as repo name)
2. Repository URL follows the convention: `https://github.com/doitintl/<accelerator-name>`
3. Initialize the repository:
   ```bash
   git init
   git remote add origin https://github.com/doitintl/<accelerator-name>.git
   ```
4. Create `.gitignore` with at minimum:
   ```
   .DS_Store
   .env
   .env.*
   ```
5. Create a feature branch for the current work:
   ```bash
   git checkout -b feature/<unit-or-feature-name>
   ```
6. Make initial commit:
   ```bash
   git add .gitignore
   git commit -m "Initial commit: project setup"
   ```

**IF git repository exists**:
- Verify remote points to `https://github.com/doitintl/` org
- If remote is missing or incorrect, ask user to confirm/update
- Create a feature branch for the current work if on `main`:
  ```bash
  git checkout -b feature/<unit-or-feature-name>
  ```
- Record current branch and status

**Branch workflow**: All development happens on feature branches, never directly on `main`. The `aidlc-docs/` directory is committed to the branch so teammates can review design decisions in PRs. On merge, a GitHub Action automatically archives `aidlc-docs/` into `aidlc-docs/archive/<date>-<branch-name>/` to keep `main` clean.

**Record findings in state file:**
```markdown
## Git Repository
- **Repository URL**: https://github.com/doitintl/<accelerator-name>
- **Branch**: [current branch]
- **Status**: [initialized/existing]
```

## Step 4: Determine Next Phase

**IF workspace is empty (no existing code)**:
- Set flag: `brownfield = false`
- Next phase: Requirements Analysis

**IF workspace has existing code**:
- Set flag: `brownfield = true`
- Check for existing reverse engineering artifacts in `aidlc-docs/inception/reverse-engineering/`
- **IF reverse engineering artifacts exist**:
    - Check if artifacts are stale (compare artifact timestamps against codebase's last significant modification)
    - **IF artifacts are current**: Load them, skip to Requirements Analysis
    - **IF artifacts are stale**: Next phase is Reverse Engineering (rerun to refresh artifacts)
    - **IF user explicitly requests rerun**: Next phase is Reverse Engineering regardless of staleness
- **IF no reverse engineering artifacts**: Next phase is Reverse Engineering

## Step 5: Create Initial State File

Create `aidlc-docs/aidlc-state.md`:

```markdown
# AI-DLC State Tracking

## Project Information
- **Project Type**: [Greenfield/Brownfield]
- **Start Date**: [ISO timestamp]
- **Current Stage**: INCEPTION - Workspace Detection

## Workspace State
- **Existing Code**: [Yes/No]
- **Reverse Engineering Needed**: [Yes/No]
- **Workspace Root**: [Absolute path]

## Code Location Rules
- **Application Code**: Workspace root (NEVER in aidlc-docs/)
- **Documentation**: aidlc-docs/ only
- **Structure patterns**: See code-generation.md Critical Rules

## Stage Progress
[Will be populated as workflow progresses]
```

## Step 6: Present Completion Message

**For Brownfield Projects:**
```markdown
# 🔍 Workspace Detection Complete

Workspace analysis findings:
• **Project Type**: Brownfield project
• [AI-generated summary of workspace findings in bullet points]
• **Next Step**: Proceeding to **Reverse Engineering** to analyze existing codebase...
```

**For Greenfield Projects:**
```markdown
# 🔍 Workspace Detection Complete

Workspace analysis findings:
• **Project Type**: Greenfield project
• **Next Step**: Proceeding to **Requirements Analysis**...
```

## Step 7: Automatically Proceed

- **No user approval required** - this is informational only
- Automatically proceed to next phase:
  - **Brownfield**: Reverse Engineering (if no existing artifacts) or Requirements Analysis (if artifacts exist)
  - **Greenfield**: Requirements Analysis
