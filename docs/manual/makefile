PROJECT_NAME := mini_colecovision

MK_DIR := makefiles

export PROJECT_NAME

.PHONY: clean GEN_FUSESOC_CORE_LATEX FUSSOC_CORE_LATEX_CLEAN GEN_HTML HTML_CLEAN GEN_PDF PDF_CLEAN GEN_DIAGRAMS DIAGRAMS_CLEAN #GEN_WIKI WIKI_CLEAN

all: GEN_FUSESOC_CORE_LATEX GEN_DIAGRAMS GEN_HTML GEN_PDF #GEN_WIKI

GEN_FUSESOC_CORE_LATEX:
	$(MAKE) -f $(MK_DIR)/makefuselatex.mk

GEN_HTML:
	$(MAKE) -f $(MK_DIR)/makehtml.mk

GEN_PDF: GEN_HTML
	$(MAKE) -f $(MK_DIR)/makepdf.mk

GEN_DIAGRAMS:
	$(MAKE) -f $(MK_DIR)/makedia.mk

# GEN_WIKI:
# 	$(MAKE) -f $(MK_DIR)/makewiki.mk

clean: FUSSOC_CORE_LATEX_CLEAN HTML_CLEAN PDF_CLEAN DIAGRAMS_CLEAN #WIKI_CLEAN

FUSSOC_CORE_LATEX_CLEAN:
	$(MAKE) -f $(MK_DIR)/makefuselatex.mk clean

HTML_CLEAN:
	$(MAKE) -f $(MK_DIR)/makehtml.mk clean

PDF_CLEAN:
	$(MAKE) -f $(MK_DIR)/makepdf.mk clean

DIAGRAMS_CLEAN:
	$(MAKE) -f $(MK_DIR)/makedia.mk clean

# WIKI_CLEAN:
# 	$(MAKE) -f $(MK_DIR)/makewiki.mk clean
