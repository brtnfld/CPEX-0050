# Draft email reply — CPEX-0050

**To:** [reviewer]
**Subject:** Re: CPEX-0050 — revised, narrowed, and one question back to you

> Fill in the greeting name. Sign-off assumes Scot. The document link should point at the current
> registry attachment: https://cgns.github.io/current/CPEX.html (CPEX0050 → `CPEX-0050-dof-storage.pdf`)

---

Hi [Name],

Thanks for this — and please don't apologise on any of the three counts.

Your comments were brief because they were precise. Every one landed on something real, and two of
them changed the proposal structurally rather than cosmetically, which is a better return than most
long reviews produce. If anything the register you used is the one I'd ask for: half a sentence that
identifies the right defect is worth considerably more than pages of commentary. The delay didn't
cost anything either — a fast confirmation would have left the document worse than your late
objection did.

On the impression that I took the feedback as destructive: that's fair from what you read, and it's on
my framing rather than on you. The working notes track argument status in deliberately blunt shorthand
to keep triage unambiguous, and read cold that comes across as adversarial. I've adjusted it. No harm
done by reading it, incidentally — I'd rather reviewers see the reasoning than take conclusions on
trust.

**On the central objection, you were right and I've rebuilt the motivation.** CGNS is not ambiguous
today: `GridLocation_t` together with the SIDS `DataSize` rules fixes the DOF layout in every legal
encoding. The document contained its own refutation, which I hadn't noticed — the legacy-interpretation
table is a complete deterministic decision table, and it states that at `Vertex` "the SIDS `DataSize`
formula admitted no other layout at this size." Design Decision 1 then makes your argument verbatim in
order to exclude `BCData_t`. So the case now rests on *expressiveness* — element-local DOFs cannot be
**written** at a shared-entity grid location — and every ambiguity claim is gone, including the
mixed-element-mesh assertion, which was simply wrong.

Everything else I've conceded too, and acted on: the HDG bullet no longer calls trace DOFs globally
shared (you were describing the standard formulation, not a variant, and the text was wrong); the
reference entity set is now stated in the normative definition instead of only in the 0045 interaction
section; the weak-BC inference is deleted, since Nitsche and penalty methods in CG and IGA make weak
imposition thoroughly non-DG-specific; and Design Decision 3 is reconciled with §4.2 on
`InterpolationPoints` + shared storage.

**Your interpolation-points question was the one that changed my own view of the design.** There is no
answer. 0045 states the principal-vertices-first assumption only for `ElementInterpolation_t`;
`SolutionInterpolation_t` has no equivalent clause; `LagrangeControlPointDistribution` explicitly
carries nothing a reader needs in order to interpret the points; and under the monomial bases the
coefficients have no geometric support on any sub-entity at all. So shared storage there is not merely
redundant, it is unactionable — and combined with the rest, the shared value is nowhere load-bearing.
The document now says so outright: `IndependentDofs` is the only value that does work, and its
counterpart is retained for self-description alone.

Consequently the scope is narrowed to one case — element-local DOFs at `GridLocation_t = Vertex` with
the shared-vertex grid retained — and the finite-volume, HDG, FSI and conjugate-heat-transfer
motivations are gone along with their examples, because in each of those the layout is already
determined. Twelve examples became seven.

**On "purely informative" — thank you for reconsidering, and for saying so explicitly.** I've acted on
it: there is now a second, independent attribute recording whether duplicated DOFs agree by
construction. Three limits are deliberate, and each is a place I could have overreached: it records
agreement, not smoothness order, so `C^k` for `k ≥ 1` stays with 0045; it is a writer's assertion the
library does not verify, and the `cgnscheck` sampling check is documented as necessarily partial rather
than authoritative — your interpolation-points point again; and it is vacuous rather than wrong where
no duplication occurs.

**On timing, you judged it correctly and I won't claim otherwise.** I'm developing both proposals
together for CGNS 5.0, so 0050 is not the faster route and that argument is withdrawn. The case rests
on what you already granted: reader-side adoption cost for the subset where the DOF positions simply
*are* the mesh vertices.

I'd put one thing in the other column, though. Joint development is why the redundancy you identified
is manageable rather than merely tolerated — both go through the MLL and `cgnscheck` in one pass, so
they share vocabulary, are validated against one model of DOF storage, and cannot end up describing
the same data in contradictory terms, which is the usual way two overlapping CGNS encodings become
painful for readers. Your framing of the cost is the honest one and it's now stated plainly in the
scope section, with 0045 recommended wherever it is available.

**Two implementation notes, since you'll care as an implementer.** I had given both enumerations
type-stem prefixes (`DofStorageShared`), reasoning that `BCType_t` set a precedent and that bare
`Independent` risked colliding in `cgnslib.h`. Checking the header rather than trusting that: no CGNS
enumeration prefixes its values with its own type stem — none of the twenty-seven; `BCType_t` carries
`BC`, a domain prefix, and its sibling `BCDataType_t` is bare — and the namespace concern is already
answered by `CGNS_SCOPE_ENUMS`. So the values are now `SharedDofs` / `IndependentDofs` and
`ContinuousInterface` / `DiscontinuousInterface`, following the compound-descriptive pattern of
`CellCenter` and `NonDeformingGrid`. Separately, an earlier draft had writing `Null` delete an existing
child; `cg_delete_node` already does that, so writing `Null` is simply rejected, as
`cgi_check_location` already rejects `GridLocationNull`.

Both were on the meeting agenda as questions for the Committee until I checked them, which leaves
CPEX-0050 with one genuine decision instead of four.

**That one is where I'd value your view before 4 August.** It is whether the `Vertex` encoding belongs
in CPEX-0050 at all, or would be better folded into 0045 as an alternative encoding there. You know
0045 better than I do and you're the person most affected either way. My draft keeps it in 0050 with
0045 recommended wherever available, but I hold that lightly — what I'd argue against is leaving the
underlying request unaddressed, since the workaround in the field is materially harmful.

One practical thing: renaming the source is what broke your Overleaf link. I've re-shared the project
so it points at the current file — apologies for the dead end. The current PDF is also on the CPEX
registry page.

Cheers,
Scot
