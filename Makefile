# vim: set noexpandtab
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))
SCRIPT_DIR  := $(MKFILE_DIR)scripts

#######################
all: articles web

ARTICLES_DIR   := $(MKFILE_DIR)data/articles
VOLUMES_DIR    := $(MKFILE_DIR)sources/volumes
VOLUMES_FILES  := $(wildcard $(VOLUMES_DIR)/pj*.xml)

#######################
.PHONY: articles
articles: $(subst pj, article-extraction-, $(VOLUMES_FILES:.xml=))

article-extraction-%: $(VOLUMES_DIR)/pj%.xml
	@mkdir -p $(ARTICLES_DIR)
	saxonb-xslt -ext:on -s:$< -xsl:$(SCRIPT_DIR)/extract_articles.xsl volume-id="$(basename $(notdir $<))" outdir=$(ARTICLES_DIR) >/dev/null

#######################
.PHONY: web
web:
	$(MAKE) -C web all

#######################
.PHONY: publish
publish:
	rsync -av --exclude images web/site/ dingler:/var/www/dingler/web/site
