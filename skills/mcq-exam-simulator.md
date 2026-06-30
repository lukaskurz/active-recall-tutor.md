---
name: mcq-exam-simulator
description: "Quiz the user with multiple-choice questions that mimic a real exam, using retrieval practice and plausible, misconception-targeting distractors. Use whenever the user wants to be tested, quizzed, drilled, or checked — e.g. 'quiz me on X', 'test me', 'give me practice questions', 'run a mock exam', 'am I ready'. Prefer this over loosely asking questions in chat: it enforces commit-before-reveal and the per-distractor analysis that make practice testing effective. Grounds questions in the user's own course materials and matches the real exam format when known."
---

# MCQ Exam Simulator

## Why this skill exists

Practice testing is one of the two highest-utility study techniques in the
evidence base, and for a multiple-choice exam it does triple duty: it forces
retrieval, it trains the **discrimination** between look-alike options that
distractors exploit, and it rehearses the exact *format* the learner will face.
But it only works if done right — the learner must **commit to an answer before
seeing the solution**, and the debrief must explain *why each wrong option is
wrong*, because the wrong options are where the learning lives. This skill exists
to enforce that discipline instead of casually lobbing questions and revealing
answers too early.

## Question quality: the distractors are the skill

A good MCQ item is defined by its **distractors**, not its stem. Weak distractors
(obviously wrong, off-topic) teach nothing. Strong distractors are *plausible*:
each one should correspond to a **specific, common misconception or error** a
learner who half-knows the material would actually make. Aim for distractors that
are:

- **Factually true but the wrong answer to *this* stem** (tests reading the
  question, not just recognising a true statement).
- **The right idea applied to the wrong object** (e.g. a property of estimation
  error attached to approximation error).
- **A neighbouring concept** that's easy to confuse (circulant vs Toeplitz,
  invariance vs equivariance, WL-can't-distinguish vs WL-can).
- **A classic procedural slip** (off-by-one, dropped normalisation, forgotten
  inverse).

If you can't articulate the misconception a distractor targets, it's a bad
distractor — replace it.

## The loop

1. **Set up.** Ask (once) which topic(s) to cover and, if not already known, the
   real exam's format — number of questions, options per question, whether it's
   single-best-answer, and any time budget. Default to 4 options and
   single-best-answer. Pull the actual content from project/course knowledge so
   questions match the course's notation and emphasis.
2. **Pose ONE question and STOP.** Present the stem and options, then end your
   turn. **Never reveal or hint at the answer in the same message.** The
   learner's choice comes as their next message.
3. **Debrief after they commit.** Once they answer:
   - Say whether they were right.
   - Explain *why the correct option is correct* in one or two lines.
   - Go through **each distractor** and name the specific trap it was testing —
     this is the most valuable part, do not skip it.
   - If they got it wrong, have them re-state the correct reasoning once.
4. **Interleave.** Don't ask all questions on one topic back-to-back. Mix
   clusters so the learner practises *identifying which concept applies* — that
   selection step is half of what the real exam tests.
5. **Track weaknesses.** Keep a running tally of which topics/misconceptions the
   learner misses, and bias later questions toward those.

## Two modes

- **Drill mode (default):** one question at a time with full debrief after each.
  Best for learning. Use this unless asked otherwise.
- **Mock-exam mode:** on request ("full mock", "timed run"), present the full set
  (e.g. 12 questions) at once with the real time budget stated, collect all
  answers, then debrief everything together. Best for calibrating pace and
  stamina near the end of prep.

## Exam-day tactics to reinforce in debriefs

Where natural, point out the transferable test-taking move the question rewards,
so the learner builds the habit:

- **Process of elimination** — strike options known to be wrong first.
- **Extreme modifiers** ("always", "never", "all") are often distractor tells.
- **Plug the option back into the stem** — wrong ones read awkwardly.
- **The true-but-irrelevant trap** — a statement can be correct yet not answer
  the question asked.
- **Time discipline** — if a question would take too long, flag it and move on;
  don't let one item eat the budget.
- **Don't over-switch** — change a committed answer only for a *specific reason*,
  not a vague doubt.

## Formatting

- Use LaTeX for all maths, in `$...$` or `$$...$$`.
- Label options clearly (A/B/C/D). Keep stems unambiguous and self-contained.
- One question per message in drill mode. End the turn after the options.

## Example item (note the engineered distractors)

> **Q.** A graph neural network's message-passing layer matches the
> distinguishing power of the 1-Weisfeiler–Leman test only if its aggregation
> over neighbours is:
>
> A. permutation-**invariant** and **injective**
> B. permutation-invariant but need not be injective
> C. permutation-**equivariant** and injective
> D. a sum, specifically — no other aggregator qualifies
>
> *(end turn — wait for the learner to commit before revealing anything)*

Targets, on debrief: B (forgets injectivity is the binding requirement), C
(swaps invariance for equivariance at the aggregation step), D (true that sum
works, but stated as if it's the *only* option — the requirement is injectivity,
which sum satisfies but isn't unique to). Correct: **A**.
