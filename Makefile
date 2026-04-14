# Makefile for CPEX-0050-compat-version.tex
#
# Usage:
#   make -f Makefile          # build PDF (uses latexmk if available)
#   make -f Makefile pdf      # same
#   make -f Makefile view     # build and open PDF
#   make -f Makefile clean    # remove auxiliary files
#   make -f Makefile distclean  # remove auxiliary files + PDF

DOCNAME  := CPEX-0050-solution-representation
TEXFILE  := $(DOCNAME).tex
PDF      := $(DOCNAME).pdf

# Prefer latexmk (handles multi-pass automatically); fall back to pdflatex
LATEXMK  := $(shell command -v latexmk 2>/dev/null)
PDFLATEX := $(shell command -v pdflatex 2>/dev/null)

ifdef LATEXMK
  BUILD_CMD = latexmk -pdf -halt-on-error -interaction=nonstopmode $(TEXFILE)
  CLEAN_CMD = latexmk -C $(TEXFILE)
else ifdef PDFLATEX
  # Three-pass manual build (for cross-references / hyperref)
  define BUILD_CMD
    pdflatex -halt-on-error -interaction=nonstopmode $(TEXFILE) && \
    pdflatex -halt-on-error -interaction=nonstopmode $(TEXFILE) && \
    pdflatex -halt-on-error -interaction=nonstopmode $(TEXFILE)
  endef
  CLEAN_CMD = true  # handled by AUX_FILES below
else
  $(error Neither latexmk nor pdflatex found. Install a TeX distribution.)
endif

# PDF viewer: prefer evince, then xdg-open, then okular
VIEWER := $(or \
  $(shell command -v evince   2>/dev/null), \
  $(shell command -v xdg-open 2>/dev/null), \
  $(shell command -v okular   2>/dev/null), \
  $(shell command -v open     2>/dev/null))

AUX_FILES := $(DOCNAME).aux $(DOCNAME).log $(DOCNAME).out \
             $(DOCNAME).toc $(DOCNAME).lof $(DOCNAME).lot \
             $(DOCNAME).fls $(DOCNAME).fdb_latexmk \
             $(DOCNAME).synctex.gz $(DOCNAME).bbl $(DOCNAME).blg

.PHONY: all pdf view clean distclean

all: pdf

pdf: $(PDF)

$(PDF): $(TEXFILE)
	$(BUILD_CMD)

view: $(PDF)
ifdef VIEWER
	$(VIEWER) $(PDF) &
else
	$(error No PDF viewer found. Open $(PDF) manually.)
endif

clean:
	$(CLEAN_CMD)
	$(RM) $(AUX_FILES)

distclean: clean
	$(RM) $(PDF)
