# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

XSLT_FILES := $(wildcard $(MKFILE_DIR)xslt/*.xsl)
XSLT_DIR   := $(MKFILE_DIR)/xslt

#######################
all: documentation volumes volume-index articles

#######################
# documentation
DOC_DIR      := $(MKFILE_DIR)documentation
DOC_OUTDIR   := $(MKFILE_DIR)site
DOC_FILES    := $(wildcard $(DOC_DIR)/*.html)

.PHONY: documentation
documentation: $(subst $(DOC_DIR),$(DOC_OUTDIR),$(DOC_FILES))

$(DOC_OUTDIR)/%.html: $(DOC_DIR)/%.html $(XSLT_FILES)
	xsltproc $(MKFILE_DIR)xslt/documentation.xsl $< > $@

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

$(VOLUMES_OUTDIR)/%.html: $(VOLUMES_DIR)/%.xml
	xsltproc $(MKFILE_DIR)xslt/volume.xsl $< > $@

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

$(ARTICLES_OUTDIR)/%.html: $(ARTICLES_DIR)/%.xml
	xsltproc $(MKFILE_DIR)xslt/article-full.xsl $< > $@
