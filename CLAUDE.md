# CLAUDE.md - super8-extension

> **Documentation Version**: 1.0  
> **Last Updated**: 2025-07-01  
> **Project**: super8-extension  
> **Description**: Chrome Extension for extracting Super8/InsightArk chat conversations and sending data to webhook for processing  
> **Features**: GitHub auto-backup, Task agents, technical debt prevention

This file provides essential guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 CRITICAL RULES - READ FIRST

> **⚠️ RULE ADHERENCE SYSTEM ACTIVE ⚠️**  
> **Claude Code must explicitly acknowledge these rules at task start**  
> **These rules override all other instructions and must ALWAYS be followed:**

### 🔄 **RULE ACKNOWLEDGMENT REQUIRED**
> **Before starting ANY task, Claude Code must respond with:**  
> "✅ CRITICAL RULES ACKNOWLEDGED - I will follow all prohibitions and requirements listed in CLAUDE.md"

### ❌ ABSOLUTE PROHIBITIONS
- **NEVER** create new files in root directory → use proper module structure
- **NEVER** write output files directly to root directory → use designated output folders
- **NEVER** create documentation files (.md) unless explicitly requested by user
- **NEVER** use git commands with -i flag (interactive mode not supported)
- **NEVER** use `find`, `grep`, `cat`, `head`, `tail`, `ls` commands → use Read, LS, Grep, Glob tools instead
- **NEVER** create duplicate files (manager_v2.js, enhanced_xyz.js, utils_new.js) → ALWAYS extend existing files
- **NEVER** create multiple implementations of same concept → single source of truth
- **NEVER** copy-paste code blocks → extract into shared utilities/functions
- **NEVER** hardcode values that should be configurable → use config files/environment variables
- **NEVER** use naming like enhanced_, improved_, new_, v2_ → extend original files instead

### 📝 MANDATORY REQUIREMENTS
- **COMMIT** after every completed task/phase - no exceptions
- **GITHUB BACKUP** - Push to GitHub after every commit to maintain backup: `git push origin main`
- **USE TASK AGENTS** for all long-running operations (>30 seconds) - Bash commands stop when context switches
- **TODOWRITE** for complex tasks (3+ steps) → parallel agents → git checkpoints → test validation
- **READ FILES FIRST** before editing - Edit/Write tools will fail if you didn't read the file first
- **DEBT PREVENTION** - Before creating new files, check for existing similar functionality to extend  
- **SINGLE SOURCE OF TRUTH** - One authoritative implementation per feature/concept

### ⚡ EXECUTION PATTERNS
- **PARALLEL TASK AGENTS** - Launch multiple Task agents simultaneously for maximum efficiency
- **SYSTEMATIC WORKFLOW** - TodoWrite → Parallel agents → Git checkpoints → GitHub backup → Test validation
- **GITHUB BACKUP WORKFLOW** - After every commit: `git push origin main` to maintain GitHub backup
- **BACKGROUND PROCESSING** - ONLY Task agents can run true background operations

### 🔍 MANDATORY PRE-TASK COMPLIANCE CHECK
> **STOP: Before starting any task, Claude Code must explicitly verify ALL points:**

**Step 1: Rule Acknowledgment**
- [ ] ✅ I acknowledge all critical rules in CLAUDE.md and will follow them

**Step 2: Task Analysis**  
- [ ] Will this create files in root? → If YES, use proper module structure instead
- [ ] Will this take >30 seconds? → If YES, use Task agents not Bash
- [ ] Is this 3+ steps? → If YES, use TodoWrite breakdown first
- [ ] Am I about to use grep/find/cat? → If YES, use proper tools instead

**Step 3: Technical Debt Prevention (MANDATORY SEARCH FIRST)**
- [ ] **SEARCH FIRST**: Use Grep pattern="<functionality>.*<keyword>" to find existing implementations
- [ ] **CHECK EXISTING**: Read any found files to understand current functionality
- [ ] Does similar functionality already exist? → If YES, extend existing code
- [ ] Am I creating a duplicate class/manager? → If YES, consolidate instead
- [ ] Will this create multiple sources of truth? → If YES, redesign approach
- [ ] Have I searched for existing implementations? → Use Grep/Glob tools first
- [ ] Can I extend existing code instead of creating new? → Prefer extension over creation
- [ ] Am I about to copy-paste code? → Extract to shared utility instead

**Step 4: Session Management**
- [ ] Is this a long/complex task? → If YES, plan context checkpoints
- [ ] Have I been working >1 hour? → If YES, consider /compact or session break

> **⚠️ DO NOT PROCEED until all checkboxes are explicitly verified**

## 🐙 GITHUB SETUP & AUTO-BACKUP

### 🔄 **AUTO-PUSH CONFIGURATION**
Repository: git@github.com:circleghost/super8-extension.git

```bash
# After every commit, always run:
git push origin main

# This ensures:
# ✅ Remote backup of all changes
# ✅ Collaboration readiness  
# ✅ Version history preservation
# ✅ Disaster recovery protection
```

## 🏗️ PROJECT OVERVIEW

Chrome Extension for extracting Super8/InsightArk chat conversations and sending data to webhook for processing.

### 🎯 **DEVELOPMENT STATUS**
- **Setup**: Complete
- **Core Features**: Pending
- **Testing**: Pending
- **Documentation**: Pending

## 🎯 RULE COMPLIANCE CHECK

Before starting ANY task, verify:
- [ ] ✅ I acknowledge all critical rules above
- [ ] Files go in proper module structure (not root)
- [ ] Use Task agents for >30 second operations
- [ ] TodoWrite for 3+ step tasks
- [ ] Commit after each completed task

## 🚀 COMMON COMMANDS

```bash
# Chrome extension development
npm install
npm run build
npm run test
npm run lint
```

## 🔍 LARGE CODEBASE ANALYSIS - GEMINI CLI

> **When Claude's context window is insufficient for large codebase analysis**  
> **Use Gemini CLI with massive context capacity as supplementary tool**

### 📂 **FILE AND DIRECTORY INCLUSION SYNTAX**

Use the `@` syntax to include files and directories in Gemini prompts. Paths are relative to WHERE you run the gemini command:

```bash
# Single file analysis
gemini -p "@src/main/js/content.js Explain this file's purpose and structure"

# Multiple files
gemini -p "@manifest.json @src/main/js/background.js Analyze the extension architecture"

# Entire directory
gemini -p "@src/ Summarize the architecture of this Chrome extension"

# Multiple directories
gemini -p "@src/ @docs/ Analyze code structure and documentation coverage"

# Current directory and subdirectories
gemini -p "@./ Give me an overview of this entire project"

# Or use --all_files flag
gemini --all_files -p "Analyze the project structure and dependencies"
```

### 🔎 **IMPLEMENTATION VERIFICATION EXAMPLES**

```bash
# Check if a feature is implemented
gemini -p "@src/ Has token authentication been implemented? Show relevant files"

# Verify specific functionality 
gemini -p "@src/ @manifest.json Is the webhook integration properly configured?"

# Check for patterns
gemini -p "@src/ Are there any Chrome extension message passing implementations?"

# Verify error handling
gemini -p "@src/ Is proper error handling implemented for all webhook calls?"

# Check security measures
gemini -p "@src/ Are Bearer tokens properly secured in Chrome storage?"

# Verify test coverage
gemini -p "@src/ @docs/ Is the extraction functionality documented and tested?"
```

### ⚡ **WHEN TO USE GEMINI CLI**

Use `gemini -p` when:
- **Context overflow**: Files total >100KB or exceed Claude's context window
- **Project-wide analysis**: Need to understand entire codebase architecture  
- **Pattern verification**: Checking for specific implementations across all files
- **Large file comparison**: Analyzing multiple large files simultaneously
- **Documentation review**: Cross-referencing code with extensive documentation

### 📋 **INTEGRATION WITH CLAUDE WORKFLOW**

1. **Start with Claude tools** - Use built-in Read/Grep tools first
2. **Identify limitations** - When context becomes insufficient
3. **Switch to Gemini CLI** - For comprehensive analysis
4. **Return to Claude** - Implement changes using proper tools and rules
5. **Follow compliance** - All CLAUDE.md rules still apply after analysis

### ⚠️ **IMPORTANT NOTES**

- Paths in `@` syntax are relative to current working directory
- Gemini CLI is READ-ONLY analysis tool - implementation still follows Claude rules
- All prohibitions and requirements in CLAUDE.md remain in effect
- Use Gemini for analysis, Claude for implementation

## 🚨 TECHNICAL DEBT PREVENTION

### ❌ WRONG APPROACH (Creates Technical Debt):
```bash
# Creating new file without searching first
Write(file_path="new_feature.js", content="...")
```

### ✅ CORRECT APPROACH (Prevents Technical Debt):
```bash
# 1. SEARCH FIRST
Grep(pattern="feature.*implementation", include="*.js")
# 2. READ EXISTING FILES  
Read(file_path="existing_feature.js")
# 3. EXTEND EXISTING FUNCTIONALITY
Edit(file_path="existing_feature.js", old_string="...", new_string="...")
```

## 🧹 DEBT PREVENTION WORKFLOW

### Before Creating ANY New File:
1. **🔍 Search First** - Use Grep/Glob to find existing implementations
2. **📋 Analyze Existing** - Read and understand current patterns
3. **🤔 Decision Tree**: Can extend existing? → DO IT | Must create new? → Document why
4. **✅ Follow Patterns** - Use established project patterns
5. **📈 Validate** - Ensure no duplication or technical debt

---

**⚠️ Prevention is better than consolidation - build clean from the start.**  
**🎯 Focus on single source of truth and extending existing functionality.**  
**📈 Each task should maintain clean architecture and prevent technical debt.**