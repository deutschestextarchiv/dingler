# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

XSLT_FILES := $(wildcard $(MKFILE_DIR)xslt/*.xsl)
XSLT_DIR   := $(MKFILE_DIR)/xslt

#######################
all: documentation volumes volume-index article-listings articles tabs

#######################
# documentation
DOC_DIR      := $(MKFILE_DIR)documentation
DOC_OUTDIR   := $(MKFILE_DIR)site
DOC_FILES    := $(wildcard $(DOC_DIR)/*.html)

.PHONY: documentation
documentation: $(subst $(DOC_DIR),$(DOC_OUTDIR),$(DOC_FILES))

$(DOC_OUTDIR)/%.html: $(DOC_DIR)/%.html $(XSLT_FILES)
	xsltproc --stringparam page "$(notdir $<)" $(MKFILE_DIR)xslt/documentation.xsl $< > $@

.PHONY: encoding
encoding: $(DOC_DIR)/encoding.xml $(XSLT_FILES)
	 saxonb-xslt -ext:on $< $(MKFILE_DIR)xslt/encoding.xsl > $(DOC_OUTDIR)/encoding.html

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
	xsltproc $(MKFILE_DIR)xslt/volume.xsl $< > $@

#######################
# article listings per volume
ARTICLE_LISTINGS_OUTDIR := $(MKFILE_DIR)site/article-listings

.PHONY: article-listings
article-listings: $(subst $(VOLUMES_DIR),$(ARTICLE_LISTINGS_OUTDIR),$(VOLUMES_FILES:.xml=.html)) $(XSLT_FILES)

$(ARTICLE_LISTINGS_OUTDIR):
	mkdir -p $(ARTICLE_LISTINGS_OUTDIR)

$(ARTICLE_LISTINGS_OUTDIR)/%.html: $(VOLUMES_DIR)/%.xml $(XSLT_FILES)
	xsltproc $(MKFILE_DIR)xslt/article-listing.xsl $< > $@

#######################
# volume index
.PHONY: volume-index
volume-index:
	mkdir -p $(VOLUMES_OUTDIR)
	{ \
	  echo '<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">'; \
	  for i in $(VOLUMES_DIR)/*.xml; \
		do b=`basename "$$i" .xml`; \
		xsltproc $(MKFILE_DIR)xslt/volume-single.xsl "$$i"; \
	  done; \
	  echo '</teiCorpus>'; \
	} | xsltproc $(MKFILE_DIR)xslt/volume-listing.xsl - > $(VOLUMES_OUTDIR)/index.html

#######################
# articles
ARTICLES_DIR      := $(MKFILE_DIR)../data/articles
ARTICLES_OUTDIR   := $(MKFILE_DIR)site/articles
ARTICLES_FILES    := $(wildcard $(ARTICLES_DIR)/*.xml)

.PHONY: articles
articles: $(subst $(ARTICLES_DIR),$(ARTICLES_OUTDIR),$(ARTICLES_FILES:.xml=.html)) $(XSLT_FILES)

$(ARTICLES_FILES): | $(ARTICLES_OUTDIR)

$(ARTICLES_OUTDIR):
	mkdir -p $(ARTICLES_OUTDIR)

$(ARTICLES_OUTDIR)/%.html: $(ARTICLES_DIR)/%.xml $(XSLT_FILES)
	xsltproc $(MKFILE_DIR)xslt/article-full.xsl $< > $@

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
	saxonb-xslt -ext:on $(MKFILE_DIR)../sources/database/persons/persons.xml $(MKFILE_DIR)xslt/persons.xsl > $(MKFILE_DIR)site/persons/index.html

#######################
# journal register
.PHONY: journal-register
journal-register: $(MKFILE_DIR)../sources/database/journals/journals.xml $(MKFILE_DIR)xslt/journals.xsl
	saxonb-xslt -ext:on $(MKFILE_DIR)../sources/database/journals/journals.xml $(MKFILE_DIR)xslt/journals.xsl > $(MKFILE_DIR)site/journals/index.html
