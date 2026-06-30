---
name: course-mapper
description: "Analyse a whole subject's materials and devise an exam-oriented study scaffold: the unifying spine of the course, its topics re-clustered by exam relevance and weighted by importance, with per-cluster scope, the key thing to drill, and the distractor-traps. Use whenever the user wants to structure, map, or plan a subject for an exam — e.g. 'build a course map', 'map out this subject', 'what are the exam clusters', 'structure this course for studying'. Prefer this over informally listing topics: the value is the exam-weighted clustering and trap analysis. Produces a single Course_Map.md that future study sessions read first. Works best once per-lecture knowledge docs exist."
---

# Course Mapper

## Why this skill exists

A syllabus lists topics in teaching order; an exam tests them in a different
shape, with different weights, and with predictable traps. Studying from the
syllabus wastes effort on low-yield material and misses the unifying thread that
makes everything cohere. This skill produces the orientation document for the
whole subject — the thing every future study session reads first — built around
how the material is actually examined, not how it was taught.

## The single most valuable input: past/example questions

Before anything else, ask for any past exam, mock exam, or instructor-provided
example-question list. This is the strongest possible signal of what's weighted
and how it's asked — far better than guessing from slide counts. If it exists,
the clustering and weights should be derived primarily from it. If it doesn't,
say so and fall back to the softer signals below, marking weights as estimates.

## What to gather (interview, briefly)

1. **Exam format** — modality (multiple-choice / oral / written / mixed), number
   of questions, time limit, and allowed aids (cheat sheet? calculator?). This
   changes the study strategy materially, so capture it up front.
2. **Past/example questions** — as above.
3. **The materials** — ideally the per-lecture knowledge docs (from
   knowledge-doc-builder); otherwise slides, notes, syllabus. Read them from
   project knowledge.

## Process

1. **Read everything** — knowledge docs and (especially) any example questions.
2. **Find the spine.** Identify the one idea the course keeps returning to — the
   thread that unifies the clusters. State it in a single sentence. Almost every
   well-designed course has one; finding it is the highest-value synthesis step.
3. **Re-cluster by exam relevance.** Group topics into exam clusters, which may
   cut across or merge lectures. Explicitly note which lectures are low-yield /
   barely tested.
4. **Assign weights (High / Med / Low)** from, in priority order: coverage in the
   example questions; emphasis and repetition across materials; explicit
   instructor cues ("this is examinable" / "not on the exam"). State that weights
   are estimates, and give a priority order for a time-pressed learner.
5. **Per cluster, extract three things:** scope (the sub-topics in play), the one
   computation or skill to drill, and the distractor-traps (the look-alike
   concepts that wrong answers exploit).
6. **Look for a reusable per-topic template.** If the subject has a repeating
   structure (e.g. every domain instantiates the same blueprint), capture it as a
   fill-in-the-slots table so the learner can apply it across clusters. If there's
   no such repeating structure, omit this section.
7. **Add the study process** — the retrieval/interleaving loop and which of the
   study skills to use for each phase.
8. **Be honest about uncertainty.** Where a fact, weight, or framing is unclear,
   mark it "to verify" rather than asserting it. Don't invent exam logistics.

## Deterministic output

Write a single file named **Course_Map.md** (one per project/subject). On
re-runs, overwrite and improve it in place — read the existing version first if
present and sharpen it rather than starting over. Never date-stamp or version the
name.

## Output format

Use this exact section structure:

  # [Subject] — Course Map & Study Guidance
  > Purpose: orientation doc for this subject. Read first when starting a study session.

  ## 0. Exam logistics
  [format, number of questions, time, allowed aids, and what that implies for strategy.]

  ## 1. The spine (the one idea everything reduces to)
  [one-sentence unifying thread, then a short unpacking.]

  ## 2. Reusable template
  [include only if the subject has a repeating structure: a fill-in-the-slots
  table the learner applies across clusters; otherwise omit this section.]

  ## 3. The exam clusters (with weights)
  [a table with columns: number, cluster, source lecture(s), weight (High/Med/Low).]
  [note low-yield clusters; give a priority order for short time.]

  ## 4. Per-cluster scope, drill, and traps
  ### Cluster N — [name] (L[x]) · [weight]
  Scope: [sub-topics in play.]
  Drill: [the one computation/skill to be able to do cold.]
  Traps: [look-alike confusions the distractors will target.]
  [repeat per cluster.]

  ## 5. How to study this
  [the retrieval + interleaving + spacing loop; which skill for which phase:
  active-recall-tutor, then mcq-exam-simulator, then cheatsheet-builder, plus any
  existing lecture/flashcard skills.]

  ## 6. Facts distractors will target
  [2 to 5 precise statements worth memorising verbatim.]

## After writing

State that Course_Map.md was written/overwritten, flag anything you marked "to
verify," and point the user at the next step: start a study session per cluster
using the study skills, beginning with the highest-weight clusters.
