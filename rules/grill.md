**14.1 Scope** — When `/grill` is invoked, MUST ruthlessly interrogate ALL output produced in the current session (code, plans, documents, configs). NEVER accept anything at face value.

**14.2 Mandatory Read** — MUST read EVERY file created or modified in the session BEFORE grilling. NEVER grill from memory, summaries, or cached context.

**14.3 Six-Lens Interrogation** — MUST apply ALL six question lenses (WHAT, WHY, HOW, WHERE, WHEN, WHICH) to every artifact. NEVER skip a lens. NEVER skip a file.

**14.4 Severity Tagging** — Every finding MUST be tagged: `[CRITICAL]`, `[GAP]`, `[UNCLEAR]`, `[SMELL]`, or `[QUESTION]`. NEVER use softened language. State what is wrong and why.

**14.5 Evidence-Based** — MUST verify every claim against actual code on disk. MUST run commands or read files to confirm. NEVER trust what was "intended."

**14.6 Structured Output** — MUST produce a numbered findings table (`#`, `Severity`, `File/Section`, `Finding`, `Action Required`) and a final verdict: **PASS**, **CONDITIONAL PASS**, or **FAIL** (CRITICAL findings present → FAIL, no exceptions).

**14.7 No Rubber-Stamping** — NEVER say "looks good" without evidence. NEVER skip files. NEVER accept "it should work" — demand proof. If no issues found, look harder.

**14.8 Follow-Up** — MUST surface `[QUESTION]` items directly to the user with pointed questions. NEVER assume answers on behalf of the user.

**14.9 Caveat Propagation Check** — For every limitation or caveat identified anywhere in the document: MUST grep every recommendation, conclusion, and summary section for references to the same concept. NEVER pass if a limitation is flagged in one section while the same concept is recommended without caveat in another. This is `[CRITICAL]`.

**14.10 Stale Rationale Check** — For every explanation that cites a specific number, range, mechanism, or causal reason: MUST verify the explanation is consistent with current computed/measured values in the same document. Any explanation citing a number that does not match current data is `[CRITICAL]`.

**14.11 Validation Section Self-Verification** — For every claim, formula, or count in a checklist/validation section: MUST independently verify against actual document or source data — NEVER accept a checklist item without confirming it. For every computed ratio: verify numerator/denominator direction matches the winner stated in adjacent prose. Errors here are `[GAP]` minimum, `[CRITICAL]` if the formula inverts the stated conclusion.
