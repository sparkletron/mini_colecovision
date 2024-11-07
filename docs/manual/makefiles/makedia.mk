SRCDIR=src

HTML_DIR=html
ND_HTML=$(HTML_DIR)/index.html
ND_HTML_FILES=$(wildcard $(HTML_DIR)/files/*.html)
ND_PDF=$(notdir $(ND_HTML_FILES:.html=.pdf))

DIAGRAM_DIR=$(SRCDIR)/diagrams
DIAGRAM_OUT_DIR=img/diagrams
DIAGRAM_LAT=$(wildcard $(DIAGRAM_DIR)/*.tex)
DIAGRAM_PDF=$(notdir $(DIAGRAM_LAT:.tex=.pdf))
DIAGRAM_JPG=$(DIAGRAM_PDF:.pdf=.png)

.PHONY: clean

#html bug breaks this
all: $(DIAGRAM_JPG)

#-r 300
%.png: %.pdf
	pdftoppm -gray -r 300 -png $^ > $@
	rm $^
	convert -trim $@ $@
	rm $(basename $@).log $(basename $@).aux
	mkdir -p $(DIAGRAM_OUT_DIR)
	mv $@ $(DIAGRAM_OUT_DIR)/$@

%.pdf: $(DIAGRAM_DIR)/%.tex
	pdflatex -jobname=$(basename $@) -shell-escape -interaction=batchmode '\documentclass{article}\usepackage{DejaVuSans}\renewcommand{\familydefault}{\sfdefault}\usepackage[T1]{fontenc}\usepackage{multirow}\usepackage{lscape}\usepackage{graphics}\begin{document}\pagenumbering{gobble}\input{$^}\end{document}'

clean:
	rm -rf $(DIAGRAM_OUT_DIR)/*.jpg


