# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))

SCRIPT_DIR   := $(MKFILE_DIR)/scripts

#######################
all: articles

ARTICLES_DIR   := $(MKFILE_DIR)/data/articles
VOLUMES_DIR    := $(MKFILE_DIR)/sources/volumes
VOLUMES_FILES  := $(wildcard $(VOLUMES_DIR)/*.xml)

$(ARTICLES_DIR):
	mkdir -p $(ARTICLES_DIR)

$(ARTICLES_FILES): | $(ARTICLES_DIR)

$(ARTICLES_FILES)/%.xml: | $(VOL_DIR)

articles:
	for i in $(VOLUMES_DIR)/pj*.xml; do \
	  b=`basename "$$i" .xml`; \
	  saxonb-xslt -ext:on "$$i" $(SCRIPT_DIR)/extract_articles.xsl outdir=$(ARTICLES_DIR) >/dev/null; \
	done
