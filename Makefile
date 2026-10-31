# Build the worksheets and their answer keys.
#
#   make dependencies   install a TeX distribution with the required packages
#   make build          build <doc>.pdf and <doc>-solutions.pdf for each
#                       document in DOCS
#   make clean          remove build artefacts
#
# Build a single document with e.g. `make build DOCS=irregular-verbs`.

# (not TEX: make predefines TEX=tex, which would defeat ?=)
PDFLATEX ?= pdflatex
TEXFLAGS ?= -interaction=nonstopmode -halt-on-error -file-line-error
DOCS     ?= exercises irregular-verbs
STY      := worksheet.sty

WORKSHEETS := $(addsuffix .pdf,$(DOCS))
SOLUTIONS  := $(addsuffix -solutions.pdf,$(DOCS))
AUXFILES   := $(foreach d,$(DOCS) $(addsuffix -solutions,$(DOCS)), \
                $(d).aux $(d).log $(d).out)

# Distribution packages providing: geometry, tikz/pgf, xcolor, booktabs,
# enumitem, fancyhdr, microtype, TeX Gyre fonts (Heros, Chorus), expl3.
APT_PACKAGES    := make texlive-latex-base texlive-latex-recommended \
                   texlive-latex-extra texlive-pictures texlive-fonts-recommended \
                   tex-gyre
DNF_PACKAGES    := make texlive-scheme-basic texlive-collection-latexrecommended \
                   texlive-collection-latexextra texlive-collection-pictures \
                   texlive-collection-fontsrecommended
PACMAN_PACKAGES := make texlive-basic texlive-latex texlive-latexrecommended \
                   texlive-latexextra texlive-pictures texlive-fontsrecommended
TLMGR_PACKAGES  := l3kernel l3packages geometry pgf xcolor booktabs enumitem \
                   fancyhdr microtype tex-gyre tools

.PHONY: all build dependencies clean

all: build

build: $(WORKSHEETS) $(SOLUTIONS)

$(WORKSHEETS): %.pdf: %.tex $(STY)
	$(PDFLATEX) $(TEXFLAGS) -jobname=$* $<

$(SOLUTIONS): %-solutions.pdf: %.tex $(STY)
	$(PDFLATEX) $(TEXFLAGS) -jobname=$*-solutions \
	  '\def\WorksheetSolutions{}\input{$<}'

dependencies:
	@if command -v apt-get >/dev/null 2>&1; then \
	  sudo apt-get update && \
	  sudo apt-get install -y --no-install-recommends $(APT_PACKAGES); \
	elif command -v dnf >/dev/null 2>&1; then \
	  sudo dnf install -y $(DNF_PACKAGES); \
	elif command -v pacman >/dev/null 2>&1; then \
	  sudo pacman -S --needed --noconfirm $(PACMAN_PACKAGES); \
	elif command -v tlmgr >/dev/null 2>&1; then \
	  tlmgr install $(TLMGR_PACKAGES); \
	else \
	  echo "No supported package manager found (apt-get, dnf, pacman, tlmgr)." >&2; \
	  echo "Install TeX Live with: $(TLMGR_PACKAGES)" >&2; \
	  exit 1; \
	fi

clean:
	rm -f $(AUXFILES) $(WORKSHEETS) $(SOLUTIONS)
