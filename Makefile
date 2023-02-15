# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))
SCRIPT_DIR  := $(MKFILE_DIR)scripts

#######################
all: articles

ARTICLES_DIR   := $(MKFILE_DIR)data/articles
VOLUMES_DIR    := $(MKFILE_DIR)sources/volumes
VOLUMES_FILES  := $(wildcard $(VOLUMES_DIR)/*.xml)

.PHONY: articles
articles: $(subst pj, article-extraction-, $(VOLUMES_FILES:.xml=))
	@echo $<
	@echo $?

article-extraction-%: $(VOLUMES_DIR)/pj%.xml
	@mkdir -p $(ARTICLES_DIR)
	saxonb-xslt -ext:on $< $(SCRIPT_DIR)/extract_articles.xsl volume-id="$(basename $(notdir $<))" outdir=$(ARTICLES_DIR) >/dev/null
