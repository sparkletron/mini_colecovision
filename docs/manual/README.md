# Latex to jpg
pdflatex -jobname=REG -shell-escape -interaction=batchmode '\documentclass{article}\usepackage{multirow}\usepackage{lscape}\usepackage{graphics}\begin{document}\pagenumbering{gobble}\input{test.tex}\end{document}'
pdftoppm -gray -r 300 -jpeg test.pdf > test.jpg
convert -trim test.jpg newtest.jpg


# get each html page, and output a pdf of it to ../../name.pdf then run the latex doc with the include pdfs?
wkhtmltopdf --enable-local-file-access axi_lite_1553-v.html test.pdf

# generate jpg diagrams

# generate html of static latex html version (latex2html)
# generate html of natural docs (naturaldocs)
# generate pdf of natural docs files html pages (wkhtmltopdf)
# generate pdf of static latex pdf version, run twice to get TOC (pdflatex)
# generate markdown of static latex md version. (pandoc latex/gfm) (output to wiki repo)
