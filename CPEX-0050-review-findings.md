# CPEX 0050 Review Findings

> **Status: all findings addressed in document version 1.1** (2026-07-27).
> See the [Resolution Log](#resolution-log-v11) at the end for the disposition of each ID.
> The findings below describe version 1.0 and are retained as the review record.

**Document**: `CPEX-0050-solution-representation.tex` (reviewed at Version 1.0, 1659 lines)
**Date**: 2026-07-27
**Verified against**: `CGNS-develop` (`src/cgnslib.{c,h}`, `src/cgns_internals.c`, `src/cgns_header.h`,
`src/pcgnslib.{c,h}`, `src/tools/cgnscheck.c`), `cgns.github.io` (`source/standard/SIDS/*.rst`,
`source/standard/FMM/nodes.rst`, `source/current/CPEX.rst`), and
`CPEX-0045/CPEX-0045-high-order-interpolation.tex`.

---

## Executive Summary

The proposal is well-motivated and the core idea is sound: the shared-vs-independent DOF-layout
distinction genuinely is not expressible in CGNS today, the two-value classification is correctly
scoped, the ASCI-DMF/SAF prior-art grounding is a real strength, and the SIDS section cross-references
(4.1, 4.5, 7.7, 7.9, 12.4) all check out. Backward compatibility is genuinely additive, and
`cgnscheck` does not flag unknown child labels, so the compatibility claims hold.

Three classes of problem block acceptance as written:

1. **The document misstates CPEX 0045.** `SolutionInterpolation_t` is a child of `Family_t`, not of
   `FlowSolution_t`; the children 0045 adds to `FlowSolution_t` are `InterpolationOrders` and
   `CharacteristicLength`. The amended SIDS block in §5 is therefore wrong, and the interaction with
   0045 — the proposal's main selling point — rests on that error.
2. **The HDG example does not work.** Both cases in Example 4 produce encodings that either fail in
   the MLL (`FaceCenter` in a 3-D zone has no `cgi_datasize` formula) or are undefined under CPEX 0045
   (`InterpolationPoints` with no point set sizes over volume elements). `InterpolationPoints` +
   `Shared` is never given a meaning at all.
3. **The rename to `DofStorage_t` is incomplete.** The normative "Summary of API Additions" table still
   lists twelve `*_continuity_*` functions that appear nowhere else in the document.

Beyond that, the proposed MLL surface (12 new functions plus a node-id field in three internal
structs) departs from the established CGNS pattern for optional scalar metadata children, and adopting
that pattern would cut the API to 4 functions, halve the ABI change, and eliminate one of the
correctness bugs below.

**Recommendation**: revise and resubmit. The concept is ready; the specification is not.

---

## Findings Table

| ID | Location | Area | Severity | Finding | Recommendation |
|----|----------|------|----------|---------|----------------|
| C1 | `.tex:434,457` | Technical Accuracy | **Critical** | The amended `FlowSolution_t` block shows `SolutionInterpolation_t SolutionInterpolation ; (o) (CPEX 0045)` as a child, and line 434 says "the definition below includes the `SolutionInterpolation_t` child introduced by CPEX 0045". In CPEX 0045, `SolutionInterpolation_t` is a child of **`Family_t`** (0045 §12.11); the children it adds to `FlowSolution_t` are `IndexArray_t<1,2,int> InterpolationOrders` and `DataArray_t ... CharacteristicLength`. | Replace the `SolutionInterpolation_t` line with 0045's actual two children, and correct every place that implies `SolutionInterpolation_t` hangs off `FlowSolution_t` (also `:502`, `:519-521`). |
| C2 | `.tex:1132-1139` | Technical Accuracy | **Critical** | Example 4 Case B writes `InterpolationPoints` + `Shared` with **no point set**. Per CPEX 0045, field length is Σ_e N_DOFs(e) over "all zone elements when no `PointRange`/`PointList` is present" — i.e. the zone's volume elements in element order — so a face-trace block sized this way is wrong. More fundamentally, `InterpolationPoints` *is* a concatenation of per-element DOF blocks, an inherently independent layout; the CPEX never defines what `Shared` means under it. | Add a normative rule for `InterpolationPoints` + `Shared` (presumably: the block must carry a `PointList`/`PointRange` of *face*-element indices, and a face Elements_t section must exist), or drop Case B. |
| C3 | `.tex:1124-1130` | Technical Accuracy | **Critical** | Example 4 Case A uses `cg_sol_write(..., FaceCenter, &S_trace)` with no point set. `cgi_datasize()` (`cgns_internals.c`) has no `FaceCenter` formula for `Cdim==3` — it falls through to `cgi_error("Location not yet supported")`. Any `cg_field_write` on this node fails in a 3-D zone. | Use `cg_sol_ptset_write` with `FaceCenter` and a `PointRange`/`PointList` over face-element indices. |
| C4 | `.tex:1609-1620`, `:744` | Technical Accuracy | **Critical** | The normative "Summary of API Additions" table lists 12 functions as `cg_sol_continuity_{read,write}`, `cg_discrete_continuity_*`, `cg_subreg_continuity_*` (+ `_f` variants). None of these names appear anywhere else; §5.4 defines `cg_sol_dof_storage_*` etc. Line 744 has the same stale name in prose. Leftover from the `SolutionContinuity_t` → `DofStorage_t` rename. | Rename all 12 table rows and the `:744` reference to `*_dof_storage_*`. |
| C5 | `.tex:724-736` vs `:830-837` | Technical Accuracy | **Critical** | The tree-parser spec populates only the `continuity` field, never `continuity_id`. In `CG_MODE_MODIFY` on a file that already has the node, `cg_sol_dof_storage_write` then sees `continuity != Null` with `continuity_id == 0`, calls `cgi_delete_node(sol->id, 0)`, and creates a **duplicate** `DofStorage` child. | Either add "store the child's node id in `continuity_id`" to parser step 2, or adopt M1 (the address-helper pattern locates the node by label and needs no stored id). |
| M1 | `.tex:524-652`, `:654-692` | Standards Compliance | **Major** | The proposal invents 12 index-based functions plus a `double` node-id field in three internal structs. Every other optional scalar metadata child in CGNS — `GridLocation`, `DataClass`, `Rind`, `DimensionalUnits`, `Descriptor` — uses a single `cg_goto`-based function pair backed by a `cgi_*_address(local_mode, &ier)` helper that whitelists parent labels and, in MODIFY mode, finds the existing node **by label** (`cgi_get_nodes(parent_id, "GridLocation_t", ...)`) and deletes it (`cgns_internals.c:13194`). The document itself uses this pattern in Example 8 (`cg_goto` + `cg_gridlocation_write`), which makes the inconsistency conspicuous. | Propose `cg_dof_storage_read/write(type)` + `cgi_dof_storage_address()`. Cuts 12 functions to 4, removes `continuity_id` (ABI change becomes one field, not two), eliminates C5, and extends free to `UserDefinedData_t`, `BCDataSet_t`, `GridConnectivity_t`, etc. |
| M2 | `.tex:854-860` | Technical Accuracy | **Major** | "This follows the pattern used by other optional child nodes in the MLL (e.g., `GridLocation` tracking via `location_id` fields in some internal paths)." No `location_id` exists anywhere in CGNS: `grep -rn location_id src/` returns nothing, and `cgns_sol` (`cgns_header.h:694`) has `location` but no id field. The cited precedent does not exist. | Delete the claim, or replace it with the real mechanism (`cgi_location_address` + `cgi_get_nodes` by label). |
| M3 | `.tex:1474-1504` | Standards Compliance | **Major** | The CPEX process requires the filemap description "following the prescription given in existing Node Description Documentation". The canonical FMM template (`FMM/nodes.rst`, `GridLocation_t`) is **Name, Label, DataType, Dimension, Dimension Values, Data, Children, Cardinality**. The CPEX table has 6 rows and omits `Children: None` and `Cardinality: 0,1`; row labels also deviate ("Data type", "Dimension value"). | Match the canonical 8-row template verbatim, and state which File Mapping figures change (`FlowSolution_t`, `DiscreteData_t`, `ZoneSubRegion_t`). |
| M4 | `.tex:917-936`, `:1459-1467` | Technical Accuracy | **Major** | The `PointList` ordering covenant is under-specified in five ways. (a) "ascending `Elements_t` section index order" ≠ element order: element numbering is global via each section's `ElementRange`, and sections need not be stored in ascending `ElementRange` order. (b) `MIXED` sections interleave an element-type code before each element's vertex list; the text must say type codes are not DOF entries. (c) "extends naturally to ... `NFACE_n`" does not hold — `NFACE_n` elements are defined by *face* indices, so no canonical per-element vertex list exists. (d) Undefined when the `PointList` covers only a subset of elements. (e) Interaction with `Rind_t` is unstated: §6.2 says the label covers rind entries but never says where rind DOFs sit in the ordering. | Re-anchor on **ascending element index (`ElementRange`)**; specify `MIXED` explicitly; scope `NFACE_n` out or define the derivation; require the `PointList` to cover all elements or define the subset anchor; specify or forbid `Rind` + `PointList`. Also acknowledge the cost: the `PointList` is fully redundant with the connectivity (exactly Miller's "hopelessly confused" observation the CPEX cites) at one `cgsize_t` per DOF. |
| M5 | `.tex:863-945` | Completeness | **Major** | The `Vertex` + `Independent` + `PointList` mechanism is defined entirely in terms of `Elements_t`, which structured zones do not have. `Independent` at `Vertex` in a structured zone has no encoding, and the document never says so. | State that the pattern is unstructured-only, and say what structured DG/FV data should do. Note that 0045's `InterpolationOrders` is itself "recognized only for Unstructured zones", so `InterpolationPoints` is not a structured fallback either. |
| M6 | `.tex:895-898` | Completeness | **Major** | Non-vertex element-local DOFs are routed to `GridLocation_t = InterpolationPoints`, but CPEX 0045 states it "is valid only on `FlowSolution_t` nodes. `ArbitraryGridMotion_t` and `DiscreteData_t` nodes must not use this location." So for the `DiscreteData_t` and `ZoneSubRegion_t` parents this CPEX adds, the prescribed encoding is unavailable. | Restrict the guidance to `FlowSolution_t` and state the gap for the other two parents explicitly. |
| M7 | `.tex:1039-1045` | Technical Accuracy | **Major** | "identical to how `GridLocation` is handled in the parallel MLL" — `GridLocation` is not handled in the parallel MLL at all; `grep -n GridLocation src/pcgnslib.c` returns nothing. It is written by the serial MLL, which under parallel HDF5 must be called collectively. The conclusion (no new `cgp_*` variants) is right; the justification is not, and the actual constraint is missing. | Replace with the normative requirement: all ranks must call the write collectively with identical arguments, because HDF5 structural modification — including the `cgi_delete_node` + `cgi_new_node` overwrite path — is collective under MPI-IO. |
| M8 | `.tex:358-371` | Technical Accuracy | **Major** | Labelling Raviart–Thomas / Nédélec DOFs `Shared` is defensible as a storage statement, but H(div)/H(curl) DOFs carry a per-element **orientation/sign** convention (outward normal, tangent direction). A reader told only "Shared" will interpolate or average them as scalar nodal values and get wrong results — the exact failure mode the CPEX exists to prevent. | Either scope H(div)/H(curl) out of v1.0, or state explicitly that orientation metadata is out of scope and that `Shared` on vector-conforming spaces must not be consumed as nodal values. |
| M9 | `.tex:1017-1020` vs `:1325-1329` | Clarity | **Major** | The legacy default is self-contradictory. §7 says absent = `Null` = unspecified; Example 10 comments "assume continuous for backward compatibility"; the Abstract asserts most CFD is FV, i.e. *independent*. Readers get three different answers. | Give one normative legacy-inference rule, e.g.: `CellCenter` → treat as `Independent`; `Vertex` with `DataSize == VertexSize` → `Shared`; otherwise unspecified. |
| m1 | `.tex:621-651,666-692,727-733,764,818-856` | Clarity | Minor | Internal field names `continuity`/`continuity_id`, the Fortran dummy argument `continuity`, and the example locals `repr`/`cont` all survive the rename. | Rename to `dof_storage`/`dof_storage_id` and `dofStorage` throughout. |
| m2 | throughout (80 hits) | Clarity | Minor | Four vocabularies coexist: "continuity", "solution continuity", "representation", "DOF storage". The §5.4 doc comments still read "Write the solution continuity for a `FlowSolution_t` node." The filename is still `solution-representation.tex`. | Pick one term and sweep. |
| m3 | `.tex:118-129` | Traceability | Minor | Registry mismatch. `cgns.github.io/source/current/CPEX.rst:64` records CPEX0050 as Scope "Support Solution Continuity Type in CGNS", doc `CPEX-0050-SolutionContinuity.pdf`, Date First Posted April.21.26, status "proposal under review". This draft says GitHub Issue "TBD", Date First Posted `\today` (changes every build), status "proposed". | Fix `\today` → literal date; fill in the GitHub issue (the process requires one); plan the registry Scope/filename update for the rename. |
| m4 | `.tex:1629-1657` | Standards Compliance | Minor | Only `miller2003` is cited. `cgns-sids`, `cgns-mll`, `cpex0045`, `hesthaven2008`, `cockburn2000` never appear in a `\cite` — CPEX 0045 is referenced ~20 times in prose but never cited. | Cite each at first mention. |
| m5 | `.tex:336`, `:598` | Clarity | Minor | `cg_DofStorageName` is declared twice. | Keep the §5.4 declaration; drop it from the enum listing. |
| m6 | `.tex:1588-1590` | Technical Accuracy | Minor | The recommended `cgnscheck` rule "value outside the range [0, `NofValidDofStorage`)" is framed against the in-memory enum, but the file stores a **C1 string**; an out-of-range integer is not representable on disk. | Restate as "`DofStorage` node data is not one of `Null`/`UserDefined`/`Shared`/`Independent`". Add a rule for `DofStorageUserDefined` present without the prescribed `DofStorageDescription` descriptor. |
| m7 | `.tex:1440-1444` | Completeness | Minor | SIDS Impact item 1 says only "Section 4". Chapter 4 is alphabetical (4.1 `DataClass_t` … 4.4 `DimensionalExponents_t`, 4.5 `GridLocation_t` … 4.8 `Rind_t`), so `DofStorage_t` becomes **4.5** and renumbers 4.5–4.8. | Name the insertion point and the renumbering. (Verified: 4.1, 4.5, 7.7, 7.9, 12.4 as cited are all correct.) |
| m8 | `.tex:347-356` | Completeness | Minor | The `DofStorageUserDefined` escape hatch prescribes a `DofStorageDescription` `Descriptor_t` in prose only: no filemap row, no API, and Example 3's `default:` branch ignores it. | Add a filemap row and handle it in Example 3, or downgrade to a non-normative note. |
| m9 | `.tex:327-328` | Standards Compliance | Minor | `Shared` and `Independent` are bare identifiers injected into the global namespace by `cgnslib.h`. Existing bare CGNS enum values are domain-specific nouns (`Vertex`, `CellCenter`, `Kilogram`, `Structured`); `Independent` in particular is a word applications and I/O layers commonly define. No collision exists in `cgnslib.h` today. | Consider `DofStorageShared`/`DofStorageIndependent`, or at least note the collision risk for the committee. |
| m10 | `.tex:324-329` | Style | Minor | The enum listing's `=` columns are misaligned; CGNS's own enum blocks are column-aligned. | Align. |
| m11 | `.tex:310-318` | Completeness | Minor | `UserDefinedData_t` is not among the proposed parents, though `cgi_location_address` already accepts it for `GridLocation_t` and it is the standard generic extension point. | Add it — free if M1 is adopted. |
| m12 | `.tex:1201` | Reproducibility | Minor | `cgsize_t point_list[nElems * nVertsPerElem];` is a C99 VLA with a potentially very large stack footprint, and VLAs are unavailable in C89/MSVC. `nElems`, `nVertsPerElem`, `element_connectivity` are undeclared. | Use `malloc`/`free` and declare the inputs. |
| m13 | `.tex:1079,1137,1359` | Clarity | Minor | `cg_sol_interpolation_order_write(fn,B,Z,S,3,0)` — the trailing args are `spatialOrder, temporalOrder` (verified against CPEX 0045 Table `tab:sol-api`), but the document never says so. | Add `/* spatialOrder=3, temporalOrder=0 */`. |
| m14 | `.tex:1280,1411` | Reproducibility | Minor | Examples 9 and 12 use a bare `CellDimension` as if it were a variable; the comment explains the intent but the snippet will not compile. | Introduce `int cellDim;` via `cg_base_read`. |
| m15 | `.tex:751-767` | Clarity | Minor | The listing uses the file-scope global `cg` without declaring it — correct inside `cgnslib.c`, confusing in isolation. | Add a one-line comment. |
| m16 | `.tex:804-814` | Standards Compliance | Minor | Enum validation is an open-coded `switch`; CGNS provides `INVALID_ENUM(E,EMAX)` (`cgns_header.h:119`) and uses it in `cg_gridlocation_write`. | Use `INVALID_ENUM(type, NofValidDofStorage)`. |
| m17 | `.tex:124-125` | Traceability | Minor | No test plan, no reference implementation, `Reference Impl.` and `Target Release` are `TBD`, and no minimum CGNS library version is stated. (The CPEX 0045 review raised the same gap as F13.) | Add a short test-plan subsection and a "supported from CGNS version X.Y" note. |
| m18 | build | Style | Minor | 6 overfull hboxes: the amended `FlowSolution_t` `sidsnode` block (`:437-463`) overruns by ~19pt and ~14pt, the API summary `longtable` (`:1600-1622`) by ~41pt. Plus `fancyhdr: \headheight is too small (12.0pt)` and two `hyperref` "Token not allowed in a PDF string" warnings from math in subsection titles (`$p=0$` in Example 6, `$C^k$`). | `\setlength{\headheight}{14pt}`; `\texorpdfstring{}` in those titles; narrow the longtable `p{}` column and the `sidsnode` content. |
| m19 | `.tex` labels | Style | Minor | 14 `\label`s are defined but never referenced (`sec:enum`, `sec:mll`, `sec:mll-impl`, `sec:sids-node`, `ex:cg-write`, `ex:dg-write`, `ex:dispatch`, `ex:hdg`, `ex:fortran`, `ex:fv`, `ex:discrete`, `ex:subreg`, `ex:restart`, `ex:fsi`). `\usepackage{hyphenat}` is loaded but unused. | Harmless; prune or use. |
| s1 | `.tex:236-238` | Technical Accuracy | Suggestion | "`SolutionInterpolation_t` (CPEX 0045) records polynomial order and basis type per element type" — under 0045 the *order* lives in `InterpolationOrders` on the `FlowSolution_t`; only the basis type and control points live in the Family's `SolutionInterpolation_t`. | Correct, and note the node's parent is `Family_t` (see C1). |
| s2 | `.tex:1160-1178` | Clarity | Suggestion | The value proposition for the FV majority is thin: a `CellCenter` solution is already unambiguously independent, so the tag adds nothing derivable. Example 6's justification ("assists post-processors") is weak next to the Abstract's emphasis on FV. | Lead with the load-bearing cases (`Vertex` + `Independent`, HDG, coupling dispatch) and frame FV tagging as optional-but-recommended uniformity. |
| s3 | `.tex:984-993` | Clarity | Suggestion | The orthogonality table shows an em-dash for "Continuous, p=0" without explanation. | Footnote that CG p=0 is meaningless, not merely unusual. |
| s4 | §10 | Standards Compliance | Suggestion | §"Design Decisions" covers per-field granularity and `MixedContinuity`, but there is no explicit rejected-alternatives treatment of: a boolean `Discontinuous` flag; reusing `UserDefinedData_t`; or a new `GridLocation_t` value. | Add a short "Rejected alternatives" subsection — standard in the stronger CPEXs, and it pre-empts review churn. |
| s5 | §5.3 | Clarity | Suggestion | The node-placement rationale argues against `Zone_t` and `SolutionInterpolation_t` but never against the most obvious alternative: extending `GridLocation_t` with a new value (e.g. `ElementVertex`). That is the first question a reviewer will ask. | Add a paragraph on why a new node type beats extending an existing enum. |
| s6 | §4 | Completeness | Suggestion | Only CPEX 0045 is analyzed. CPEX 0047 (`IntegrationPointDefinition`) also concerns element-local DOFs at non-vertex positions and is plausibly adjacent. | Verify and state whether any overlap or conflict exists with CPEX 0047. |

---

## Assessment Areas Key

| Area | Description |
|------|-------------|
| Technical Accuracy | Correctness of claims about CGNS, the SIDS, and other CPEXs |
| Completeness | Cases the specification leaves undefined |
| Standards Compliance | Conformance to CGNS conventions and the CPEX process checklist |
| Clarity | Precision and internal consistency of the prose |
| Reproducibility | Whether the examples compile and run as written |
| Traceability | Process metadata, references, versioning |

---

## Detail on the Critical Findings

### C1 — What CPEX 0045 actually adds to `FlowSolution_t`

From `CPEX-0045-high-order-interpolation.tex:1238-1253`, the amended `FlowSolution_t`:

```
GridLocation_t GridLocation ;                                  (o/d)
IndexArray_t<1, 2, int> InterpolationOrders ;                  (o/d)   <-- new in 0045
DataArray_t<R8, 1|2, [NumElements] or [PhysDim,NumElements]>
    CharacteristicLength ;                                     (o)     <-- new in 0045
Rind_t<IndexDimension> Rind ;                                  (o/d)
...
```

`SolutionInterpolation_t` is introduced as **SIDS §12.11, a child of `Family_t`**
(`0045:1061,1075,1159-1190`). CPEX 0050's amended block therefore both invents a child that does not
exist and omits the two that do. Because §4 ("Interaction with CPEX 0045") is the proposal's principal
argument for why `DofStorage_t` is complementary rather than redundant, this error is load-bearing.

### C2/C3 — Example 4 (HDG) does not work

`cgi_datasize()` in `cgns_internals.c` handles `Vertex`, `CellCenter`, `FaceCenter` **only when
`Cdim==2`**, `EdgeCenter` only when `Cdim==1`, and `[IJK]FaceCenter`; everything else hits
`cgi_error("Location not yet supported")`. `cg_field_write` (`cgnslib.c:6581-6585`) uses
`sol->ptset->size_of_patch` when a point set is present and `cgi_datasize` otherwise. So Case A —
`FaceCenter`, 3-D zone, no point set — fails at the first field write.

Case B is worse because it is a semantic gap, not just a missing argument. Under 0045 the field length
is Σ over "the elements covered by the block (all zone elements when no `PointRange`/`PointList` is
present)". A trace field sized over volume elements is meaningless. And since `InterpolationPoints`
concatenates per-element DOF blocks, `Shared` has no defined reading under it — the only coherent one
requires the "elements" to be *face* elements listed in a point set, which the example does not do and
the specification never states.

### C5 — Duplicate node on modify

`cg_gridlocation_write` avoids this by delegating to `cgi_location_address`
(`cgns_internals.c:13194`), which in `CG_MODE_MODIFY` does:

```c
if (cg->mode == CG_MODE_MODIFY && local_mode == CG_MODE_WRITE) {
    if (cgi_get_nodes(parent_id, "GridLocation_t", &nnod, &id)) return CG_OK;
    if (nnod>0) { if (cgi_delete_node(parent_id, id[0])) {...} CGNS_FREE(id); }
}
```

It looks the node up **by label**, so no id needs to be cached and no parser change is required. This
is the mechanism M2 mistakes for a non-existent `location_id` field, and adopting it (M1) makes C5
impossible by construction.

---

## What is solid

Worth recording so it does not get re-litigated:

- The two-value classification and the reasoning for rejecting `MixedContinuity`, per-`DataArray_t`
  granularity, and a smoothness-order field are well argued and correctly scoped.
- The ASCI-DMF/SAF dof-relation framing (§2.4) is the strongest part of the document and correctly
  positions this CPEX as the coarse layer beneath 0045.
- The storage-not-smoothness framing is right, and holding the line on it in the HDG, penalized-DG,
  and IGA cases is correct.
- All SIDS cross-references verified correct: 4.1 `DataClass_t`, 4.5 `GridLocation_t`, 7.7
  `FlowSolution_t`, 7.9 `ZoneSubRegion_t`, 12.4 `DiscreteData_t`.
- Backward-compatibility claims hold. `cgnscheck` validates only known child labels and does not
  enumerate or warn on unknown ones, so existing tools will silently ignore the new node.
- The filemap encoding choice (C1 string, `DofStorage`/`DofStorage_t`) exactly mirrors
  `GridLocation`, and the `DofStorageName[]` string table (`"Null"`, `"UserDefined"`, ...) matches
  the `GridLocationName[]` convention in `cgnslib.c:148`.
- The enum numbering (`CG_Null`=0, `CG_UserDefined`=1, then 2, 3) matches every other CGNS enum.
- `cgi_new_node` and `cgi_delete_node` are called with correct signatures.
- Example 7's `cg_sol_ptset_write` usage is correct, and `cg_field_write` will accept the larger
  `nElems * nVertsPerElem` array because a point set is present.
- The document builds cleanly (`latexmk` exit 0); all issues are cosmetic (m18).

---

## Resolution Log (v1.1)

Document revised from v1.0 (1659 lines) to v1.1 (2472 lines, 43 pages). Build is clean:
0 errors, 0 undefined references, 0 undefined citations, 0 unreferenced labels, 0 package
warnings. Two overfull hboxes remain at 1.33 pt and 0.56 pt — both under half a millimetre
and not visible in print; reducing them further would require degrading wording.

### Critical

| ID | Resolution |
|----|-----------|
| C1 | Amended `FlowSolution_t` SIDS block now shows CPEX 0045's actual children — `IndexArray_t<1,2,int> InterpolationOrders` and `DataArray_t ... CharacteristicLength` — and states explicitly that `SolutionInterpolation_t` is a child of `Family_t`. All five other mentions corrected; §3.3.1 now argues that placing the node under `SolutionInterpolation_t` would be *doubly* wrong (family-level granularity cannot distinguish two solutions on one family). |
| C2 | New §4.2 "`DofStorage_t` Under `InterpolationPoints`" gives three normative rules: `Independent` is the natural reading; `Shared` is permitted **only** with a point set over interface (face/edge) element indices; `Shared` with no point set, or over volume elements, is **invalid**. Example 4 Case B rewritten to write a face `Elements_t` section and reference it via `PointRange`. |
| C3 | Example 4 Case A rewritten to use `cg_sol_ptset_write` with `FaceCenter` + `PointRange` over face element indices, with an inline comment explaining that `FaceCenter` in a 3-D zone has no SIDS `DataSize` formula so the point set is required. |
| C4 | "Summary of API Additions" fully rewritten for the new API (4 public + 3 internal symbols). No `*_continuity_*` name survives anywhere in the document. |
| C5 | Eliminated by construction: adopting the address-helper pattern (M1) means the existing child is located **by label** at write time, so no node id is cached and the parser has nothing extra to store. §3.7.1 shows the mechanism; §12.3 test 3 is the explicit duplicate-child regression test. |

### Major

| ID | Resolution |
|----|-----------|
| M1 | API redesigned to the position-based pattern: `cg_dof_storage_read/write(type)` reached via `cg_goto`, backed by `cgi_dof_storage_address()`. 12 public functions → 4. New §3.4.1 gives the rationale; Design Decision 4 records it. All 12 examples updated. |
| M2 | The false `location_id` claim is gone. §3.5 now states the opposite and correct fact — the structures carry `location` but no `location_id` — and §3.7.1 shows the real mechanism (`cgi_get_nodes` by label). |
| M3 | §9 rewritten to the canonical FMM 8-row **Node Attributes** template (Name, Label, DataType, Dimension, Dimension Values, Data, Children, Cardinality), cites `cgns-fmm`, places the node in the "Location and Position Group", lists the four affected File Mapping figures, and gives the `DofStorageDescription` filemap. |
| M4 | New §3.8.3 "DOF Ordering Rule" re-anchors on **ascending element index (`ElementRange`)**, explicitly noting sections need not be stored in that order; specifies `MIXED` type codes are not DOFs; specifies `NGON_n`; **excludes `NFACE_n`** with the reason; requires whole-zone coverage; forbids `Rind_t` with this encoding. New §3.8.1 adds the storage-overhead acknowledgment citing Miller, and states `InterpolationPoints`/`IntegrationPoint` are preferred. |
| M5 | §3.8.1 restricts the encoding to unstructured zones and says what structured solvers should do, noting that CPEX 0045's `InterpolationOrders` is also unstructured-only so high-order is not a structured fallback. `cgnscheck` error rule added. |
| M6 | New §3.8.2 states the gap plainly: CPEX 0045 forbids `InterpolationPoints` outside `FlowSolution_t`, CPEX 0047 permits `IntegrationPoint` under four parents but not `DiscreteData_t`, so `DiscreteData_t` has no standard non-vertex element-local encoding. Declared out of scope rather than left implicit. |
| M7 | §6.1 rewritten. States that `pcgnslib.c` contains no scalar-metadata handling at all, then gives the actual normative requirement: `cg_dof_storage_write` and its `cg_goto` **shall** be called by all ranks with identical arguments, because HDF5 structural modification under MPI-IO is collective. Reads may be independent. |
| M8 | New §3.2.1 "Caveat: Vector-Conforming Spaces" moved out of the enum description. Explains the per-element sign/orientation convention, states that `DofStorage_t` does not encode it, and gives three normative bullets — writers may use `Shared`, writers that do shall add identifying provenance, and readers **shall not** apply nodal interpolation to `Shared` vector-conforming DOFs. Orientation metadata declared out of scope. |
| M9 | New §6.2 "Interpreting Legacy Data" gives one rule per grid location; `Vertex` + `PointList` is explicitly left unspecified rather than guessed. States that no blanket "assume shared" default is given, because most existing CFD files are cell-centered and it would be wrong for the majority. Example 10 updated to match. |

### Minor and Suggestions

| ID | Resolution |
|----|-----------|
| m1 | Internal field renamed `dof_storage` (single field). Fortran dummy argument `dofStorage`; example locals `layout`. |
| m2 | One vocabulary throughout. "Continuity" now appears only where naming a *method* (Continuous/Discontinuous Galerkin, `$C^0$-continuous`) or in the new §2.5 naming-history note. |
| m3 | Date First Posted → literal "April 21, 2026"; Date of Last Revision added; statuses → "proposal under review" to match the registry; GitHub Issue → "to be assigned by the CPEX editors"; Reference Impl./Target Release point at §12. New "Prior Title" row plus §2.5 record the rename and flag that the registry scope line and PDF filename need updating. |
| m4 | All 8 bibliography entries now cited at first mention (verified programmatically). |
| m5 | Duplicate `cg_DofStorageName` declaration removed; declared once in §3.4.2. |
| m6 | §11 is now a dedicated `cgnscheck` section with 13 rules, opening with the note that the on-disk form is a C1 string so there is no out-of-range integer to check. Adds rules for the string check (incl. the MLL's version-dependent error-vs-warning behavior), structured zones, exact `PointList` verification, `NFACE_n`, `Rind_t`, `InterpolationPoints`+`Shared`, `IntegrationPoint`+`Shared`, `spatialOrder=0`+`Shared`, missing `DofStorageDescription`, and a literal `"Null"` node. |
| m7 | §8 item 1 names the alphabetical insertion point (new **4.5**) and states that current 4.5–4.8 renumber to 4.6–4.9 and cross-references need updating. |
| m8 | `DofStorageDescription` is now normative ("shall"), has a filemap paragraph in §9.3, a `cgnscheck` warning rule, and is handled in Example 3's `DofStorageUserDefined` branch. |
| m9 | New §3.2.3 "Enumeration Value Naming" documents the convention followed, the collision risk (`cgnslib.h` injects values into the global namespace; no collision today), the `DofStorageShared`/`DofStorageIndependent` alternative, and notes it is a source- not file-compatibility question. Referenced from the API summary table. |
| m10 | Enum listing `=` column aligned. |
| m11 | `UserDefinedData_t` added as a fourth permitted parent — SIDS amendment, address helper, parser update, struct field, filemap figure, and SIDS Impact item 5. Free under the M1 design. |
| m12 | Example 7 rewritten: `malloc`/`free` with a null check, all inputs declared in a header comment with types, `cgsize_t` loop index, and a note that a multi-section/`MIXED`/`NGON_n` zone needs the §3.8.3 traversal. |
| m13 | All three `cg_sol_interpolation_order_write` calls carry a `spatialOrder`/`temporalOrder` comment. |
| m14 | Examples 9 and 12 now call `cg_base_read` to obtain `cellDim` instead of using a bare identifier. |
| m15 | §3.7 opens by identifying `cg` and `posit` as the file-scope pointers used inside `cgnslib.c`. |
| m16 | Write function uses `INVALID_ENUM(DofStorage, NofValidDofStorage)`; the open-coded `switch` is gone. |
| m17 | New §12 "Reference Implementation, Versioning, and Test Plan": 8 deliverables by file, a versioning subsection tying forward compatibility to the version constant, and 13 numbered test cases including the duplicate-child regression, forward compatibility, `PointList` verification, Fortran, and 1/2/4-rank parallel. |
| m18 | `\headheight` → 22 pt with compensating `\topmargin`; `\texorpdfstring` on the Example 6 heading; `\emergencystretch` → 4 em; 8 paragraphs reworded. Overfull count 6 → 2 (1.33 pt, 0.56 pt); all package warnings gone. |
| m19 | All 12 orphaned labels now referenced from natural cross-references (verified: 0 unreferenced labels, 0 dangling refs). `hyphenat` removed. |
| s1 | §2.2 corrected: `SolutionInterpolation_t` records interpolation type and control-point layout on `Family_t`; polynomial orders live in `InterpolationOrders` on `FlowSolution_t`. A new bullet covers CPEX 0047's `ItgPointsStartOffset`. |
| s2 | Abstract and §2.3 keep FV prominent as motivation, but Example 6's commentary now says plainly that a `CellCenter` tag is derivable and therefore recommended-but-optional, and points to the four examples where the tag is load-bearing. |
| s3 | The orthogonality table's `p=0`/Shared cell is now `n/a` with a footnote explaining that a `$p=0$` basis has no interface DOFs to share, so `Shared` is meaningless rather than merely unusual; a matching `cgnscheck` warning was added. |
| s4 | New "Rejected Alternatives" subsection in §10 covering a boolean flag, `MixedStorage`, `UserDefinedData_t` as the primary mechanism, size-based inference, and `Zone_t`/`Base_t` placement. |
| s5 | New §3.3.2 "Why a New Node Rather Than a New `GridLocation_t` Value" with four arguments, plus the observation that CPEX 0045 and 0047 *correctly* add `GridLocation_t` values because those describe genuinely new locations. Recorded as Design Decision 5. |
| s6 | New §5 "Interaction with CPEX 0047". Confirms no conflict; notes `ItgPointsStartOffset` is a better dof-map than the `PointList` encoding where it applies and recommends it; establishes that `IntegrationPoint` data is necessarily `Independent`; notes CPEX 0047 does not subsume this proposal (silent on vertex/edge/face DOFs and on `DiscreteData_t`); flags that boundary extensions must be reconciled if per-BC metadata is later proposed; and flags the `InterpolationPoints`/`IntegrationPoint` name similarity for the editors. |

### Verification performed on v1.1

Every API signature used in the examples and implementation listings was checked against
`CGNS-develop`: `cg_section_write`, `cg_base_read`, `cg_sol_ptset_write`,
`cg_subreg_bcname_write`, `cg_ndescriptors`, `cg_descriptor_read`, `cg_free`,
`CGIO_MAX_NAME_LENGTH`, `cg_goto_f` argument order (`ier` third), `cgi_new_node`,
`cgi_delete_node`, `cgi_get_nodes`, `cgi_posit_id`, `CHECK_FILE_OPEN`, `INVALID_ENUM`,
`ADDRESS4SINGLE_ALLOC`, and the `cgns_user_data` structure. The new `cgi_DofStorage` and
`cgi_dof_storage_address` listings are modelled line-for-line on `cgi_GridLocation`
(`cgns_internals.c`) and `cgi_location_address` (`cgns_internals.c:13194`).
