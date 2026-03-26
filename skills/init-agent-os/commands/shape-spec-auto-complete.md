# Spec Shaping Process (Auto-Complete Mode)

You are helping me shape and plan the scope for a new feature using **autonomous requirement gathering**. This process generates and auto-answers questions using senior architect reasoning, then presents the decisions for review.

This process follows 4 main phases:

**Process overview:**

PHASE 1. Initialize spec
PHASE 2. Generate questions (using spec-shaper logic)
PHASE 3. Auto-answer questions (using spec-auto-completer)
PHASE 4. Inform the user with decision summary

Follow each of these phases IN SEQUENCE:

---

## Multi-Phase Process:

### PHASE 1: Initialize Spec

Use the **spec-initializer** subagent to initialize a new spec.

IF the user has provided a description, provide that to the spec-initializer.

The spec-initializer will provide the path to the dated spec folder (YYYY-MM-DD-spec-name) they've created.

**Store this spec-path for use in subsequent phases.**

---

### PHASE 2: Generate Questions with spec-shaper

After spec-initializer completes, use the **spec-shaper** subagent BUT capture its questions instead of showing them to the user:

**Provide to spec-shaper:**
- The spec folder path from Phase 1

**Special Instructions for spec-shaper:**
- Generate questions as normal (following spec-shaper.md workflow)
- **STOP after generating questions** - do NOT wait for user responses
- Save the questions to `[spec-path]/planning/questions.tmp.md`

The spec-shaper will:
1. Read initialization.md
2. Analyze product context (mission, roadmap, tech-stack)
3. Generate 4-8 targeted questions
4. Include reusability and visual asset questions
5. Save questions to questions.tmp.md

**Do NOT show questions to user** - they go directly to Phase 3.

---

### PHASE 3: Auto-Answer Questions with spec-auto-completer

After spec-shaper completes and questions are saved, use the **spec-auto-completer** subagent:

**Provide to spec-auto-completer:**
- The spec folder path from Phase 1
- Instruction: "Read questions.tmp.md and answer all questions with architect reasoning"

The spec-auto-completer will:
1. Read `[spec-path]/planning/questions.tmp.md`
2. Load product context (mission, roadmap, tech-stack)
3. For each question:
   - Generate 2-3 realistic options
   - Evaluate pros/cons for each option
   - Make clear decision with detailed rationale
4. Save comprehensive answers to `[spec-path]/planning/answers.tmp.md`

---

### PHASE 4: Compile Requirements Document

After spec-auto-completer finishes, YOU (Claude) will compile the final requirements.md:

**4.1 Check for Visual Assets:**
```bash
ls -la [spec-path]/planning/visuals/ 2>/dev/null | grep -E '\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"
```

If files found, analyze them using Read tool.

**4.2 Create requirements.md:**

Combine initialization, questions, auto-completed answers, and visual analysis into:
`[spec-path]/planning/requirements.md`

**Format:**
```markdown
# Spec Requirements: [Spec Name]

## Initial Description
[From initialization.md]

## Requirements Discussion

_Note: Requirements gathered using autonomous architect reasoning. Each decision includes multi-option analysis._

---

### Question 1: [Question text]

#### Options Considered

**Option 1: [Name]**
- **Description:** [Explanation]
- **Pros:** [List]
- **Cons:** [List]
- **Complexity:** [Low/Medium/High]

**Option 2: [Name]**
[Same structure]

#### ✅ Decision: Option [X] - [Name]

**Answer:** [One-paragraph summary]

**Detailed Rationale:**
[Full reasoning including trade-offs, risk mitigation, implementation notes]

---

[Continue for all questions]

---

### Existing Code Reuse

[From reusability question answer]

---

## Visual Assets

### Files Provided:
[Based on bash check in 4.1]

### Visual Insights:
[Design patterns, fidelity level, user flows]

---

## Requirements Summary

### Functional Requirements
[Synthesize from all decisions]

### Key Architecture Decisions
1. **[Category]**: [Decision] - [Why]

### Reusability Opportunities
[From reusability analysis]

### Scope Boundaries
**In Scope:** [Phase 1 features from decisions]
**Out of Scope:** [Future enhancements]

### Technical Considerations
[Key choices and constraints from decisions]
```

**4.3 Clean up temporary files:**
```bash
rm [spec-path]/planning/questions.tmp.md 2>/dev/null
rm [spec-path]/planning/answers.tmp.md 2>/dev/null
```

---

### PHASE 5: Inform User with Decision Summary

After all phases complete, present a comprehensive summary:

```
✅ Spec shaping complete (auto-completed with architect reasoning)!

📋 **Spec:** [spec-name]
📁 **Location:** [spec-path]

🤔 **Questions Analyzed:** [N] questions with multi-option evaluation

🏗️ **Key Architecture Decisions:**

1. **[Category]**: Selected [Option Name]
   - **Why:** [One-line reason]
   - **Trade-off:** [What we're accepting]

[List top 5 most important decisions]

🎨 **Visual Assets:** [Found X files / No files found]

♻️ **Reusability:** [Identified Y similar features / None identified]

💾 **Requirements saved to:** [spec-path]/planning/requirements.md

---

**Next Steps:**

1. **📖 Review:** Open `[spec-path]/planning/requirements.md` to review all architect decisions

2. **✏️ Revise (optional):** If you disagree with any decision, tell me and I'll reconsider

3. **✅ Approve:** If decisions look good, run `/write-spec`
```
