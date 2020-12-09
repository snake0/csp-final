THESIS = csp-final
# TEX, BIB, TEST dir
TEX_DIR = tex
BIB_DIR = bib

# Option for latexmk
LATEXMK_OPT_BASE = -xelatex -gg -silent
LATEXMK_OPT = $(LATEXMK_OPT_BASE) -f
LATEXMK_OPT_PVC = $(LATEXMK_OPT_BASE) -pvc

all: $(THESIS).pdf

.PHONY : all cleanall pvc view wordcount git zip

$(THESIS).pdf : $(THESIS).tex *.bib elegantpaper.cls elegantpaper.cfg Makefile
	-latexmk $(LATEXMK_OPT) $(THESIS)

pvc :
	latexmk $(LATEXMK_OPT_PVC) $(THESIS)

validate :
	xelatex -no-pdf -halt-on-error $(THESIS)
	biber --debug $(THESIS)

view : $(THESIS).pdf
	open $<

wordcount:
	@perl texcount.pl $(THESIS).tex -inc          | awk '/total/ {getline; print "词数　　:",$$4}' 
	@perl texcount.pl $(THESIS).tex -inc -char    | awk '/total/ {getline; print "字符数　:",$$4}' 
	@perl texcount.pl $(THESIS).tex -inc -ch-only | awk '/total/ {getline; print "中文字数:",$$4}' 

clean :
	-@latexmk -c -silent 2> /dev/null
	-@rm -f $(TEX_DIR)/*.aux 2> /dev/null || true

cleanall :
	-@latexmk -C -silent 2> /dev/null
	-@rm -f $(TEX_DIR)/*.aux 2> /dev/null || true

s3 : $(THESIS).pdf
	s3cmd put $< s3://sjtuthesis/README.pdf

git :
	git push --tags github; git push github;
	git push --tags gitlab; git push gitlab; 

zip :
	git archive --format zip --output thesis.zip master

ew :
	cat tex/end_english_abstract.tex |grep -o -E "[A-Za-z]+" |grep -o -E "[A-Za-z]+" |wc -m