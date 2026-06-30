---
name: cheatsheet-builder
description: "Compress a topic or whole cluster into dense, hand-writable, exam-ready cheat-sheet content: the load-bearing formula, one minimal worked example, the key diagram in words, and the trap distinctions between look-alike concepts. Use whenever the user wants to build, draft, condense, or plan a cheat sheet, formula sheet, summary sheet, or crib notes — e.g. 'make me a cheat sheet for X', 'what should go on my cheat sheet', 'condense this cluster'. Especially apt when a handwritten aid is allowed and there is a page budget. Grounds everything in the user's own course materials."
---

# Cheat-Sheet Builder

## Why this skill exists

When a handwritten aid is allowed, **building the sheet is the studying** — the
act of deciding what is load-bearing, compressing it, and hand-copying it is
heavy active processing and a memory-encoding event in its own right. A good
sheet is therefore not a transcript of the notes; it's the *minimal* set of
triggers that lets the learner reconstruct everything else. The goal of this
skill is ruthless compression toward what's high-yield and easy to forget, not
coverage.

## What goes on the sheet (and what doesn't)

Include, per concept:

- **The one load-bearing formula**, with every symbol that isn't obvious named in
  three words or fewer.
- **One minimal worked example** — the smallest instance that shows the mechanic
  (a $2\times2$ shift matrix, a 3-node message-passing step), not a full problem.
- **The key picture in words** — what to sketch and what the axes/regions mean
  (e.g. "double-descent: test error dips, rises to a spike at the interpolation
  threshold, then descends again").
- **The trap line** — the one-sentence distinction from the concept it's most
  confused with ("approximation error shrinks under symmetry; estimation error
  can still suffer the curse").

Leave **off** the sheet:

- Anything the learner already knows cold (wasted space — verify this with them).
- Long derivations (keep the result + the one trick that unlocks it).
- Prose. The sheet is symbols, mini-diagrams, and trap lines, not sentences.

## Method

1. **Scope it.** Confirm the topic/cluster and the page budget. Pull the real
   content from project/course knowledge so notation matches the exam.
2. **Sort by yield and forgettability.** Put high-yield, easy-to-forget items
   first; drop or shrink anything already mastered. Ask the learner what they
   already know so you don't spend the budget on it.
3. **Compress each item** into the four-part block above. Push for the *shortest*
   form that still triggers full recall.
4. **Budget-check.** Estimate density against the page limit and flag what to cut
   if it's over. A cramped, complete sheet beats a tidy, partial one — but legible
   under time pressure matters, so don't over-pack.
5. **Recommend hand-copying.** Output is a draft to **write out by hand**, not
   print — the copying is where a lot of the encoding happens. Say so.

## Output format

Produce a compact, scannable draft the learner can transcribe. Organise by
cluster, and within each cluster use this block per concept:

```
### [concept]
Formula:  $[the load-bearing expression]$   (symbols: a = …, b = …)
Example:  [smallest instance, one line]
Picture:  [what to sketch + what it means]
Trap:     [one-line distinction from the look-alike concept]
```

Keep it tight. Use LaTeX for every formula, in `$...$` or `$$...$$`. If the
material spans several clusters and the budget is tight, rank the clusters by
exam weight and compress the low-weight ones hardest.

## Example block

```
### Discrete convolution on a 1-D grid
Formula:  circulant $C$ diagonalised by DFT: $C = F^{-1}\,\mathrm{diag}(\hat c)\,F$
          [F = DFT matrix, $\hat c$ = DFT of the filter]
Example:  shift-by-1 = circulant with a single off-diagonal of 1s (cyclic)
Picture:  filter slides over signal; in Fourier domain it's pointwise multiply
Trap:     circulant (cyclic, → DFT) vs Toeplitz (non-cyclic, no clean DFT diag)
```
