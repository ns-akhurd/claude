---
name: explain
description: Use when user invokes /explain [topic] to produce a terse, nested-list technical breakdown with no filler, no intro, no outro.
---

# explain

## Response Format

Produce two sections, in order:

1. **ASCII diagram** — a compact flow or state diagram capturing the essence of the topic.
2. **Nested list** — terse breakdown as described below.

No intro sentence. No outro sentence.

### ASCII Diagram Rules

- MUST appear first, before the nested list.
- Capture the dominant flow, state machine, or data transformation — whichever best represents the topic.
- Use box-and-arrow style for flows (`-->`, `->`, `=>`), state-machine style for stateful topics, or layered columns for parallel concepts.
- Width ≤ 80 chars. Height ≤ 20 lines.
- Label every node/arrow with the action or condition it represents.
- No filler labels ("step 1", "step 2") — every label names what actually happens.

### Nested List Rules

- Top-level items: major components, stages, or concepts.
- Sub-items: detail, mechanism, or consequence of the parent.
- Every line: exactly one sentence.
- Terse: strip all filler words ("Note that", "It is important to", "In order to", "This means that").
- Vocabulary: high-impact nouns and verbs only; avoid weak verbs (is, has, uses → performs, holds, invokes).
- Depth: go 2–3 levels; stop when further nesting adds no new information.

### Template

```
[ASCII diagram]

- [Component / Stage]
  - [What it does — one sentence.]
  - [Why it matters or what it produces — one sentence.]
    - [Edge case or sub-mechanism — one sentence.]
- [Next component...]
```

## Example — /explain TCP handshake

```
Client                          Server
  |                               |
  |-------- SYN (ISN=x) -------->|
  |                               |
  |<----- SYN-ACK (ISN=y) -------|  ack = x+1
  |                               |
  |-------- ACK (ack=y+1) ------->|
  |                               |
  |<======= ESTABLISHED =========>|
```

- Client sends SYN packet to open a connection.
  - SYN carries the client's initial sequence number (ISN).
- Server replies with SYN-ACK to acknowledge and claim its own ISN.
  - Server increments the client's ISN by 1 in the ACK field.
- Client sends ACK to confirm the server's ISN.
  - Both sides enter ESTABLISHED state and begin data transfer.
- Three-way design prevents half-open connections from blocking resources.
  - Each side must prove reachability before the kernel allocates a socket buffer.
