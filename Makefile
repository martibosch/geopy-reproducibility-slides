html:
	pandoc -t revealjs -s -i slides/slides.md -o index.html --slide-level=2 -V revealjs-url=./ -f markdown+emoji --mathjax --css css/custom.css
