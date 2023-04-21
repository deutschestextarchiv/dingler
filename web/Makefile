# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

XSLT_FILES := $(wildcard $(MKFILE_DIR)xslt/*.xsl)
XSLT_DIR   := $(MKFILE_DIR)/xslt

BASE_URL ?= /

#######################
all: documentation encoding volumes volume-index article-listings articles-saxon

#######################
# documentation
DOC_DIR      := $(MKFILE_DIR)documentation
DOC_OUTDIR   := $(MKFILE_DIR)site
DOC_FILES    := $(wildcard $(DOC_DIR)/*.html)

.PHONY: documentation
documentation: $(subst $(DOC_DIR),$(DOC_OUTDIR),$(DOC_FILES))

$(DOC_OUTDIR)/%.html: $(DOC_DIR)/%.html $(XSLT_FILES)
	saxonb-xslt -ext:on -s:$< -xsl:$(MKFILE_DIR)xslt/documentation.xsl -o:$@ base="$(BASE_URL)" page="$(notdir $<)"

.PHONY: encoding
encoding: $(DOC_DIR)/encoding.xml $(XSLT_FILES)
	saxonb-xslt -ext:on -s:$< -xsl:$(MKFILE_DIR)xslt/encoding.xsl -o:$(DOC_OUTDIR)/encoding.html base="$(BASE_URL)"

#######################
# volumes
VOLUMES_DIR      := $(MKFILE_DIR)../sources/volumes
VOLUMES_OUTDIR   := $(MKFILE_DIR)site/volumes
VOLUMES_FILES    := $(wildcard $(VOLUMES_DIR)/*.xml)

.PHONY: volumes
volumes: $(subst $(VOLUMES_DIR),$(VOLUMES_OUTDIR),$(VOLUMES_FILES:.xml=.html)) $(XSLT_FILES)

$(VOLUMES_FILES): | $(VOLUMES_OUTDIR)

$(VOLUMES_OUTDIR):
	mkdir -p $(VOLUMES_OUTDIR)

$(VOLUMES_OUTDIR)/%.html: $(VOLUMES_DIR)/%.xml $(XSLT_FILES)
	saxonb-xslt -ext:on -s:$< -xsl:$(MKFILE_DIR)xslt/volume.xsl -o:$@ base="$(BASE_URL)"

#######################
# article listings per volume
ARTICLE_LISTINGS_OUTDIR := $(MKFILE_DIR)site/article-listings

.PHONY: article-listings
article-listings: $(subst $(VOLUMES_DIR),$(ARTICLE_LISTINGS_OUTDIR),$(VOLUMES_FILES:.xml=.html)) $(XSLT_FILES)

$(ARTICLE_LISTINGS_OUTDIR):
	mkdir -p $(ARTICLE_LISTINGS_OUTDIR)

$(ARTICLE_LISTINGS_OUTDIR)/%.html: $(VOLUMES_DIR)/%.xml $(XSLT_FILES)
	saxonb-xslt -ext:on -s:$< -xsl:$(MKFILE_DIR)xslt/article-listing.xsl -o:$@ base="$(BASE_URL)"

#######################
# volume index
.PHONY: volume-index
volume-index:
	mkdir -p $(VOLUMES_OUTDIR)
	{ \
	  echo '<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">'; \
	  for i in $(VOLUMES_DIR)/pj???.xml; \
		do b=`basename "$$i" .xml`; \
		echo [volume-index] parsing $$b … 1>&2; \
		saxonb-xslt -s:"$$i" -xsl:$(MKFILE_DIR)xslt/volume-single.xsl; \
	  done; \
	  echo '</teiCorpus>'; \
	} | saxonb-xslt -ext:on -s:- -xsl:$(MKFILE_DIR)xslt/volume-listing.xsl -o:$(VOLUMES_OUTDIR)/index.html base="$(BASE_URL)"

#######################
# articles
ARTICLES_DIR      := $(MKFILE_DIR)../data/articles
ARTICLES_OUTDIR   := $(MKFILE_DIR)site/articles
ARTICLES_FILES    := $(wildcard $(ARTICLES_DIR)/*.xml)

.PHONY: articles-saxon
articles-saxon:
	saxonb-xslt -t -ext:on -s:$(ARTICLES_DIR) -xsl:$(MKFILE_DIR)xslt/article-full.xsl -o:$(ARTICLES_OUTDIR) base="$(BASE_URL)" 2>&1 | grep "Processing file"

.PHONY: articles-libxslt
articles-libxslt: $(subst $(ARTICLES_DIR),$(ARTICLES_OUTDIR),$(ARTICLES_FILES:.xml=.html)) $(XSLT_FILES)

$(ARTICLES_FILES): | $(ARTICLES_OUTDIR)

$(ARTICLES_OUTDIR):
	mkdir -p $(ARTICLES_OUTDIR)

$(ARTICLES_OUTDIR)/%.html: $(ARTICLES_DIR)/%.xml $(XSLT_FILES)
	xsltproc -o $@ --stringparam base "$(BASE_URL)" $(MKFILE_DIR)xslt/article-full.xsl $<

#######################
# page mapping


#######################
# tabs
.PHONY: tabs
TABS_OUTDIR := $(MKFILE_DIR)site/tabs
tabs:	
	for i in $(VOLUMES_DIR)/*/*.xml; \
	  do b=`basename "$$i" .xml`; \
	  xsltproc $(MKFILE_DIR)xslt/imt.xsl "$$i" > $(TABS_OUTDIR)/"$$b".html; \
	done; \

#######################
# person register
.PHONY: person-register
person-register: $(MKFILE_DIR)../sources/database/persons/persons.xml $(MKFILE_DIR)xslt/persons.xsl
	saxonb-xslt -ext:on -xsl:$(MKFILE_DIR)xslt/persons.xsl -s:$(MKFILE_DIR)../sources/database/persons/persons.xml -o:$(MKFILE_DIR)site/persons/index.html base="$(BASE_URL)"

#######################
# journal register
.PHONY: journal-register
journal-register: $(MKFILE_DIR)../sources/database/journals/journals.xml $(MKFILE_DIR)xslt/journals.xsl
	saxonb-xslt -ext:on -xsl:$(MKFILE_DIR)xslt/journals.xsl -s:$(MKFILE_DIR)../sources/database/journals/journals.xml -o:$(MKFILE_DIR)site/journals/index.html base="$(BASE_URL)"
