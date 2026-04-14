\documentclass[11pt,letterpaper]{article}

%% ── Packages ──────────────────────────────────────────────────────────────
\usepackage[margin=1in]{geometry}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{listings}
\usepackage{booktabs}
\usepackage{enumitem}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{longtable}
\usepackage{array}
\usepackage{colortbl}
\usepackage{parskip}
\usepackage{microtype}
\usepackage[htt]{hyphenat}
\setlength{\emergencystretch}{3em}
\usepackage{needspace}
\usepackage[right,running]{lineno}

%% ── Suppress lineno inside code listings ────────────────────────────────
\makeatletter
\let\cgns@orig@lstlisting\lstlisting
\let\cgns@endorig@lstlisting\endlstlisting
\renewenvironment{lstlisting}
  {\par\needspace{5\baselineskip}\nolinenumbers\cgns@orig@lstlisting}
  {\cgns@endorig@lstlisting\par\linenumbers}
\makeatother

%% ── Color palette ───────────────────────────────────────────────────────
\definecolor{cgnsblue}{HTML}{1F4E79}
\definecolor{cgnsteal}{HTML}{2E7D8C}
\definecolor{cgnslight}{HTML}{D6EAF0}
\definecolor{cgnsgold}{HTML}{C78C1C}

%% ── Hyperlink style ──────────────────────────────────────────────────────
\hypersetup{
  colorlinks=true,
  linkcolor=cgnsblue,
  urlcolor=cgnsteal,
  citecolor=cgnsblue,
}

%% ── Code listing style ──────────────────────────────────────────────────
\lstset{
  basicstyle=\scriptsize\ttfamily,
  keywordstyle=\bfseries\color{cgnsblue},
  commentstyle=\itshape\color{cgnsteal},
  stringstyle=\color{red!60!black},
  breaklines=true,
  frame=single,
  framerule=0.5pt,
  rulecolor=\color{cgnsblue!40},
  backgroundcolor=\color{cgnslight!30},
  numbers=left,
  numberstyle=\tiny\color{cgnsblue!50},
  numbersep=6pt,
  showstringspaces=false,
  xleftmargin=1em,
  xrightmargin=1em,
  aboveskip=1em,
  belowskip=1em,
  tabsize=4,
}

%% ── SIDS-style node definition environment ──────────────────────────────
\newenvironment{sidsnode}[1]{%
  \par\vspace{0.8em}%
  \noindent\colorbox{cgnslight!50}{\makebox[\dimexpr\linewidth-2\fboxsep][l]{%
    \texttt{\textbf{\color{cgnsblue}#1}}}}\\[0.3em]%
  \begin{quote}\ttfamily
}{%
  \end{quote}\vspace{0.4em}%
}

%% ── Header / Footer ────────────────────────────────────────────────────
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\color{cgnsblue} CPEX 0050 --- Solution Representation Type}
\fancyhead[R]{\small\color{cgnsblue} Version 0.1}
\fancyfoot[C]{\small\color{cgnsblue}\thepage}
\renewcommand{\headrulewidth}{0.5pt}
\renewcommand{\headrule}{\hbox to\headwidth{\color{cgnsgold}\leaders\hrule height\headrulewidth\hfill}}
\renewcommand{\footrulewidth}{0pt}

%% ── Title Formatting ───────────────────────────────────────────────────
\titleformat{\section}{\Large\bfseries\color{cgnsblue}}{\thesection}{0.6em}{}[\vspace{0.2em}{\color{cgnsgold}\titlerule[0.8pt]}]
\titleformat{\subsection}{\large\bfseries\color{cgnsblue!85}}{\thesubsection}{0.6em}{}
\titleformat{\subsubsection}{\normalsize\bfseries\color{cgnsteal}}{\thesubsubsection}{0.6em}{}

%% =====================================================================
\begin{document}
\linenumbers

%% ── Title Block ─────────────────────────────────────────────────────────
\begin{center}
  \includegraphics[width=0.25\textwidth]{CGNS_logo_1.png}\\[1.2em]
  {\LARGE\bfseries\color{cgnsblue} CGNS Proposal for Extension 0050}\\[0.6em]
  {\Large\color{cgnsteal} Solution Representation Type}\\[0.4em]
  {\color{cgnsgold}\rule{0.4\textwidth}{0.8pt}}\\[0.6em]
  {\large Version 0.1}\\[0.6em]
  \today
\end{center}

\vspace{1em}

%% ── Metadata Table ──────────────────────────────────────────────────────
\noindent
\rowcolors{2}{cgnslight!30}{white}
\begin{tabular}{@{} >{\bfseries\color{cgnsblue}}l l @{}}
\toprule
CPEX\#           & 0050 \\
Scope            & Distinguish continuous and discontinuous solution representations \\
Champion         & M.\ Scot Breitenfeld \\
Organization     & The HDF Group \\
E-mail           & \href{mailto:brtnfld@hdfgroup.org}{brtnfld@hdfgroup.org} \\
GitHub Issue     & TBD \\
Reference Impl.  & TBD \\
Target Release   & TBD \\
Date First Posted & \today \\
SIDS Status      & proposed \\
Filemap Status   & proposed \\
MLL Status       & proposed \\
\bottomrule
\end{tabular}

\vspace{1.5em}

\tableofcontents
\newpage

%% ═════════════════════════════════════════════════════════════════════════
\section{Abstract}
%% ═════════════════════════════════════════════════════════════════════════

This CPEX proposes adding a \texttt{SolutionRepresentation\_t}
enumeration and corresponding SIDS node to the CGNS standard, enabling
CGNS files to record whether solution data uses a continuous or
discontinuous field representation.  This distinction---most commonly
associated with Continuous Galerkin (CG) and Discontinuous Galerkin
(DG) finite element methods---is fundamental to the correct
interpretation of solution data but is not captured by any existing
CGNS construct.  The proposal is general: it applies at any polynomial
order, to any discretization family (finite element, finite volume,
spectral element, etc.), and interacts naturally with the higher-order
solution infrastructure introduced by CPEX~0045.

%% ═════════════════════════════════════════════════════════════════════════
\section{Motivation and Rationale}
%% ═════════════════════════════════════════════════════════════════════════

\subsection{Problem Statement}

Modern CFD and computational mechanics codes increasingly use
discretization methods whose solution data cannot be fully described
by the existing CGNS metadata.  The core issue is the treatment of
degrees of freedom (DOFs) at shared geometric entities (vertices,
edges, faces):

\begin{itemize}[leftmargin=2em]
\item In a \textbf{continuous} representation (e.g., Continuous
  Galerkin FEM, $C^0$ spectral element methods), DOFs at shared
  interfaces are \emph{shared}: a single value exists per geometric
  node, and the global solution field is at least $C^0$-continuous
  across element boundaries.

\item In a \textbf{discontinuous} representation (e.g., Discontinuous
  Galerkin, finite volume, $C^{-1}$ spectral element methods), DOFs
  are \emph{element-local}: each element owns its own values at every
  point, including at shared interfaces.  Multiple independent values
  may exist at the same geometric location.
\end{itemize}

This distinction affects:

\begin{enumerate}[leftmargin=2em]
\item \textbf{Data size and layout.}  A DG solution on a mesh with
  shared vertices stores more values than a CG solution on the same
  mesh.  Post-processors that assume shared-vertex semantics will
  misinterpret the data dimensions.

\item \textbf{Visualization and interpolation.}  CG fields can be
  interpolated globally using the mesh connectivity; DG fields require
  element-local interpolation and may exhibit intentional
  discontinuities at element interfaces that should not be smoothed.

\item \textbf{Restart and data exchange.}  Solvers reading restart
  files must know whether DOFs are shared or element-local to
  correctly reconstruct the solution state.  Coupling frameworks
  exchanging solution data between codes need this metadata to perform
  correct inter-code transfers.

\item \textbf{Error estimation and adaptation.}  The jump in solution
  values across element interfaces in a DG solution is physically
  meaningful and is used for error estimation.  A post-processor that
  incorrectly treats DG data as continuous would average out these
  jumps.
\end{enumerate}

\subsection{Inadequacy of Existing CGNS Constructs}

No existing CGNS mechanism captures the continuous/discontinuous
distinction:

\begin{description}[leftmargin=2em]
\item[\texttt{GridLocation\_t}] specifies \emph{where} data is
  located (vertices, cell centers, faces, edges, or interpolation
  points) but not whether values at shared locations are shared or
  element-local.  A \texttt{Vertex}-located solution could be either
  CG or DG; the same applies to \texttt{InterpolationPoints}.

\item[\texttt{PointSet}] (\texttt{PointList}, \texttt{PointRange})
  can index subsets of data but does not encode continuity semantics.

\item[\texttt{InterpolationType\_t}] (CPEX~0045) describes the
  polynomial basis (Lagrange, monomial, isoparametric) but not whether
  that basis yields a globally continuous or element-local field.

\item[\texttt{SolutionInterpolation\_t}] (CPEX~0045) records
  polynomial order and basis type per element type but contains no
  continuity information.

\item[Data array size] can sometimes be used to \emph{infer} the
  representation---a DG field will have $N_{\mathrm{elem}} \times
  N_{\mathrm{DOF/elem}}$ values versus $N_{\mathrm{nodes}}$ for CG.
  However, this inference is fragile, ambiguous for $p=0$
  (cell-centered) data, and breaks entirely for mixed-element meshes
  or when point sets are used.
\end{description}

\subsection{Generality Beyond Higher-Order Methods}

Although often discussed in the context of high-order finite elements,
the continuous/discontinuous distinction is \textbf{not limited to
higher-order methods}:

\begin{itemize}[leftmargin=2em]
\item \textbf{DG $p=0$} (piecewise constant) is essentially a
  cell-centered finite volume representation.
\item \textbf{DG $p=1$} (piecewise linear, discontinuous) is widely
  used and is a low-order method.
\item \textbf{CG $p=1$} is standard continuous linear FEM, the most
  common finite element discretization.
\item Classical \textbf{finite volume} methods are inherently
  discontinuous ($p=0$ DG).
\item \textbf{Hybridizable DG (HDG)} methods have both element-local
  DOFs (discontinuous) and trace DOFs on faces (continuous on the
  skeleton).
\end{itemize}

A proper metadata field should therefore live at the
\texttt{FlowSolution\_t} level, applicable at any order, not solely
within the higher-order interpolation infrastructure.

%% ═════════════════════════════════════════════════════════════════════════
\section{Detailed Description}
%% ═════════════════════════════════════════════════════════════════════════

\subsection{Design Overview}

The proposal introduces:

\begin{enumerate}[leftmargin=2em]
\item A new \texttt{SolutionRepresentation\_t} enumeration with values
  covering the common representation types.
\item A new optional child node of \texttt{FlowSolution\_t} (and
  \texttt{DiscreteData\_t}) recording the solution representation.
\item Mid-Level Library functions to read and write the representation.
\item Fortran bindings.
\end{enumerate}

\subsection{New Enumeration: \texttt{SolutionRepresentation\_t}}
\label{sec:enum}

\begin{lstlisting}[language=C]
typedef enum {
  CGNS_ENUMV( SolutionRepresentationNull )        = CG_Null,
  CGNS_ENUMV( SolutionRepresentationUserDefined )  = CG_UserDefined,
  CGNS_ENUMV( ContinuousFieldRepresentation )      = 2,
  CGNS_ENUMV( DiscontinuousFieldRepresentation )   = 3
} CGNS_ENUMT( SolutionRepresentation_t );

#define NofValidSolutionRepresentation 4

extern CGNSDLL const char *
    SolutionRepresentationName[NofValidSolutionRepresentation];
\end{lstlisting}

The enumeration values are:

\begin{description}[leftmargin=2em]
\item[\texttt{SolutionRepresentationNull}] No representation
  specified.  This is the default for backward compatibility: existing
  files and codes that do not set this field are unaffected.

\item[\texttt{SolutionRepresentationUserDefined}] Application-defined
  representation not covered by the standard values.

\item[\texttt{ContinuousFieldRepresentation}] The solution field is
  globally $C^0$-continuous (or higher) across element interfaces.
  DOFs at shared mesh entities (vertices, edges, faces) are shared
  between adjacent elements.  Typical of: Continuous Galerkin FEM,
  $C^0$ spectral element methods, isogeometric analysis with
  $C^0$~junctions.

\item[\texttt{DiscontinuousFieldRepresentation}] The solution field is
  element-local with no continuity enforced across element interfaces
  ($C^{-1}$).  Each element owns independent DOFs, including at shared
  geometric locations.  Typical of: Discontinuous Galerkin methods,
  finite volume methods, $C^{-1}$ spectral element methods.
\end{description}

\subsubsection{Design Alternative: Additional Continuity Classes}

More granular continuity classes were considered:

\begin{itemize}[leftmargin=2em]
\item \texttt{MixedContinuity} --- for HDG-like methods with both
  continuous trace DOFs and discontinuous volume DOFs.
\item \texttt{WeaklyContinuous} --- for penalized DG methods where
  continuity is weakly enforced.
\item $C^k$ continuity order --- for isogeometric analysis with
  higher-than-$C^0$ smoothness.
\end{itemize}

These were deferred in favor of simplicity.  The
\texttt{SolutionRepresentationUserDefined} value provides an escape
hatch, and additional enumeration values can be added in future CPEXes
without breaking backward compatibility.  In practice, the
overwhelming majority of current CFD codes fall cleanly into the
continuous or discontinuous categories.

For HDG methods, the recommended approach is to use separate
\texttt{FlowSolution\_t} nodes: one with
\texttt{DiscontinuousFieldRepresentation} for the volume DOFs and one
with \texttt{ContinuousFieldRepresentation} for the trace (skeleton)
DOFs.

\subsection{SIDS Node Definition}
\label{sec:sids-node}

The representation is stored as a new optional child node of
\texttt{FlowSolution\_t}.  The amended SIDS definition adds one line
(shown with the \texttt{+} marker):

\begin{sidsnode}{FlowSolution\_t (amended, SIDS Section 7.7)}
FlowSolution\_t< int CellDimension, int IndexDimension, \\
\qquad\qquad\quad int VertexSize[IndexDimension], \\
\qquad\qquad\quad int CellSize[IndexDimension] > := \\
\quad \{ \\
\quad List( Descriptor\_t Descriptor1 ... DescriptorN ) ;  \qquad\qquad (o) \\
\\
\quad GridLocation\_t GridLocation ; \qquad\qquad\qquad\qquad\qquad\quad\; (o/d) \\
\\
\quad Rind\_t<IndexDimension> Rind ; \qquad\qquad\qquad\qquad\qquad\quad (o/d) \\
\\
\quad IndexRange\_t<IndexDimension> PointRange ; \qquad\qquad\qquad\;\; (o) \\
\quad IndexArray\_t<IndexDimension, ListLength[], int> PointList ; \; (o) \\
\\
\quad List( DataArray\_t<DataType, IndexDimension, DataSize[]> \\
\qquad\quad DataArray1 ... DataArrayN ) ; \qquad\qquad\qquad\qquad\quad\;\; (o) \\
\\
\quad DataClass\_t DataClass ; \qquad\qquad\qquad\qquad\qquad\qquad\quad\; (o) \\
\\
\quad DimensionalUnits\_t DimensionalUnits ; \qquad\qquad\qquad\quad\;\;\; (o) \\
\\
+ \quad SolutionRepresentation\_t SolutionRepresentation ; \qquad\quad\;\; (o) \\
\\
\quad List( UserDefinedData\_t UserDefinedData1 ... UserDefinedDataN ) ; (o) \\
\quad \}
\end{sidsnode}

The \texttt{SolutionRepresentation} child is \textbf{optional}
(\texttt{o}).  When absent, the representation is unspecified
(\texttt{SolutionRepresentationNull}), preserving full backward
compatibility.

The same optional child node is added to \texttt{DiscreteData\_t}
(SIDS Section~12.4), using identical structure and semantics:

\begin{sidsnode}{DiscreteData\_t (amended, SIDS Section 12.4)}
DiscreteData\_t< int CellDimension, int IndexDimension, \\
\qquad\qquad\quad int VertexSize[IndexDimension], \\
\qquad\qquad\quad int CellSize[IndexDimension] > := \\
\quad \{ \\
\quad ... (existing children unchanged) ... \\
\\
+ \quad SolutionRepresentation\_t SolutionRepresentation ; \qquad\quad\;\; (o) \\
\quad \}
\end{sidsnode}

\subsubsection{Node Placement Rationale}

The node is placed as a child of \texttt{FlowSolution\_t} (rather
than, for example, \texttt{Zone\_t} or
\texttt{SolutionInterpolation\_t}) because:

\begin{itemize}[leftmargin=2em]
\item The representation is a property of the \emph{solution field},
  not of the mesh or the zone.

\item A single zone may contain multiple \texttt{FlowSolution\_t}
  nodes with different representations---for example, an HDG solver
  storing both volume (discontinuous) and trace (continuous) solutions,
  or a multi-physics code storing a continuous displacement field
  alongside a discontinuous stress field.

\item This parallels the existing \texttt{GridLocation\_t} child of
  \texttt{FlowSolution\_t}, which is also a per-solution-node
  property.

\item Placing it within the CPEX~0045 \texttt{SolutionInterpolation\_t}
  would incorrectly limit the scope to higher-order solutions, when
  the distinction applies at any order.
\end{itemize}

\subsection{New MLL Functions}
\label{sec:mll}

\subsubsection{C API}

\begin{lstlisting}[language=C]
/*
 * Write the solution representation for a FlowSolution_t node.
 *
 * fn   - file number
 * B    - base index
 * Z    - zone index
 * S    - solution index
 * type - SolutionRepresentation_t value
 */
int cg_sol_representation_write(
    int fn, int B, int Z, int S,
    CGNS_ENUMT(SolutionRepresentation_t) type);

/*
 * Read the solution representation for a FlowSolution_t node.
 *
 * fn   - file number
 * B    - base index
 * Z    - zone index
 * S    - solution index
 * type - [out] SolutionRepresentation_t value;
 *        returns SolutionRepresentationNull if node absent
 */
int cg_sol_representation_read(
    int fn, int B, int Z, int S,
    CGNS_ENUMT(SolutionRepresentation_t) *type);

/*
 * Write/read the solution representation for a DiscreteData_t node.
 * Same semantics as the FlowSolution_t counterparts.
 *
 * fn   - file number
 * B    - base index
 * Z    - zone index
 * D    - discrete data index
 * type - SolutionRepresentation_t value
 */
int cg_discrete_representation_write(
    int fn, int B, int Z, int D,
    CGNS_ENUMT(SolutionRepresentation_t) type);

int cg_discrete_representation_read(
    int fn, int B, int Z, int D,
    CGNS_ENUMT(SolutionRepresentation_t) *type);
\end{lstlisting}

\textbf{Behavior:}

\begin{itemize}[leftmargin=2em]
\item The \texttt{\_write} functions create (or overwrite)
  the \texttt{SolutionRepresentation} child node under the specified
  \texttt{FlowSolution\_t} or \texttt{DiscreteData\_t} node.  Writing
  \texttt{SolutionRepresentationNull} removes the node if present.

\item The \texttt{\_read} functions return the value stored
  in the \texttt{SolutionRepresentation} child node.  If the node does
  not exist (legacy file or unset), they return
  \texttt{SolutionRepresentationNull} without error.
\end{itemize}

\subsubsection{Fortran API}

\begin{lstlisting}[language=Fortran]
! FlowSolution_t
subroutine cg_sol_representation_write_f( &
    fn, B, Z, S, type, ier)
  integer, intent(in) :: fn, B, Z, S, type
  integer, intent(out) :: ier

subroutine cg_sol_representation_read_f( &
    fn, B, Z, S, type, ier)
  integer, intent(in) :: fn, B, Z, S
  integer, intent(out) :: type, ier

! DiscreteData_t
subroutine cg_discrete_representation_write_f( &
    fn, B, Z, D, type, ier)
  integer, intent(in) :: fn, B, Z, D, type
  integer, intent(out) :: ier

subroutine cg_discrete_representation_read_f( &
    fn, B, Z, D, type, ier)
  integer, intent(in) :: fn, B, Z, D
  integer, intent(out) :: type, ier
\end{lstlisting}

\subsection{Internal Data Structure Changes}

The \texttt{cgns\_sol} structure (\texttt{FlowSolution\_t}) and
\texttt{cgns\_discrete} structure (\texttt{DiscreteData\_t}) in
\texttt{cgns\_header.h} each gain one field:

\begin{lstlisting}[language=C]
typedef struct {            /* FlowSolution_t node */
    /* ... existing fields ... */

    /* CPEX 0050 */
    CGNS_ENUMT(SolutionRepresentation_t) representation;
} cgns_sol;

typedef struct {            /* DiscreteData_t node */
    /* ... existing fields ... */

    /* CPEX 0050 */
    CGNS_ENUMT(SolutionRepresentation_t) representation;
} cgns_discrete;
\end{lstlisting}

The field defaults to \texttt{SolutionRepresentationNull} (value~0),
which is the zero-initialization value and the ``not specified'' state.

%% ═════════════════════════════════════════════════════════════════════════
\section{Interaction with CPEX 0045 (Higher-Order Elements)}
%% ═════════════════════════════════════════════════════════════════════════

CPEX~0045 introduced \texttt{GridLocation\_t = InterpolationPoints},
\texttt{SolutionInterpolation\_t}, and the concept of per-element-type
polynomial basis definitions.  The present CPEX complements rather
than modifies that infrastructure:

\begin{itemize}[leftmargin=2em]
\item CPEX~0045 answers: ``What polynomial basis and order describes
  the solution within each element?''
\item This CPEX answers: ``Are the resulting DOFs shared across element
  interfaces or element-local?''
\end{itemize}

Both pieces of metadata are needed for a complete description of a
higher-order solution field.  They are orthogonal:

\begin{center}
\begin{tabular}{lcc}
\toprule
& \textbf{Continuous} & \textbf{Discontinuous} \\
\midrule
Lagrange $p=1$ & CG FEM & DG $p=1$ \\
Lagrange $p=3$ & CG spectral & DG spectral \\
Monomial $p=2$ & CG (modal) & DG (modal) \\
$p=0$ (constant) & --- & FV / DG $p=0$ \\
\bottomrule
\end{tabular}
\end{center}

For higher-order solutions using \texttt{GridLocation\_t =
InterpolationPoints}, the recommended practice is:

\begin{enumerate}[leftmargin=2em]
\item Use CPEX~0045 to define the element type, interpolation basis,
  and polynomial order via \texttt{SolutionInterpolation\_t}.
\item Use this CPEX to set \texttt{SolutionRepresentation\_t} on the
  \texttt{FlowSolution\_t} node to indicate whether the field is
  continuous or discontinuous.
\end{enumerate}

For lower-order solutions using \texttt{GridLocation\_t = Vertex} or
\texttt{CellCenter}, this CPEX can be used independently of CPEX~0045.

%% ═════════════════════════════════════════════════════════════════════════
\section{Backward Compatibility}
%% ═════════════════════════════════════════════════════════════════════════

\begin{itemize}[leftmargin=2em]
\item \textbf{Existing files:} Fully compatible.  The
  \texttt{SolutionRepresentation} node is optional; its absence is
  equivalent to \texttt{SolutionRepresentationNull}.  No existing file
  is invalidated.

\item \textbf{Existing readers:} Unaffected.  Per CGNS convention,
  readers silently ignore unknown child nodes.  An older library
  reading a file with \texttt{SolutionRepresentation} nodes will
  simply skip them.

\item \textbf{Existing writers:} Unaffected.  Codes that do not call
  the new API functions produce files without
  \texttt{SolutionRepresentation} nodes, identical to current
  behavior.

\item \textbf{ABI:} The \texttt{cgns\_sol} structure grows by one
  \texttt{int}-sized field.  This is an ABI change requiring
  recompilation of code that directly accesses the internal
  structures.  The public API is purely additive (new functions, new
  enum), so no existing function signatures change.
\end{itemize}

%% ═════════════════════════════════════════════════════════════════════════
\section{Examples}
%% ═════════════════════════════════════════════════════════════════════════

\subsection{Example 1: Writing a Continuous Galerkin Solution (C)}

\begin{lstlisting}[language=C]
/* Create a vertex-located solution node */
int S;
cg_sol_write(fn, B, Z, "FlowSolution", CGNS_ENUMV(Vertex), &S);

/* Mark as continuous (CG FEM) */
cg_sol_representation_write(fn, B, Z, S,
    CGNS_ENUMV(ContinuousFieldRepresentation));

/* Write solution data (one value per mesh vertex, shared) */
cg_field_write(fn, B, Z, S, CGNS_ENUMV(RealDouble),
    "Pressure", pressure, &F);
\end{lstlisting}

\subsection{Example 2: Writing a Discontinuous Galerkin Solution (C)}

\begin{lstlisting}[language=C]
/* Create an interpolation-point-located solution node */
int S;
cg_sol_write(fn, B, Z, "FlowSolution_DG",
    CGNS_ENUMV(InterpolationPoints), &S);

/* Set polynomial order (CPEX 0045) */
cg_sol_interpolation_order_write(fn, B, Z, S, 3, 0);

/* Mark as discontinuous */
cg_sol_representation_write(fn, B, Z, S,
    CGNS_ENUMV(DiscontinuousFieldRepresentation));

/* Write element-local DOFs */
cg_field_write(fn, B, Z, S, CGNS_ENUMV(RealDouble),
    "Pressure", pressure_dg, &F);
\end{lstlisting}

\subsection{Example 3: Reading and Dispatching on Representation (C)}

\begin{lstlisting}[language=C]
CGNS_ENUMT(SolutionRepresentation_t) repr;
cg_sol_representation_read(fn, B, Z, S, &repr);

switch (repr) {
case CGNS_ENUMV(ContinuousFieldRepresentation):
    /* Shared DOFs: interpolate using global mesh connectivity */
    visualize_continuous(fn, B, Z, S);
    break;
case CGNS_ENUMV(DiscontinuousFieldRepresentation):
    /* Element-local DOFs: render per-element, preserve jumps */
    visualize_discontinuous(fn, B, Z, S);
    break;
default:
    /* Null or UserDefined: fall back to legacy heuristics */
    visualize_legacy(fn, B, Z, S);
    break;
}
\end{lstlisting}

\subsection{Example 4: HDG Solver with Both Representations (C)}

\begin{lstlisting}[language=C]
/* Volume DOFs (discontinuous) */
int S_vol;
cg_sol_write(fn, B, Z, "VolumeSolution",
    CGNS_ENUMV(InterpolationPoints), &S_vol);
cg_sol_representation_write(fn, B, Z, S_vol,
    CGNS_ENUMV(DiscontinuousFieldRepresentation));

/* Trace DOFs on element faces (continuous on skeleton) */
int S_trace;
cg_sol_write(fn, B, Z, "TraceSolution",
    CGNS_ENUMV(FaceCenter), &S_trace);
cg_sol_representation_write(fn, B, Z, S_trace,
    CGNS_ENUMV(ContinuousFieldRepresentation));
\end{lstlisting}

\subsection{Example 5: Fortran Usage}

\begin{lstlisting}[language=Fortran]
integer :: S, ier, repr

! Write a continuous solution
call cg_sol_write_f(fn, B, Z, 'FlowSolution', Vertex, S, ier)
call cg_sol_representation_write_f(fn, B, Z, S, &
    ContinuousFieldRepresentation, ier)

! Read representation
call cg_sol_representation_read_f(fn, B, Z, S, repr, ier)
if (repr == DiscontinuousFieldRepresentation) then
    ! Element-local interpolation
end if
\end{lstlisting}

\subsection{Example 6: Low-Order Finite Volume (DG $p=0$)}

\begin{lstlisting}[language=C]
/* Cell-centered FV solution */
int S;
cg_sol_write(fn, B, Z, "FlowSolution",
    CGNS_ENUMV(CellCenter), &S);

/* Explicitly mark as discontinuous */
cg_sol_representation_write(fn, B, Z, S,
    CGNS_ENUMV(DiscontinuousFieldRepresentation));
\end{lstlisting}

This example demonstrates that the representation metadata is useful
even for traditional low-order methods.  While a \texttt{CellCenter}
solution is inherently element-local, explicitly recording the
representation aids post-processors and coupling frameworks that need
to distinguish between solution types programmatically.

%% ═════════════════════════════════════════════════════════════════════════
\section{SIDS Impact}
%% ═════════════════════════════════════════════════════════════════════════

\begin{enumerate}[leftmargin=2em]
\item \textbf{New enumeration type:} \texttt{SolutionRepresentation\_t}
  is added to the SIDS building-block structure definitions
  (Section~4 of the SIDS document), alongside existing enumeration
  types such as \texttt{GridLocation\_t} (Section~4.5) and
  \texttt{DataClass\_t} (Section~4.1).

\item \textbf{FlowSolution\_t amendment:} The
  \texttt{FlowSolution\_t} node definition (SIDS Section~7.7) is
  amended to include an optional
  \texttt{SolutionRepresentation\_t} child node.

\item \textbf{DiscreteData\_t amendment:} The
  \texttt{DiscreteData\_t} node definition (SIDS Section~12.4) is
  similarly amended.

\item No existing SIDS node types, enumerations, or conventions are
  modified or removed.
\end{enumerate}

%% ═════════════════════════════════════════════════════════════════════════
\section{File Mapping Impact}
%% ═════════════════════════════════════════════════════════════════════════

The \texttt{SolutionRepresentation} child node is stored identically
to \texttt{GridLocation}: as a character node containing the string
name of the enumeration value.  The file-mapping attributes are:

\begin{center}
\begin{tabular}{@{} l l @{}}
\toprule
\textbf{Attribute} & \textbf{Value} \\
\midrule
Node name  & \texttt{SolutionRepresentation} \\
Label      & \texttt{SolutionRepresentation\_t} \\
Data type  & \texttt{C1} (character) \\
Dimension  & 1 \\
Dimension value & length of enumeration string \\
Data       & enumeration name string \\
\bottomrule
\end{tabular}
\end{center}

\noindent This follows the same pattern as the \texttt{GridLocation}
node under \texttt{FlowSolution\_t}: node name
\texttt{"GridLocation"}, label \texttt{"GridLocation\_t"}, data type
\texttt{"C1"}, with the enumeration string as data.

The node is written only when the representation is not
\texttt{SolutionRepresentationNull}.  When absent, readers default to
\texttt{SolutionRepresentationNull}, paralleling how an absent
\texttt{GridLocation} node defaults to \texttt{Vertex}.

%% ═════════════════════════════════════════════════════════════════════════
\section{Open Questions}
%% ═════════════════════════════════════════════════════════════════════════

\begin{enumerate}[leftmargin=2em]

\item \textbf{Enum naming convention.}
  The proposed enumeration values use descriptive names
  (\texttt{ContinuousFieldRepresentation},
  \texttt{DiscontinuousFieldRepresentation}).  Shorter alternatives
  such as \texttt{Continuous}/\texttt{Discontinuous} or
  \texttt{CG\_Representation}/\texttt{DG\_Representation} could be
  considered.  The longer names were chosen to avoid ambiguity with
  the ``CG'' abbreviation (which collides with the CGNS library's
  \texttt{CG\_} namespace prefix) and to be self-documenting in the
  SIDS string representation.

\item \textbf{Scope: \texttt{FlowSolution\_t} only, or broader?}
  Should \texttt{SolutionRepresentation\_t} also be permitted on
  other node types such as \texttt{BCData\_t} or
  \texttt{ZoneSubRegion\_t}?  The initial proposal limits scope to
  \texttt{FlowSolution\_t} and \texttt{DiscreteData\_t} for
  simplicity, but the committee may wish to extend it.

\item \textbf{Per-field vs.\ per-solution-node granularity.}
  The current proposal applies the representation at the
  \texttt{FlowSolution\_t} level, meaning all fields within a solution
  node share the same representation.  An alternative would allow
  per-\texttt{DataArray\_t} representation, at the cost of more
  complexity.  Per-solution-node granularity is believed to be
  sufficient: solvers that mix representations can use separate
  \texttt{FlowSolution\_t} nodes.

\item \textbf{Interaction with \texttt{GridLocation\_t = CellCenter}.}
  A \texttt{CellCenter} solution is inherently element-local.  Should
  the library enforce consistency (reject
  \texttt{ContinuousFieldRepresentation} with \texttt{CellCenter}), or
  allow the user to set any combination?  The proposal currently does
  not enforce consistency, leaving validation to application-level
  tools.

\end{enumerate}

%% ═════════════════════════════════════════════════════════════════════════
\section{Summary of API Additions}
%% ═════════════════════════════════════════════════════════════════════════

\begin{center}
\begin{longtable}{l p{8.5cm}}
\toprule
\textbf{Symbol} & \textbf{Description} \\
\midrule
\endhead
\texttt{SolutionRepresentation\_t} & New enumeration type: \texttt{Null}, \texttt{UserDefined}, \texttt{ContinuousFieldRepresentation}, \texttt{DiscontinuousFieldRepresentation}. \\
\texttt{SolutionRepresentationName} & String table for the enumeration values. \\
\texttt{NofValidSolutionRepresentation} & Count of valid enumeration values (4). \\
\texttt{cg\_sol\_representation\_write} & C: write solution representation for a \texttt{FlowSolution\_t} node. \\
\texttt{cg\_sol\_representation\_read} & C: read solution representation for a \texttt{FlowSolution\_t} node. \\
\texttt{cg\_discrete\_representation\_write} & C: write solution representation for a \texttt{DiscreteData\_t} node. \\
\texttt{cg\_discrete\_representation\_read} & C: read solution representation for a \texttt{DiscreteData\_t} node. \\
\texttt{cg\_sol\_representation\_write\_f} & Fortran: write solution representation (\texttt{FlowSolution\_t}). \\
\texttt{cg\_sol\_representation\_read\_f} & Fortran: read solution representation (\texttt{FlowSolution\_t}). \\
\texttt{cg\_discrete\_representation\_write\_f} & Fortran: write solution representation (\texttt{DiscreteData\_t}). \\
\texttt{cg\_discrete\_representation\_read\_f} & Fortran: read solution representation (\texttt{DiscreteData\_t}). \\
\bottomrule
\end{longtable}
\end{center}

%% ═════════════════════════════════════════════════════════════════════════
\section{References}
%% ═════════════════════════════════════════════════════════════════════════

\begin{enumerate}[leftmargin=2em]
\item CGNS Standard Interface Data Structures (SIDS),\\
  \url{https://cgns.org/standard/SIDS/CGNS_SIDS.html}

\item CGNS Mid-Level Library---Flow Solution,\\
  \url{https://cgns.org/standard/MLL/api/c_api.html}

\item CPEX 0045, ``High-Order Elements and Solutions,''\\
  \url{https://github.com/CGNS/CGNS/issues/359}

\item Hesthaven, J.S.\ and Warburton, T., \emph{Nodal Discontinuous
  Galerkin Methods}, Springer, 2008.

\item Cockburn, B., Karniadakis, G.E., and Shu, C.-W., eds.,
  \emph{Discontinuous Galerkin Methods: Theory, Computation, and
  Applications}, Springer, 2000.
\end{enumerate}

\end{document}
