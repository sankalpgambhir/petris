# Makefile for papers
MAIN = main
.PHONY: clean spell fresh wipe

all: 	fresh

$(MAIN).pdf: *.tex #*.bib *.cls
	latexmk -pdf $(MAIN).tex

spell:
	for f in `find . -name "*.tex"`; do aspell -t -l en_us -c $$f; done;
#	aspell -t -l en_us -c $(MAIN).tex

zip:
	zip -r $(MAIN).zip *.tex */*.tex *.bib *.cls *.bbl

uzip:
	unzip Sugar-synth.zip

clean:
	@rm -f $(MAIN).aux $(MAIN).bbl $(MAIN).blg $(MAIN).bst $(MAIN).dvi $(MAIN).fdb_latexmk $(MAIN).fls $(MAIN).idx $(MAIN).lof $(MAIN).log $(MAIN).nav $(MAIN).out $(MAIN).snm $(MAIN).synctex.gz $(MAIN).toc $(MAIN).log $(MAIN).aux $(MAIN).fdb_latekmx $(MAIN).fls
	@rm -f $(MAIN).zip
	@rm -rf auto
	@rm -f *.bak */*.bak *.auto *.log */*.log *~ */*~ */texput.log
	
wipe:
	@rm -f $(MAIN).aux $(MAIN).bbl $(MAIN).blg $(MAIN).bst $(MAIN).dvi $(MAIN).fdb_latexmk $(MAIN).fls $(MAIN).idx $(MAIN).lof $(MAIN).log $(MAIN).nav $(MAIN).out $(MAIN).snm $(MAIN).synctex.gz $(MAIN).toc $(MAIN).log $(MAIN).aux $(MAIN).fdb_latekmx $(MAIN).fls $(MAIN).pdf
	@rm -f $(MAIN).zip
	@rm -rf auto
	@rm -f *.bak */*.bak *.auto *.log */*.log *~ */*~ */texput.log

fresh:	wipe $(MAIN).pdf clean
