### 2. **CPEX 50 — One Decision Required** (Scot)

Review feedback on CPEX-50 has been received and folded into the draft. It was substantive rather than editorial: the reviewer's central objection — that CGNS is not ambiguous today, because `GridLocation_t` plus the SIDS `DataSize` rules already fix the DOF layout in every legal encoding — was accepted, and the proposal has been **re-motivated on expressiveness rather than ambiguity** and narrowed accordingly. The finite-volume, HDG, FSI and conjugate-heat-transfer motivations were withdrawn along with their examples, since in each of those cases the layout is already determined. The reviewer has since agreed the remaining gap is real and asked for exactly this narrowed revision.

Status: **pending Steering Committee vote** on all three tracks (SIDS, Filemap, MLL). Nothing has been implemented and no file has been written with either enumeration. Target release is **CGNS 5.0, jointly with CPEX-45**; no claim of earlier availability is made.

Three questions that earlier drafts of this agenda item put to the Committee have since been settled against the existing standard and the library source, and are recorded below as determinations rather than decisions. **One genuine decision remains**, because it is a question about how the standard should be organised and cannot be resolved from evidence.

#### D-01. Should the `Vertex` encoding live in CPEX-50, or be folded into CPEX-45?

The proposal closes one gap: element-local solution DOFs at positions coinciding with shared mesh vertices, with the shared-vertex grid retained. The evidenced need is a DG solver in production that currently writes **duplicate grid coordinates** for geometrically shared nodes so that grid and solution extents match and existing readers accept the file — inflating `GridCoordinates_t` by the average vertex valence and destroying the connectivity that mesh walking depends on.

On capability, CPEX-45's `InterpolationPoints` also satisfies this requirement; the grid is untouched either way. What the `Vertex` encoding offers is a smaller reader-side burden where the DOF positions simply *are* the mesh vertices — no `Family_t`-level `SolutionInterpolation_t` lookup, no basis evaluation, no control-point machinery. For first-order DG that is the difference between reading one additional scalar node and implementing an interpolation framework, and it is third-party reader implementors, not solver authors, who asked for it.

The consequence either way is a redundancy: for discontinuous data with p ≤ 4 on a Lagrange basis there will be two conforming encodings of the same field. The cost falls on readers, who must support both to interpret all conforming files. Tolerating alternative encodings is long-standing CGNS practice, but it should be accepted knowingly rather than by default.

1. **Keep it in CPEX-50**, with CPEX-45 recommended wherever available. The `Vertex` encoding is documented as the lower-adoption-cost path, not the preferred one, and a reader implementing only CPEX-45 is never *wrong* — merely unable to read files that chose the other encoding, and able to say so precisely, because the `DofStorage` node makes the choice explicit rather than leaving it to be inferred. *(draft placeholder)*
2. **Fold the ordering rule into CPEX-45** as an alternative encoding there. One proposal, one place to look, at the cost of enlarging CPEX-45 late in its review and coupling two schedules that are currently only aligned.
3. **Decline the `Vertex` encoding** and require CPEX-45. Removes the redundancy, and with it the low-cost path the requesters asked for; the duplicate-coordinate workaround presumably continues.

#### Determinations — recorded for confirmation, no vote sought

**Enumeration value names: `SharedDofs` / `IndependentDofs` and `ContinuousInterface` / `DiscontinuousInterface`.** An earlier draft proposed type-stem prefixes (`DofStorageShared`) on the grounds that `BCType_t` sets a precedent and that bare adjectives risk colliding in `cgnslib.h`'s global namespace. Both premises fail on inspection:

- **No CGNS enumeration prefixes its values with its type stem** — 0 of 27 in `cgnslib.h`. `BCType_t`'s values carry `BC`, a *domain* prefix, not `BCType`; and `BCDataType_t` in the same family is bare (`Dirichlet`, `Neumann`).
- **The collision concern is already solved.** Defining `CGNS_SCOPE_ENUMS` makes `CGNS_ENUMV(e)` expand to `CG_e` for every CGNS enumeration value. A prefix in this proposal would reinvent an existing mechanism, and would do so on disk as well, since the stored token follows the identifier.
- CGNS already ships equally generic bare values — `Linear`, `Constant`, `Generic`, `Ideal`, `Structured` — so a bare adjective is not itself disqualifying.
- Where CGNS wants specificity it uses **compound descriptive names**: `CellCenter`, `TimeAccurate`, `ConstantRate`, `NonDeformingGrid`. The last is exact precedent for the mild redundancy in `DofStorage = SharedDofs`.

The compound names above are therefore idiomatic, carry no type-stem prefix, are specific enough that the collision question does not arise, and collide with nothing in `cgnslib.h` today.

**`Null` on write is rejected, and `cg_delete_node` removes the child.** An earlier draft proposed that writing `DofStorageNull` delete an existing child. No `cg_*_write` in the MLL behaves that way, so this would have been a new convention needing its own justification. It is unnecessary: `cg_delete_node(const char *)` already removes an optional child at the current `cg_goto` position in `CG_MODE_MODIFY`, and neither new node is on its list of undeletable nodes. Writing `Null` is therefore rejected with `CG_ERROR`, exactly as `cgi_check_location` rejects `GridLocationNull` under `FlowSolution_t`, `DiscreteData_t` and `BC_t`. "Unspecified" is expressed by not writing the node. Readers must still accept the string `"Null"`, since a hand-built or third-party file may contain it.

**The second attribute's scope is the ballot, not a separate question.** Whether `InterfaceContinuity_t` belongs in CPEX-50 is decided by voting **B-2** up or down; it needs no prior decision item.

#### Ballot items (`[NEW]` — require a vote)

- **B-1** — `DofStorage_t` enumeration and its optional `DofStorage` child on `FlowSolution_t`, `DiscreteData_t`, `ZoneSubRegion_t` and `UserDefinedData_t`.
- **B-2** — `InterfaceContinuity_t` enumeration and node, on the same four parents. Records whether duplicated DOFs agree by construction — the one property no other CGNS metadata supplies.
- **B-3** — SIDS amendment: `PointList` semantics for independent DOFs at `GridLocation_t = Vertex`, including the DOF ordering rule and its restrictions (unstructured only, full element coverage, `NFACE_n` excluded, not combinable with `Rind_t`). **This is the load-bearing normative addition**; D-01 decides where it lives.
- **B-4** — SIDS structural changes: two new Chapter 4 sections and the four parent-node amendments, with Chapter 12 renumbering coordinated with CPEX-45 (see below).
- **B-5** — Mid-Level Library API: ten public entry points (two read/write pairs, their Fortran bindings, two name helpers).
- **B-6** — File Mapping: two node descriptions and the four affected figures.
- **B-7** — Recommended `cgnscheck` validation rules, including the optional and off-by-default numerical sampling check for asserted continuity.

#### For information — no decision needed

- **The gap is evidenced, not theoretical.** Beyond the DG solver above, the same duplicate-geometry workaround is reportedly forced by a widely used commercial post-processing format whose high-order support remains restricted to nodal — and therefore continuous — values, and was a principal motivation for CPEX-45. Two unrelated formats exhibiting the same defect suggests a general gap in how solution data is modelled rather than a CGNS-specific oversight.
- **`IndependentDofs` is the only load-bearing value.** `SharedDofs` is confirmatory: wherever it is valid, the sharing it describes is already realised by the `Elements_t` connectivity. It is retained for self-description, not because readers require it. Under `InterpolationPoints` it is not merely redundant but unactionable, because CPEX-45 supplies no DOF-to-sub-entity map for user-defined interpolation points — and for the monomial bases the coefficients have no geometric support on any sub-entity at all.
- **SIDS Chapter 12 renumbering must be sequenced with CPEX-45.** CPEX-45 inserts new Sections 12.10 and 12.11, moving `UserDefinedData_t` from 12.10 to 12.12 and `Gravity_t` to 12.13. CPEX-50's citations are given against the current SIDS and must be applied after those insertions. Chapters 4 and 7 are unaffected: CPEX-45 generalises 7.3/7.4 and 7.7/7.8 in place and adds nothing to Chapter 4.
- **A pre-existing SIDS defect, out of scope here.** Chapter 4 is alphabetical with one exception: `DimensionalUnits_t` (4.3) precedes `DimensionalExponents_t` (4.4). The insertion points for the two new sections (4.5 and 4.9) are unaffected. The Committee may wish to note it for separate correction.
- **Registry housekeeping.** The CPEX-50 entry still records the GitHub issue as "to be assigned by the CPEX editors"; the process requires one. The scope line and attachment have been updated to the current title and document.
- **Verification.** The draft has been checked against the CGNS 5.0 development tree — the address-helper pattern, `INVALID_ENUM`, `cgi_GridLocation`'s forward-compatibility degradation, the absence of `GridLocation` handling in `pcgnslib.c`, the string-table convention, every MLL signature used in the examples, and all four parser functions. Examples using `GridLocation_t = InterpolationPoints` presuppose CPEX-45, whose enumerator does not yet exist in the library.
- **Reference implementation** is pending; the test plan is in the document.
