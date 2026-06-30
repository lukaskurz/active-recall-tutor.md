---
name: knowledge-doc-builder
description: "Turn raw, messy course material — lecture notes, slides pasted as text, or transcripts of recordings — into a clean, consistent, exam-ready knowledge document for the project. Use whenever the user provides raw study material and wants it worked into structured notes — e.g. 'turn these notes into a knowledge doc', 'process this transcript', 'clean these slides into study notes', 'work this into the project knowledge'. Produces a deterministically named file so re-running on the same lecture overwrites and improves the same document instead of creating a new one. First stage of the study pipeline that feeds course-mapper and the study skills."
---

# Knowledge-Doc Builder

## Why this skill exists

Raw materials are the wrong shape for studying. Slides are terse and out of
order; handwritten notes are personal shorthand; recording transcripts are the
worst — full of filler, repetition, false starts, and speech-to-text errors,
with formulas mangled into words. A knowledge doc distils all of that into one
consistent, exam-oriented structure. Consistency is the whole point: the
course-mapper and mcq-exam-simulator skills rely on every lecture doc looking the
same, so they can find concepts, formulas, and traps reliably.

## Two rules that override everything

1. **Fidelity — never invent.** Use only what is actually in the provided source.
   Do not add theorems, numbers, definitions, or claims that aren't there, even
   if they'd "fit." Clean noise and reorganise freely, but if the source is
   ambiguous, contradictory, or silent on something important, flag it in the
   "Open gaps" section rather than guessing. A doc the user can trust beats a
   complete-looking one that smuggles in errors.
2. **Deterministic filename — same lecture, same file.** Re-running with improved
   or additional material must overwrite the same document, not spawn a new one.
   So derive the filename from the lecture's identity, never from the date or a
   random token.

## Deterministic naming

Before writing, establish the lecture's stable identity:

- Confirm (or ask for) the lecture number and a canonical title.
- Build the filename as **knowledge_NN_slug.md**:
  - NN = zero-padded two-digit lecture number (e.g. 03).
  - slug = the canonical title, lowercased, spaces to underscores, punctuation
    stripped (e.g. geometric_priors).
- Example: lecture 3, "Geometric Priors" produces knowledge_03_geometric_priors.md.
- Always reuse this exact name on re-runs so the file overwrites in place.
- If a previous version of this file is provided in context, read it first and
  improve it in place — merge the new material in, sharpen what's there, keep
  what's still good. Don't restart from a blank page.

If the user already follows a naming convention in their project (e.g.
exam_ready_lecture_NN_topic.md), match their convention instead — the governing
principle is "same lecture, same filename, every time."

## Process

1. **Fix identity.** Lecture number + canonical title produce the filename (above).
2. **Ingest everything provided.** If multiple sources cover the same lecture
   (slides + transcript + notes), reconcile them. For formulas and definitions,
   trust precise sources (slides, notes) over the transcript; use the transcript
   mainly for the intuition and the connective "why."
3. **De-noise the transcript.** Strip filler, repetition, and false starts.
   Repair obvious speech-to-text corruptions of technical terms only when the
   intended term is unambiguous from context; otherwise flag it.
4. **Reorganise by logic, not by speech order.** Group related ideas; a lecture
   that wandered should read as a clean concept sequence.
5. **Extract into the template** (below): concepts, formulas, examples, traps,
   likely exam questions.
6. **Preserve notation.** Use the course's own symbols and conventions. Render
   all maths in LaTeX (single or double dollar signs).
7. **Mark gaps.** Anything unclear, missing, or that you had to interpret goes in
   "Open gaps / to verify" — explicitly.
8. **Write to the canonical filename**, overwriting any existing version.

## Output format

Always use this exact structure so every lecture doc is consistent:

  # Lecture NN — [Title]
  > Cluster: [which exam cluster this maps to, if known]. Source: [notes / slides / transcript / mix].

  ## Overview
  [one short paragraph: what this lecture is about and why it matters in the course.]

  ## Key concepts
  For each concept:
  ### [concept name]
  - Definition: [precise, from the source]
  - Intuition: [plain-language "why", an analogy if the source gives one]

  ## Core formulas
  For each load-bearing formula:
  - $[formula in LaTeX]$ — [one-line meaning]
    - symbols: $[sym]$ = [3 words max], …

  ## Worked examples
  [the smallest concrete instances present in the source that show the mechanic.]

  ## Common confusions / exam traps
  [look-alike concepts and the one-line distinction between them; subtle
  conditions that are easy to drop. Only those grounded in the material.]

  ## Likely exam questions
  [the questions this lecture most plausibly generates, phrased as an examiner would.]

  ## Open gaps / to verify
  [anything ambiguous, missing, or interpreted — be explicit so it can be checked.]

## After writing

State the filename you wrote and that it overwrites any prior version. If this
lecture's place in the overall course is now clearer, suggest (re)running
course-mapper once enough lecture docs exist.
