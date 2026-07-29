# CPEX 0050 — Response to Reviewer (Overleaf round)

> **Status (2026-07-29):** all six comments logged and assessed; nine unconditional corrections
> applied; scope **narrowed** with champion approval; vocabulary swept and the source document
> renamed. Build clean via `make`: 47 pp., no undefined references. Provenance **resolved** — the
> requirement came from private email, is real, and is evidenced by a production workaround.
> Disposition: **narrow, do not withdraw.** The reply is complete and unblocked; the only external
> action outstanding is the CPEX registry entry.

**Document under review**: `CPEX-0050-dof-storage.tex` — renamed from
`CPEX-0050-solution-representation.tex`; builds `CPEX-0050-dof-storage.pdf`

> ⚠️ **Line anchors below predate the narrowing edits** (they refer to v1.1 as reviewed, before ~150
> lines were inserted). Locate passages by section title rather than by line number. Section titles
> and file paths are current.
**Review channel**: Overleaf inline comments + summary e-mail
**Date opened**: 2026-07-29
**Prior round**: `CPEX-0050-review-findings.md` (v1.0 internal review, all IDs addressed in v1.1)

---

## Standing Position

Two comments in, the reviewer's objections converge on a single structural point, and it holds:

**The ambiguity premise is false for conforming files.** `GridLocation_t` together with the SIDS
`DataSize` formula fixes the DOF layout in every legal pre-0050 case. The document's own
[legacy-inference table](CPEX-0050-dof-storage.tex#L1456-L1475) is a complete
deterministic decision table proving it, and `.tex:1461-1463` states outright that at `Vertex`
"the SIDS `DataSize` formula admitted no other layout at this size."

The consequence is that the CPEX must be re-motivated on **expressiveness** (element-local DOFs
cannot be *written* at a shared-entity grid location) rather than **ambiguity** (readers cannot
tell what a file *means*). Miller's "hopelessly confused" observation supports the former, not the
latter. The only ambiguity `DofStorage_t` resolves is the one it introduces itself, by making a
second array sizing legal at `Vertex` — a coherent role for the tag, but a much narrower claim.

Residual defensible scope after all concessions: **element-local DOFs at `GridLocation_t = Vertex`
on the predefined element types (order ≤ 4), without adopting CPEX 0045's `Family_t`-level
`SolutionInterpolation_t` machinery.** This is an adoption-cost argument, not a capability gap —
CPEX 0045 can already express DG at any order, including p ≥ 1 on a linear mesh.

R3 removes HDG, which was the last remaining load-bearing case besides that one. The reviewer is
working through the motivating examples methodically and each falls to the same test: *is the layout
already determined by the grid location, the element set, and the array sizing?* So far, yes in every
case except `Vertex` + `PointList`. A second, independent problem surfaces in R3: **`Shared` and
`Independent` are only well defined relative to a stated reference entity set**, which the enum
definition never states.

R4 shifts the round from motivation to **design**: because 0045 provides no DOF-to-sub-entity map for
user-defined interpolation points, `Shared` is unactionable wherever the connectivity does not
already realize it. Combined with R1–R3, `Shared` is never load-bearing in any regime, and the
two-value enum cannot be defended on semantic grounds — only as explicit self-description of the
legacy default.

**That question is now answered: yes.** See Provenance below. The requirement is attributed and the
current workaround in production — duplicating grid coordinates — is materially worse than anything
this proposal would introduce. So the reviewer's "no real gap" is answerable, and the outcome is a
narrowing rather than a withdrawal. What does *not* survive: the ambiguity premise, `Shared` as a
load-bearing value, and the FV, HDG, FSI and CHT motivations.

---

## Comment Log

| ID | Location | Reviewer's point | Verdict | Action |
|----|----------|------------------|---------|--------|
| R1 | summary e-mail | No actual benefit; CG is impossible beyond order 4 under 0045; grid location already carries DOF-sharing meaning; only new case is DG on a continuous mesh with pre-0045 HO element types, and 0045 covers the need | **Concede in part** | Re-motivate on expressiveness; narrow scope to the `Vertex` + `PointList` case; reframe FV/`CellCenter`/`InterpolationPoints` tagging as optional uniformity, not disambiguation |
| R2 | `.tex:303-309` (Miller prior-art ¶) | The "hopelessly confused" framing does not apply: CG stores at mesh nodes (implicit but clear sharing), FV cell-centered shares nothing (equally explicit); the real gap is DG beyond order 0, which 0045 adds; no major issue today | **Concede** | Replace the paragraph (draft below) and sweep the three dependent passages |
| R3 | `.tex:457-466` (HDG bullet) | (a) HDG flavors with per-face trace DOFs that are discontinuous between faces would not qualify as `Shared`; (b) both flavors are already expressible post-0045 as DG volume data + DG face data, or DG volume data + nodal data | **Concede** | Fix "globally shared" (`.tex:458`); hoist the reference-frame rule from `.tex:1315-1322` into the normative definition; drop HDG as a motivating case |
| R4 | `.tex:1364-1370` (editorial note ¶) | 0045 permits user-defined interpolation points — how would these be mapped to sub-entities (faces/edges/corner vertices) in order to actually share data? | **Concede — no answer exists** | `Shared` is unactionable under `InterpolationPoints`; strengthen the `.tex:1315-1331` prohibition on that ground; correct the orthogonality table (`.tex:1256-1266`) |
| R5 | `.tex:2101-2121` (Design Decision 1) | Weak BCs for an otherwise continuous solution are a valid numerical option; notes the paragraph partly self-addresses this | **Concede (narrow)** | Delete the DG-specific inference at `.tex:2106-2110`; keep the exclusion; note 0047 already covers the hedged case |
| R6 | `.tex:2142-2152` (Design Decision 3) | `InterpolationPoints` + `Shared` is equally meaningless — no way to share data logically assigned to the volume element; sharing is only possible for vertex-based HO interpolants; under `InterpolationPoints` the tag is **purely informative**, since the field may be continuous with shared DOFs even though storage duplicates them | **Concede — and it opens the one reconstruction path** | Complete DD3 (it names only `CellCenter`); resolve DD3 against `.tex:1324-1330`; **decide whether "purely informative" means valuable or droppable — ask him** |
| _pending_ | — | — | — | — |

---

## R1 — "I don't see the actual benefit"

### Assessment

Three sub-claims, all substantially correct:

1. **CG beyond order 4 is impossible.** Structural, not incidental. Shared storage is only
   expressible at `Vertex`, which caps at the predefined types (`BAR_5`, `TRI_15`, `QUAD_25`,
   `HEXA_125`). Beyond that, 0045's `InterpolationPoints` array is a concatenation of per-element
   DOF blocks, so sharing is inexpressible by construction — as
   [`.tex:1311-1331`](CPEX-0050-dof-storage.tex#L1311-L1331) already concedes
   (`Independent` "requires no additional metadata"; `Shared` on a volume block is *invalid*).
2. **Grid location already carries the meaning.** Informative in exactly one configuration:

   | Grid location | Tag informative? |
   |---|---|
   | `CellCenter` | No — one value/entity; `Shared` is *meaningless* at p=0 per the doc |
   | `Vertex`, no point set | No — `DataSize = VertexSize`, so `Independent` is invalid (`.tex:1151-1155`) |
   | `InterpolationPoints` | No — `Independent` is the only valid reading for volume blocks |
   | `IntegrationPoint` | No — `ItgPointsStartOffset` fixes it per element |
   | **`Vertex` + `PointList`** | **Yes — sole case** |

   [Design Decision 1](CPEX-0050-dof-storage.tex#L2101-L2112) makes the reviewer's
   argument verbatim to exclude `BCData_t`: `PointList`/`PointRange` plus `GridLocation_t`
   "already determine the data layout unambiguously."
3. **Only genuinely new case is `Vertex` + `PointList`.** Agreed. And there the tag is not metadata
   *about* a layout — it is the discriminator that makes a new sizing legal. That is the strongest
   thing in the proposal.

### Weak justification to repair

[`.tex:1120-1124`](CPEX-0050-dof-storage.tex#L1120-L1124) claims the `Vertex` +
`PointList` encoding "is the only way to keep `GridLocation_t = Vertex` — and therefore the
shared-vertex connectivity used for geometry operations." This does not hold: `GridCoordinates_t`
and `Elements_t` are untouched by writing the *solution* at `InterpolationPoints`, so stream
tracing and mesh walking still work. The real benefit is adoption cost, and must be argued as such.

---

## R2 — Miller prior-art paragraph

### Assessment

Concede. See Standing Position above. Two further overstatements in the same family:

- [`.tex:255-260`](CPEX-0050-dof-storage.tex#L255-L260): size inference "breaks
  entirely for mixed-element meshes" is **wrong** — `DataSize` at `Vertex` is `VertexSize`
  irrespective of element mix.
- [`.tex:1465-1468`](CPEX-0050-dof-storage.tex#L1465-L1468): a legacy `Vertex` +
  `PointList` is called ambiguous, but pre-0050 there was no ordering rule, so no conforming writer
  could have produced an independent layout. It is a vertex subset. (Private conventions may exist;
  say so explicitly if that is the intent.)

### Drop-in replacement for `.tex:303-309`

```latex
Miller~\cite{miller2003} notes that for piecewise-linear coordinate fields the
dof-relation and the mesh connectivity (topo-relation) are one and the same array,
and are consequently ``hopelessly confused'' in practice.  CGNS today is in exactly
this position: it has no dof-relation layer, so the only dof-map available to a
solution at a shared-entity grid location is the one implied by the
\texttt{Elements\_t} connectivity.  This does not make existing files ambiguous---a
conforming file is unambiguous, because \texttt{GridLocation\_t} together with the
SIDS \texttt{DataSize} formula fixes the layout in every legal case
(Section~\ref{sec:legacy-inference} tabulates them).  The cost is expressiveness:
because the implied dof-map \emph{is} the connectivity, a solution whose DOFs are
element-local cannot be written at \texttt{Vertex}, \texttt{EdgeCenter}, or
\texttt{FaceCenter} at all.  CPEX~0045 supplies an independent per-element dof-map
for \texttt{InterpolationPoints}, and CPEX~0047 does so for \texttt{IntegrationPoint};
both are element-local by construction.  What remains uncovered is element-local
DOFs at \texttt{Vertex} on the predefined element types, where \texttt{DofStorage\_t}
serves as the discriminator that makes a second sizing both legal and
self-describing.
```

### Dependent passages that must move with it

| Location | Problem |
|---|---|
| [`.tex:158`](CPEX-0050-dof-storage.tex#L158) | "fundamental to the correct interpretation of solution data" overclaims; "not captured by any existing CGNS construct" is fine |
| [`.tex:196-200`](CPEX-0050-dof-storage.tex#L196-L200) | "post-processors ... will misinterpret the data dimensions" is circular — they cannot misinterpret a file that cannot be written |
| [`.tex:255-260`](CPEX-0050-dof-storage.tex#L255-L260) | Size-inference bullet; mixed-mesh claim is false |
| [`.tex:2192-2196`](CPEX-0050-dof-storage.tex#L2192-L2196) | Rejected-Alternatives echo of the same bullet |

---

## R3 — HDG trace DOFs and the missing reference frame

### R3(a) — "would this not qualify as Shared?"

**The reviewer is describing standard HDG, not a flavor.** The classical hybridizable formulation
(Cockburn–Gopalakrishnan–Lazarov) takes the trace space as
$M_h = \{\mu \in L^2(\mathcal{E}_h) : \mu|_F \in P_k(F)\ \forall F\}$ — face-wise polynomials with
**no** inter-face continuity. Traces are therefore discontinuous along skeleton edges and vertices
in the mainstream method. [`.tex:458`](CPEX-0050-dof-storage.tex#L458) calls them
"globally shared trace DOFs," which is wrong as written and should be fixed regardless of the
disposition of the rest.

**On the narrow question, the document is self-consistent — but only in a buried subsection.**
[`.tex:1315-1322`](CPEX-0050-dof-storage.tex#L1315-L1322) defines the trace case as:
"each listed interface element's DOF block is shared between the volume elements adjacent to it."
Under *that* rule the reviewer's case is still `Shared`, because the reference entities are the two
adjacent **volume** elements, and skeleton-level continuity is not what is being asserted.

**But the enum definition never states the reference frame,** and under its general wording —
[`.tex:149-153`](CPEX-0050-dof-storage.tex#L149-L153), "a geometric entity (vertex, edge,
or face) that is shared between adjacent elements" — the reviewer's reading is the correct one and
the label is wrong. A face-wise-discontinuous trace field *is* independent with respect to the face
elements at their shared edges and vertices. So the same field is `Shared` w.r.t. volumes and
`Independent` w.r.t. faces:

| Reference entity set | Verdict for a face-wise-discontinuous trace field |
|---|---|
| Volume elements (the `.tex:1315-1322` rule) | `Shared` — both neighbors index the same face block |
| Face elements (the `.tex:149-153` wording) | `Independent` — no sharing at skeleton edges/vertices |

This is a genuine specification defect independent of the value question: **a single enum value per
`FlowSolution_t` node cannot be interpreted without a stated reference entity set.** Minimum fix is
to hoist the reference-frame rule out of `.tex:1315-1322` into the normative enum definition. Note
also that `Shared` on a face-element-indexed block is *automatically* true — a conforming face
`Elements_t` section lists each interior face once, so there is exactly one DOF block per face and
both neighbors necessarily index it. Derivable again.

### R3(b) — "we could specify this today after 0045"

Concede. Both flavors are expressible without this CPEX:

- **Volume DG**: `InterpolationPoints` over volume elements. Pure 0045.
- **Face-wise-discontinuous trace** (standard HDG): `InterpolationPoints` with a `PointList` over
  face-element indices — which is *precisely* the encoding `.tex:1315-1322` prescribes, minus the tag.
- **Continuous trace** (if a code wants it): nodal/skeleton data, order ≤ 4.

The reviewer has therefore removed the proposal's flagship two-value example. This compounds with
[Design Decision 2](CPEX-0050-dof-storage.tex#L2128-L2140), which already instructs HDG
users to write separate `FlowSolution_t` nodes per layout — once they are separate nodes, each one's
layout follows from its own grid location and element set, and the tag adds nothing. The argument is
self-defeating as structured.

Consequence for the document: HDG must be dropped from the motivating cases
([`.tex:278-280`](CPEX-0050-dof-storage.tex#L278-L280),
[`.tex:457-466`](CPEX-0050-dof-storage.tex#L457-L466)) and Example 4
([`.tex:1579`](CPEX-0050-dof-storage.tex#L1579)) demoted or removed. It cannot carry
the "two values are necessary" argument.

---

## R4 — Sub-entity mapping for user-defined interpolation points

**There is no answer, and this is the most serious comment in the round.** R1–R3 attacked the
*motivation*; R4 attacks the *design*. Verified directly against
`CPEX-0045/CPEX-0045-high-order-interpolation.tex`:

**1. `SolutionInterpolation_t` carries no sub-entity ordering guarantee.** 0045 states the
principal-vertices-first assumption only for `ElementInterpolation_t` (geometry, `.tex:1186-1188`:
"It is assumed that the first points correspond to the principal vertices of the corresponding
linear element"). The `SolutionInterpolation_t` node (`.tex:1260-1266`) has no equivalent clause.
Its `LagrangeControlPoints` is a bare `[Dim, NPoints]` array of parametric coordinates in writer
order. Nothing groups the points by corner / edge / face / interior.

**2. `LagrangeControlPointDistribution` explicitly does not help.** 0045 `.tex:1201-1203`: it
"carries no information a reader needs in order to interpret the control points."

**3. For modal bases the question has no meaning at all.** Under `ParametricMonomialsPascal` /
`CartesianMonomialsPascal`, the stored DOFs are monomial coefficients with *no geometric support*
— no DOF sits on a vertex, edge, or face. And 0045 `.tex:1878-1880` states the Pascal traversal
order "is a writer convention; the library does not validate ordering." So there is no entity to
share and no ordering to match.

**4. Even for `ParametricLagrange` with user-defined points, sharing needs two things neither CPEX
provides:** (a) a floating-point predicate to decide which parametric coordinates lie on a boundary
sub-entity (is $u = \pm 1$, within what tolerance?), and (b) an orientation-aware permutation
matching those points as seen from each of the two adjacent elements — the classical high-order
DOF-matching problem. CGNS defines this for the predefined element types; for arbitrary user points
it is undefined.

### Consequence: `Shared` never does any work

This closes a pincer around the `Shared` value:

| Regime | Status of `Shared` |
|---|---|
| `Vertex`, predefined types, order ≤ 4 | Realized by `Elements_t` connectivity — the tag is confirmatory, adds nothing |
| `CellCenter` / p=0 | Meaningless (doc's own words) |
| `InterpolationPoints`, volume block | Already **invalid** per `.tex:1324-1330` |
| `InterpolationPoints`, face block (HDG) | Automatically true, and now also unactionable (R4) |
| `IntegrationPoint` | Independent by construction |

In the one place this CPEX adds capability — `Vertex` + `PointList` — the value written is
`Independent`. **`Shared` is never load-bearing anywhere.** That undercuts
[§Rationale for Two-Value Classification](CPEX-0050-dof-storage.tex#L449) and makes the
[rejection of a boolean flag](CPEX-0050-dof-storage.tex#L2171-L2176) argue the wrong
point: the objection there is that a boolean cannot express "unspecified," but an enum of
`Null` / `UserDefined` / `Independent` expresses that perfectly well without `Shared`. If `Shared`
is retained it must be defended as *explicit self-description of the legacy-equivalent default*,
which is an ergonomics claim, not a semantic one.

### Document corrections required

- [Orthogonality table `.tex:1256-1266`](CPEX-0050-dof-storage.tex#L1256-L1266): the
  row **"Hierarchical $p=2$ → CG (modal)"** is not expressible. Hierarchical CG with edge/face/
  interior modes is real mathematics (Szabó–Babuška), but 0045's monomial encoding carries no
  sub-entity decomposition, so `Shared` cannot be acted on there. The **"Lagrange $p=3$ → CG
  spectral"** row is only valid read as `Vertex`-located `QUAD_16`/`HEXA_64`, yet the table sits
  inside §"Interaction with CPEX 0045", where the doc's own rule makes `Shared` invalid. The table
  presents as orthogonal a pairing that is legal in 2 of 8 cells.
- [`.tex:1324-1330`](CPEX-0050-dof-storage.tex#L1324-L1330): the prohibition on
  `Shared` for volume `InterpolationPoints` blocks is *correct* but justified only on array-sizing
  grounds. Re-justify on the deeper ground: the DOF-to-sub-entity map does not exist.

### On the editorial half of the comment

The `InterpolationPoints` / `IntegrationPoint` naming note needs no action — the reviewer is
flagging, not objecting, and the paragraph already routes it to the 0045/0047 editors.

---

## R5 — Weak BCs on a continuous solution

**Correct, and narrowly fixable — the conclusion survives, the stated reason does not.**

Weak imposition of Dirichlet data is not a DG-only technique: Nitsche's method, penalty methods,
and weakly imposed no-slip in CG FEM and IGA (Bazilevs & Hughes) are all standard, and all pair a
`Shared` solution with element-local (face-quadrature) boundary data. So the inference at
[`.tex:2106-2110`](CPEX-0050-dof-storage.tex#L2106-L2110) —

> In DG methods, boundary conditions are typically applied weakly through numerical fluxes; the
> element-local nature of the boundary data follows from the DOF storage layout on the parent
> `FlowSolution_t` node.

— is a non-sequitur twice over: weak imposition does not imply DG, and BC data layout does not
follow from the parent solution's DOF storage. The two are genuinely independent, which is why the
"future use case" hedge later in the same paragraph is needed at all. Delete or rewrite those two
sentences; the exclusion of `BCData_t` stands on the *first* half of the paragraph alone (sizing via
`PointList`/`PointRange` + `GridLocation_t`).

**Two notes for the redraft:**

1. **The hedge is weaker than it reads.** It promises a possible future CPEX for per-BC DOF storage
   metadata, but weak-BC data at face quadrature points is already expressible under CPEX 0047,
   which permits `IntegrationPoint` under `BC_t` and `BCDataSet_t`, with `ItgPointsStartOffset`
   fixing the per-face layout. So the hedged case is covered and needs no tag. Say that instead of
   promising a CPEX.
2. **Design Decision 1 is doing double duty and should be handled carefully.** Its first half is
   the same argument the reviewer used against the whole proposal in R1 — layout is already
   determined by grid location plus sizing. Post-concession that is the document's *governing
   principle*, not a local carve-out for `BCData_t`. Keep it, promote it, and delete only the DG
   inference. Rewriting the whole paragraph to sound less concessive would be a mistake: it is the
   most honest passage in v1.1.

Minor upside worth one sentence in the reply: this case does confirm that DOF layout is properly a
per-node property rather than a per-zone one, which supports
[Design Decision 2](CPEX-0050-dof-storage.tex#L2128-L2140). It does not create a need
for the tag.

---

## R6 — `InterpolationPoints` + `Shared`, and "purely informative"

Three claims. The first two confirm R4 from the reviewer's side; the third is the most valuable
sentence in the entire review round.

### R6(a) — `InterpolationPoints` + `Shared` is meaningless

Concede; this is R4 reached independently, and the document already agrees at
[`.tex:1324-1330`](CPEX-0050-dof-storage.tex#L1324-L1330) (invalid, `cgnscheck` error).
But **Design Decision 3 is incomplete and contradicts it**: DD3 names only `CellCenter` + `Shared`
as the semantically contradictory case, and says the library "shall not reject such combinations,"
while `.tex:1324-1330` calls `InterpolationPoints` + `Shared` on a volume block outright invalid.
Fix by naming both cases in DD3 and stating plainly that neither is MLL-enforced but both are
`cgnscheck` diagnostics — one a warning, one an error.

### R6(b) — "Sharing is only really possible for vertex-based HO interpolants"

Concede. This is the pincer from R4 stated in one line, and it is now the reviewer's own conclusion
rather than ours. It should be adopted verbatim as the scoping premise of any redraft.

### R6(c) — "The DofStorage is purely informative … the field itself can correspond to continuous data with shared DoF, even if the storage is duplicated in a discontinuous representation (also for continuous FE)"

**This identifies the one piece of genuinely non-derivable metadata in the whole problem space, and
v1.1 explicitly disclaims it.** Compare
[`.tex:153-154`](CPEX-0050-dof-storage.tex#L153-L154):

> This is a statement about data layout only; it makes no claim about the mathematical smoothness of
> the resulting field.

The reviewer is describing precisely the case that disclaimer excludes. Two fields can be
bit-for-bit identical in layout and mean different things:

| | Storage | Field | Derivable from CGNS metadata? |
|---|---|---|---|
| CG spectral element at `InterpolationPoints` | duplicated per element | continuous; duplicates **agree** | — |
| DG at `InterpolationPoints` | duplicated per element | discontinuous; duplicates **differ meaningfully** | — |

Same grid location, same sizing, same 0045 basis, same element set. **Nothing in CGNS — including
v1.1 — distinguishes them.** A post-processor must therefore assume jumps everywhere and can never
safely weld, average, or reconstruct a continuous field; an error estimator cannot tell a physical
jump from a numerically-zero one.

This is the inverse axis from DOF storage, and the two are orthogonal:

- **Storage layout** — shared slots vs. duplicated slots. *Derivable* (R1–R4).
- **Interface consistency** — do duplicated DOFs agree by construction? *Not derivable, and not
  currently expressible.*

It also **rescues the motivations that collapse under the storage reading**: the visualization,
error-estimation, and FSI/coupling arguments of
[Problem Statement items 2–4](CPEX-0050-dof-storage.tex#L201-L221) are circular when the
tag describes storage, but valid when it describes interface consistency — there the post-processor
genuinely cannot tell whether to smooth.

Note the irony for the [Naming History](CPEX-0050-dof-storage.tex#L319): v1.0's
`SolutionContinuity_t` was renamed because readers "consistently understood 'continuity' as a claim
about the mathematical smoothness of the field, which this node does not make." Those readers were
identifying what would have been *useful*. v1.0 had the right subject and the wrong justification;
v1.1 has a defensible subject that is derivable and therefore redundant.

### The critical ambiguity — resolve before replying

"Purely informative" has two opposite readings, and the disposition of the CPEX depends on which
the reviewer means:

1. **"Informative and therefore valuable"** — it carries information no other node carries. Then
   there is a real gap and a defensible v2.
2. **"Informative and therefore droppable"** — not machine-actionable, so it does not earn a SIDS
   node. Then this is the final nail.

**Ask him directly.** This is the single highest-value question in the round and it cannot be
inferred from the comment.

### Candidate v2 architecture (if reading 1)

Two orthogonal attributes, each doing work the other cannot:

1. **Storage discriminator** — `Independent` (+ `Null`, `UserDefined`), *required* only where a
   second array sizing becomes legal, i.e. `Vertex` + `PointList`. Enables the new capability. No
   `Shared` value, per R4.
2. **Interface-consistency attribute** — optional, informative, applicable wherever DOFs are
   duplicated (`InterpolationPoints`, `IntegrationPoint`, `Vertex` + `PointList`). Answers "may I
   weld?" Values along the lines of `C0Consistent` / `Discontinuous` / `Unspecified`.

Honest caveats to carry into the reply: (i) the writer asserts #2 and the library cannot verify it,
though `cgnscheck` could sample duplicated DOFs numerically; (ii) avoid the word "continuity" in the
node name to prevent a repeat of the v1.0 confusion; (iii) this is a *scope change*, presented to a
committee that has just said there is no gap — it needs the reviewer's explicit buy-in before any
redraft, not after.

**This is a synthesis of the reviewer's comment, not his proposal.** Do not attribute it to him.

---

## Provenance: RESOLVED — the requirement is real and attributed

**Source: private email correspondence of April 2026, not GitHub** — one week before the 21 April
registry posting. Raised by implementors of third-party CGNS readers. Specific parties and codes are
deliberately not recorded here or in the proposal; the detail lives in the champion's email thread.

Substance of the report: at least one DG solver in production writes **duplicate grid coordinates**
for geometrically shared nodes, so that grid and solution extents match and existing readers will
accept the file. What is needed is a designator for shared nodes in the grid with independent
solution values at those nodes, the shared grid being what permits mesh walking and stream tracing.

**This answers Q2 affirmatively, and is stronger than a named code — it is a documented workaround in
production.** Coordinate duplication inflates `GridCoordinates_t` by the average vertex valence and
destroys the shared-vertex connectivity. The gap is real, and the constituency is third-party
*readers* — the group that bears reader-side implementation cost, which is what makes an
adoption-cost argument legitimate rather than a convenience plea.

Recorded in the document as new [§2.2 "Evidence from Practice: Grid
Duplication as a Workaround"](CPEX-0050-dof-storage.tex#L229), attributed generically,
with the storage-overhead passage re-argued against it.

It also explains two loose ends: the filename `solution-representation.tex` and finding `m2`'s
four-vocabulary drift both trace to the vocabulary of the original email exchange
(`SolutionRepresentation_t {Continuous, Discontinuous, UserDefined}`).

### Prior search, retained for the record

Searched 2026-07-29 for a GitHub issue or discussion motivating this CPEX. **None found** — which
is consistent with an email origin.

| Query | Issues + PRs | Discussions |
|---|---|---|
| `discontinuous` | 0 | 0 (one fuzzy hit, #803; word absent from body) |
| `Galerkin` | 0 | 0 |
| `continuity`, `solution continuity` | 0 | 0 |
| `DOF`, `DofStorage`, `SolutionContinuity` | 0 | 0 relevant (only #973, an OLCF call announcement) |
| `CPEX0050`, `CPEX 0050` | 0 | — |
| same terms in `CGNS/cgns.github.io` | 0 | — |

Search verified live, not silently failing: `HDF5` → 232 issues, `FaceCenter` → 3 discussions.
[Issue 577](https://github.com/CGNS/CGNS/issues/577), the only issue URL in the document, is
CPEX 0045's tracking issue cited as a bibliography reference — not a report against 0050. The
metadata block still reads "GitHub Issue: to be assigned by the CPEX editors."

**Caveat:** absence of a GitHub record is not absence of a motivation. A steering-committee telecon,
the mailing list, an HDF Group customer request, or correspondence with the 0045/0047 authors would
not appear in any of these searches. The champion is the authority here.

### Adjacent finding — a headwind for the surviving mechanism

[Discussion 963, "FaceCenter full containers"](https://github.com/CGNS/CGNS/discussions/963)
(couletj, 2026-07-02) objects to being forced to write an identity `PointList` for `FaceCenter`
data, calling it "useless indirection" that "can confuse users" and "must be analysed ... which can
be costly in parallel algorithms."

This cuts directly against the one mechanism that survives the review round: the
`Vertex` + `Independent` encoding *requires* a `PointList` duplicating the entire element
connectivity at one `cgsize_t` per DOF. Community sentiment is running toward removing redundant
point-set indirection while this proposal would mandate a much larger instance of it. Expect the
objection; better to pre-empt it than be met with it. Folded into correction #9 below.

---

## Unconditional Document Corrections

**All nine applied 2026-07-29.** Build verified: `latexmk` exit 0, 44 pages, no undefined
references, two sub-1.5 pt overfull hboxes (one pre-existing at `:867`, one negligible at `:2246`).
These were wrong on their own terms, independent of how the CPEX is disposed of.

| # | Location | Correction |
|---|---|---|
| 1 | [`.tex:458`](CPEX-0050-dof-storage.tex#L458) | "globally shared trace DOFs" — standard HDG trace spaces are face-wise with no inter-face continuity. Rewrite. |
| 2 | [`.tex:255-260`](CPEX-0050-dof-storage.tex#L255-L260), [`.tex:2192-2196`](CPEX-0050-dof-storage.tex#L2192-L2196) | "breaks entirely for mixed-element meshes" is false — `DataSize` at `Vertex` is `VertexSize` irrespective of element mix. |
| 3 | [`.tex:2142-2152`](CPEX-0050-dof-storage.tex#L2142-L2152) (DD3) | Names only `CellCenter` + `Shared`; contradicts `.tex:1324-1330`, which makes `InterpolationPoints` + `Shared` invalid. Name both; state neither is MLL-enforced; one `cgnscheck` warning, one error. |
| 4 | [`.tex:1256-1266`](CPEX-0050-dof-storage.tex#L1256-L1266) | Orthogonality table: "Hierarchical p=2 → CG (modal)" is not expressible under 0045's monomial encoding; "Lagrange p=3 → CG spectral" holds only for `Vertex`-located predefined types, contradicting the section it sits in. |
| 5 | [`.tex:2106-2110`](CPEX-0050-dof-storage.tex#L2106-L2110) | Delete the DG inference (R5). Keep the sizing argument. Replace the future-CPEX hedge with a pointer to 0047's `IntegrationPoint` under `BC_t`/`BCDataSet_t`. |
| 6 | [`.tex:149-153`](CPEX-0050-dof-storage.tex#L149-L153) | Enum definition states no reference entity set. Hoist the rule from `.tex:1315-1322` into the normative definition (R3a). |
| 7 | [`.tex:303-309`](CPEX-0050-dof-storage.tex#L303-L309) | Replace with the expressiveness-framed paragraph drafted under R2. |
| 8 | [`.tex:158`](CPEX-0050-dof-storage.tex#L158), [`.tex:196-200`](CPEX-0050-dof-storage.tex#L196-L200) | Drop the ambiguity/misinterpretation framing. |
| 9 | [`.tex:1120-1124`](CPEX-0050-dof-storage.tex#L1120-L1124) | "only way to keep the shared-vertex connectivity" is false — `Elements_t` is untouched by writing the solution at `InterpolationPoints`. Re-argue as adoption cost. |

---

## Draft Reply to Reviewer

> Ready to send. One insert marked **[NAMED CODE]** — fill in or delete per the answer to Q2 below.

Thank you — these are well taken, and I accept the central point. Rather than defend v1.1 as
written, let me say plainly what I think survives and what does not.

**On the core objection.** You are right that CGNS is not ambiguous today. The premise v1.1 rests
on — that a reader cannot determine DOF layout without fragile inference from data dimensions — is
false for conforming files: `GridLocation_t` together with the SIDS `DataSize` formula fixes the
layout in every legal case. The document contains its own refutation, which I had not noticed: the
legacy-interpretation table is a complete deterministic decision table, and it states that at
`Vertex` "the SIDS `DataSize` formula admitted no other layout at this size." Design Decision 1
then makes your argument verbatim in order to exclude `BCData_t`. So the motivation has to be
rebuilt on *expressiveness* — element-local DOFs cannot be **written** at a shared-entity grid
location — not on ambiguity. Miller's "hopelessly confused" observation supports the former and I
was using it for the latter; that paragraph will be rewritten.

**Point by point.**

1. *Order beyond 4.* Agreed, and structurally so: `Shared` is only expressible at `Vertex`, which
   caps at the predefined types, and 0045's per-element concatenation makes sharing inexpressible by
   construction. §9.3 already concedes this; the concession should be in §2, not buried.

2. *Grid location already carries the meaning.* Agreed. Working through the cases, the tag is
   informative in exactly one configuration — `Vertex` with a `PointList`. Everywhere else it is
   confirmatory, meaningless, or already invalid.

3. *HDG traces.* Agreed on both halves, and the bullet you commented on is simply wrong: standard
   HDG trace spaces are face-wise polynomials with no inter-face continuity, so "globally shared" is
   not a description of a variant but a misstatement of the mainstream method. On your narrow
   question: §9.3 does define the reference entities as the two adjacent *volume* elements, under
   which your field is still `Shared` — but the enum definition itself never states a reference
   frame, and under its general wording your reading is the correct one. That is a real defect and I
   will fix it by hoisting the rule into the normative definition. You are also right that both
   flavors are expressible under 0045 today, so HDG can no longer carry the "two values are
   necessary" argument.

4. *User-defined interpolation points.* There is no answer, and this is the comment that changes my
   own view of the proposal. 0045 states the principal-vertices-first assumption only for
   `ElementInterpolation_t`; `SolutionInterpolation_t` has no equivalent clause,
   `LagrangeControlPointDistribution` is explicitly stated to carry no information a reader needs to
   interpret the points, and under the monomial bases the DOFs have no geometric support at all, so
   there is no sub-entity to share. Even for `ParametricLagrange` with user points, sharing would
   need a tolerance-based predicate for "lies on a boundary sub-entity" plus an orientation-aware
   cross-element permutation, neither of which is defined. So `Shared` under `InterpolationPoints`
   is not merely redundant, it is unactionable. Combined with the above, `Shared` is never
   load-bearing anywhere: it is either realized by the `Elements_t` connectivity or it cannot be
   acted on. The two-value classification cannot be defended on semantic grounds.

5. *Weak BCs.* Correct; I am deleting that inference. Weak imposition is not DG-specific — Nitsche
   and penalty methods in CG FEM and IGA are standard — and BC data layout does not follow from the
   parent solution's DOF storage. The exclusion of `BCData_t` stands on the sizing argument alone.
   I will also note that the case I hedged for is already covered by 0047, which permits
   `IntegrationPoint` under `BC_t`/`BCDataSet_t` with `ItgPointsStartOffset` fixing the layout.

6. *`InterpolationPoints` + `Shared`.* Agreed, and you have found an internal inconsistency:
   Design Decision 3 names only `CellCenter` + `Shared` as contradictory and says the library will
   not reject such combinations, while §9.3 calls `InterpolationPoints` + `Shared` outright invalid.
   Both will be named, with the enforcement split stated explicitly.

**What I think is left.** One capability: element-local DOFs at `GridLocation_t = Vertex` on the
predefined element types, keeping the standard connectivity and without adopting 0045's
`Family_t`-level `SolutionInterpolation_t` machinery. I should be honest that this is an
adoption-cost argument, not a capability gap — 0045 can already express DG at any order, including
p ≥ 1 on a linear mesh. If that is worth standardizing it needs a single-valued marker plus the
`PointList` ordering rule, not a two-value classification of DOF storage. That is a substantially
smaller proposal than v1.1.

**Two questions, which between them decide the disposition.**

*First, on "purely informative" — do you mean informative and therefore worth recording, or
informative and therefore not worth a SIDS node?* I ask because your sentence identifies the one
thing I now believe is genuinely not expressible in CGNS: whether duplicated DOFs agree by
construction. A CG spectral-element solution written at `InterpolationPoints` and a DG solution
written at `InterpolationPoints` are indistinguishable — same grid location, same sizing, same
basis, same element set — yet one field is continuous and the other is not. A post-processor must
therefore assume jumps everywhere and can never safely weld or reconstruct; an error estimator
cannot separate a physical jump from a numerically-zero one. That is orthogonal to storage layout
and, unlike storage layout, not derivable. If you think it is worth recording, there is a narrow
proposal there — and, with some irony, it is what v1.0's name was reaching for before it was
renamed for being misleading. If you think it is not machine-actionable enough to earn a node, then
I would rather withdraw this CPEX and let 0045 and 0047 carry the ground they already cover.

*Second — and this is where I do want to hold ground* — the case that remains is not hypothetical.
The requirement was raised by third-party reader implementors, and their report is that there is at
least one DG solver in production which writes **duplicate grid coordinates** for geometrically
shared nodes, so that the grid and solution extents match and existing readers will accept the file.
What they asked for is a designator for exactly one situation: shared nodes in the grid, independent
solution values at those nodes, with the shared grid retained so that mesh walking and stream
tracing still work.

That is worse than the `PointList` redundancy you would rightly object to: duplicating coordinates
inflates `GridCoordinates_t` by the average vertex valence and destroys the connectivity outright. I
have added this as a new §2.2 and re-argued the storage-overhead discussion against it.

I want to be precise about what this does and does not establish, because it does not rescue my
original framing. On capability alone you are right that CPEX 0045's `InterpolationPoints` also
satisfies this requirement — the grid is untouched either way, and I have removed the claim that the
`Vertex` encoding is the only route. What the narrow proposal offers instead is a much smaller
reader-side burden for the case where the DOF positions simply *are* the mesh vertices: no
`Family_t`-level `SolutionInterpolation_t` lookup, no basis evaluation, no control-point machinery.
For first-order DG that is the difference between reading one extra scalar node and implementing an
interpolation framework — and it is third-party readers, not solver authors, who are asking. CPEX
0045 is also not yet part of the standard, so "0045 covers it" is at present a statement about the
target state rather than about what an implementor can rely on today.

So my proposed disposition is to narrow rather than withdraw: keep the `Vertex` plus `PointList`
encoding and its ordering rule, drop the FV, HDG, FSI and CHT motivations, stop claiming the tag
resolves an ambiguity, and be explicit that `Independent` is the only load-bearing value while
`Shared` is retained for self-description alone. If you would still rather see this folded into 0045
as an alternative encoding there, I am open to that — but I do not think the underlying request
should be left unaddressed, since the current workaround in the field is materially harmful.

---

## Disposition: NARROW, not withdraw

Q2 is answered — the requirement is real, attributed, and evidenced by a harmful production
workaround. Withdrawal is off the table. Q1 (the reviewer's "purely informative") remains open and
now determines only whether a *second* attribute is added, not whether the CPEX survives.

| Q1 ("purely informative") | Outcome |
|---|---|
| Droppable | **Narrow**: keep `Vertex` + `PointList` + ordering rule; `Independent` load-bearing, `Shared` retained for self-description only; drop FV/HDG/FSI/CHT motivations and every ambiguity claim |
| Valuable | **Narrow + one addition**: the above, plus an interface-consistency attribute (non-derivable — see R6c) |

### Narrowing — applied 2026-07-29

Champion approved narrowing the scope provided the reporter's need is still met. Build verified after
each step: `latexmk` exit 0, 46 pp., no undefined references.

| # | Change | Location |
|---|---|---|
| 1 | **Abstract reframed.** Dropped the FV-leading and "broadly applicable" framing; now states the specific gap, names `Independent` at `Vertex` + the `PointList` rule as the load-bearing content, and says `Shared` is retained for self-description. | `.tex:157-172` |
| 2 | **§2.2 added** — the field evidence, generically attributed. | `.tex:229` |
| 3 | **§2.4 "Generality Beyond Higher-Order Methods" → "Scope and Non-Goals."** Replaced the breadth argument (which listed FV, HDG, FSI as motivations) with an explicit what-it-closes / what-it-does-not list. Non-goals now name: anything already determined, higher-order DOF identification, field continuity, structured zones / `NFACE_n` / vector-conforming orientation. | `.tex:320` |
| 4 | **Value asymmetry stated.** `Independent` load-bearing, `Shared` confirmatory, with the three honest reasons for keeping it and an explicit note that reader necessity is *not* one of them. | `.tex:515` |
| 5 | **Examples partitioned** into motivating (Ex. 7 `ex:shared-vertex-dg`, plus Ex. 1 and 3 as its counterpart and reader-side dispatch) versus illustrative (the rest), with the illustrative ones explicitly not offered as evidence of necessity. | `.tex:1660` |
| 6 | **`PointList` redundancy pre-empted** in the proposal, weighed against coordinate duplication rather than dismissed. | `.tex:1240-1268` |

### Vocabulary sweep — done 2026-07-29

Finding `m2` described four competing vocabularies in v1.0. **In-document, this was already fixed in
v1.1**; the item had been carried forward without re-verification. Survey of the current source: all
ten `continuity` occurrences are legitimate — the `Prior Title` metadata row, §2.6 Naming History,
the non-goal "field continuity," and genuine mathematical usage in the HDG and penalized-DG bullets.
The one `representation` is "on-disk representation." No stale `*_continuity_*` API names,
`continuity_id` fields, or `repr`/`cont` locals remain. Naming is consistent at 172 `DofStorage` /
41 `dof_storage`.

What *was* stale is the filename, and three names were in play at once:

| Origin | Name |
|---|---|
| Early draft / originating email | `SolutionRepresentation_t` → source file `CPEX-0050-solution-representation.tex` |
| v1.0 | `SolutionContinuity_t` → registry attachment `CPEX-0050-SolutionContinuity.pdf` |
| v1.1 onward | `DofStorage_t`, title "DOF Storage Type" |

Reconciled to the third: `git mv` to **`CPEX-0050-dof-storage.tex`**, `Makefile` `DOCNAME` updated
(and its stale `CPEX-0050-compat-version.tex` header comment fixed), old build artifacts removed,
§2.6 Naming History extended to record all three names and flag the registry action. Verified with
`make`: exit 0, 47 pp.

### Remaining

| # | Item | Note |
|---|---|---|
| 1 | Q1 open — if the reviewer says interface consistency is worth recording, add it as a second attribute (R6c) | Awaiting reply |
| 2 | Optional: delete rather than demote Examples 4, 6, 11, 12 | Would cut ~10 pp.; demotion may suffice |
| 3 | Stale untracked `CPEX-0050-solution-representation.md` (markdown copy, 5 May) | Not touched — champion's call whether to delete |

### Versioning and registry — done 2026-07-29

The proposal has **not been presented**, so the internal v1.0/v1.1/v1.2 numbering was dropped: the
document is now **Version 1**, dated 29 July 2026 (title block, running header, and metadata table).
§2.6 Naming History was rewritten accordingly — it now describes two prior *working names* rather
than published revisions, and explains why traces of each survive.

Registry updated in `/Users/brtnfld/packages/cgns.github.io` (working tree only, **not committed**):

| Field | Was | Now |
|---|---|---|
| Scope | Support Solution Continuity Type in CGNS | Record DOF storage layout: shared or independent |
| Documentation | `CPEX-0050-SolutionContinuity.pdf` | `CPEX-0050-dof-storage.pdf` |
| Date of Last Revision | April.21.26 | July.29.26 |

`proposed_extensions/CPEX-0050-dof-storage.pdf` added (47 pp.). The v1.0-era
`CPEX-0050-SolutionContinuity.pdf` is retained but no longer linked, following the convention used
for CPEX 0042/0043, where superseded PDFs stay in the directory and only the current one is linked.

> ⚠️ **Publishing decision, not yet made.** The registry change makes the narrowed document publicly
> downloadable. The reviewer has not yet received the reply, and Q1 is unresolved. Consider holding
> the `cgns.github.io` commit until the round closes — the scope-line correction is safe in isolation,
> but replacing the linked PDF is the act of publishing. Nothing is committed in either repository.
