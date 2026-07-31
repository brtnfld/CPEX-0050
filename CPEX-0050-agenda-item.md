### 2. **CPEX 50 — Decisions Required** (Scot)

Review feedback on CPEX-50 has been received and folded into the draft. It was substantive rather than editorial: the reviewer's central objection — that CGNS is not ambiguous today, because `GridLocation_t` plus the SIDS `DataSize` rules already fix the DOF layout in every legal encoding — was accepted, and the proposal has been **re-motivated on expressiveness rather than ambiguity** and narrowed accordingly. The finite-volume, HDG, FSI and conjugate-heat-transfer motivations were withdrawn along with their examples, since in each of those cases the layout is already determined. The reviewer has since agreed the remaining gap is real and asked for exactly this narrowed revision.

Status: **pending Steering Committee vote** on all three tracks (SIDS, Filemap, MLL). Nothing has been implemented and no file has been written with either enumeration, so every name and value below can still be settled purely on what is correct for the standard. Where the draft implements one option, that is a placeholder for self-consistency, not a preference. Target release is **CGNS 5.0, jointly with CPEX-45**; no claim of earlier availability is made.

#### D-01. Prefixed or bare enumeration value names? *(This is a file-format decision, not a source-level one.)*

CGNS writes the enumerator's own name to the file — only `Null` and `UserDefined` are abbreviated — so the choice of identifier is also the choice of on-disk token. Two patterns exist in the SIDS: most enumerations use bare domain nouns (`Vertex`, `Kilogram`), while `BCType_t` prefixes every value (`BCWall`, `BCInflow`) precisely where the bare word would be too generic, and those prefixed names appear on disk unchanged.

1. **Prefix both enumerations** — `DofStorageShared`, `DofStorageIndependent`, `InterfaceContinuous`, `InterfaceDiscontinuous`, in C, Fortran and on disk. Follows `BCType_t`. Bare `Independent` and `Continuous` are words applications and I/O layers commonly define, and `cgnslib.h` injects enumeration values into the global C namespace. *(draft placeholder)*
2. **Bare values** — `Shared`, `Independent`, `Continuous`, `Discontinuous`. Matches the majority style and is less verbose, at the cost of four generic adjectives in a public header.
3. **Prefix one, bare the other** — no principled justification; listed only for completeness.

Best settled now: free today, and a migration path for both the C API and the stored strings at any later point.

#### D-02. Is `InterfaceContinuity_t` in scope for CPEX-50, or a separate CPEX?

The second attribute records what `DofStorage_t` cannot: where storage duplicates DOFs at an interface, whether the copies agree by construction. A continuous spectral-element field written at `InterpolationPoints` and a DG field written there are indistinguishable in CGNS today — same grid location, same sizing, same basis, same element set — yet only the former may be safely welded into a continuous reconstruction. The reviewer initially judged this not worth recording and, on the post-processing argument, reconsidered.

1. **Keep both attributes in CPEX-50** — one implementation pass, one version threshold, and the second attribute reuses the address-helper mechanism the first establishes, costing one helper, one string mapper and one field per structure. *(draft placeholder)*
2. **Split into a separate CPEX** — keeps CPEX-50 minimal and single-purpose, at the cost of two proposals over one mechanism which must then be sequenced.

#### D-03. Adopt the "writing `Null` removes the child" convention?

**No existing `cg_*_write` in the MLL does this.** `cg_gridlocation_write` always creates its node, and `cgi_check_location` rejects `GridLocationNull` outright under `FlowSolution_t`, `DiscreteData_t` and `BC_t`. The convention proposed here is therefore new and needs explicit blessing.

1. **Adopt it** — `Null` means "unspecified", which is exactly what an absent node means, so a node whose data reads `"Null"` is pure redundancy. *(draft placeholder)*
2. **Always write the node**, following `cg_gridlocation_write` — then `"Null"` appears on disk carrying the same meaning as absence, i.e. two encodings of one state.

Under either option readers **must** accept `"Null"` on read, since a hand-built or third-party file may contain it.

#### D-04. Accept the acknowledged redundancy with CPEX-45?

For discontinuous data with p ≤ 4 on a Lagrange basis there will be two conforming encodings: the `Vertex` plus `PointList` encoding defined here, and CPEX-45's `InterpolationPoints`. The cost is borne asymmetrically — writers gain a choice, readers wishing to interpret all conforming files must support both. The reviewer raised this, and accepted it as consistent with long-standing CGNS practice.

1. **Accept, with CPEX-45 recommended wherever available** — the `Vertex` encoding is offered as the lower-adoption-cost path, not the preferred one. A reader implementing only CPEX-45 is never wrong, merely unable to read files that chose the other encoding, and can say so precisely because the node makes the choice explicit. *(draft placeholder)*
2. **Reject the `Vertex` encoding and require CPEX-45** — removes the redundancy, and with it the low-implementation-cost path that third-party reader implementors asked for.
3. **Fold the ordering rule into CPEX-45** as an alternative encoding there, rather than a separate CPEX.

#### Ballot items (`[NEW]` — require a vote)

- **B-1** — `DofStorage_t` enumeration and its optional `DofStorage` child on `FlowSolution_t`, `DiscreteData_t`, `ZoneSubRegion_t` and `UserDefinedData_t`. Value names follow D-01.
- **B-2** — `InterfaceContinuity_t` enumeration and node, on the same four parents. Scope follows D-02.
- **B-3** — SIDS amendment: `PointList` semantics for independent DOFs at `GridLocation_t = Vertex`, including the DOF ordering rule and its restrictions (unstructured only, full element coverage, `NFACE_n` excluded, not combinable with `Rind_t`). This is the load-bearing normative addition.
- **B-4** — SIDS structural changes: two new Chapter 4 sections and the four parent-node amendments, with Chapter 12 renumbering coordinated with CPEX-45 (see below).
- **B-5** — Mid-Level Library API: ten public entry points (two read/write pairs, their Fortran bindings, two name helpers). `Null` semantics follow D-03.
- **B-6** — File Mapping: two node descriptions and the four affected figures.
- **B-7** — Recommended `cgnscheck` validation rules, including the optional and off-by-default numerical sampling check for asserted continuity.

#### For information — no decision needed

- **The gap is evidenced, not theoretical.** Third-party reader implementors report at least one DG solver in production that writes **duplicate grid coordinates** for geometrically shared nodes, so that grid and solution extents match and existing readers accept the file. That inflates `GridCoordinates_t` by the average vertex valence and destroys the shared-vertex connectivity mesh walking depends on. The same workaround is reportedly forced by a widely used commercial post-processing format whose high-order support remains restricted to nodal — and therefore continuous — values, and was a principal motivation for CPEX-45. Two unrelated formats exhibiting the same defect suggests a general gap in how solution data is modelled.
- **`DofStorageIndependent` is the only load-bearing value.** `DofStorageShared` is confirmatory: wherever it is valid, the sharing it describes is already realised by the `Elements_t` connectivity. It is retained for self-description, not because readers require it. Under `InterpolationPoints` it is not merely redundant but unactionable, because CPEX-45 supplies no DOF-to-sub-entity map for user-defined interpolation points — and for the monomial bases the coefficients have no geometric support at all.
- **SIDS Chapter 12 renumbering must be sequenced with CPEX-45.** CPEX-45 inserts new Sections 12.10 and 12.11, moving `UserDefinedData_t` from 12.10 to 12.12 and `Gravity_t` to 12.13. CPEX-50's citations are given against the current SIDS and must be applied after those insertions. Chapters 4 and 7 are unaffected: CPEX-45 generalises 7.3/7.4 and 7.7/7.8 in place and adds nothing to Chapter 4.
- **A pre-existing SIDS defect, out of scope here.** Chapter 4 is ordered alphabetically with one exception: `DimensionalUnits_t` (4.3) precedes `DimensionalExponents_t` (4.4). The insertion points for the two new sections (4.5 and 4.9) are unaffected. The Committee may wish to note it for separate correction.
- **Registry housekeeping.** The CPEX-50 entry still records the GitHub issue as "to be assigned by the CPEX editors"; the process requires one. The scope line and attachment have been updated to the current title and document.
- **Verification.** The draft has been checked against the CGNS 5.0 development tree — the address-helper pattern, `INVALID_ENUM`, `cgi_GridLocation`'s forward-compatibility degradation, the absence of `GridLocation` handling in `pcgnslib.c`, the string-table convention, every MLL signature used in the examples, and all four parser functions. Examples using `GridLocation_t = InterpolationPoints` presuppose CPEX-45, whose enumerator does not yet exist in the library.
- **Reference implementation** is pending; the test plan is in the document.
