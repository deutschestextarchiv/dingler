# Dingler Online

This repository contains all data created and compiled by the
DFG project “Digitalisierung des Polytechnischen Journals”.

NB: **Any facsimile images and generated content to run a website are
not included.**

## Building a website with minimal requirements

### Prerequisites to generate a static website

- [GNU make](https://www.gnu.org/software/make/) (maybe other `make`s will fit)
- [saxonb-xslt](https://saxon.sourceforge.net/) (available in Debian-like Linux distributions via `libsaxonb-java`)

### Install MathJax as git submodule

```bash
git submodule init
git submodule update
```

### Extract articles from volumes and build a static website

```bash
make articles
make -C web all

# or, when you’re impatient and have the power of multi-cores:
make articles -j4
make -C web all -j4
```

## How to run a static website

Apache configuration snippet, assuming your checkout resides under
`/var/www/dingler` and you want to serve the site as `/dingler`:

```apache
<Directory /var/www/dingler/web/site>
  DirectoryIndex index.html
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
Alias /dingler /var/www/dingler/web/site
```

## How to obtain facsimile images

Go to the SLUB pages and grab them from there.

## Progress of this project

### Build

- [x] extract articles and miscellanea from volumes
  - [x] add volume id (eg. *pjXXX*) to article/miscellanea file
  - [x] adjust URLs in `<idno type="URLXML">` for volumes and articles

### Website

- [x] index page and documentation
- [x] create volume index
- [x] HTML version of volumes
- [x] HTML version of articles:
  - [x] link facsimile
- [x] link to XML sources
- styling TEI elements within `<text>`:
  - [x] `<add>`
  - [ ] `<bibl>`
  - [x] `<cb>`
  - [x] `<cell>`
  - [ ] `<choice>`
    - [x] `<sic>`/`<corr>`
  - [x] `<date>`
  - [x] `<div>`
  - [ ] `<div type="continuation">`
  - [x] `<figure>`
  - [x] `<formula>`
  - [x] `<front>`
  - [x] `<head>`
  - [x] `<hi>`
  - [x] `<item>`
  - [x] `<l>`
  - [x] `<lb>`
  - [x] `<lg>`
  - [x] `<list>`
  - [x] `<milestone>`
  - [x] `<note>`
  - [x] `<p>`
  - [x] `<pb>`
  - [x] `<persName>`
  - [x] `<placeName>`
  - [ ] `<q>`
  - [x] `<ref>` (to articles)
  - [x] `<row>`
  - [x] `<table>`
  - [x] `<titlePart>`
  - [x] `<unclear>`

### Images

- [ ] XSLT processing for IMT
- [ ] thumbnail generation

### Search

- [x] basic dstar search
- [x] documentation
- [ ] time series plots

### Registers

- [ ] patents
- [ ] persons
- [ ] sources
- [ ] tables (aka figures)

### Article rendering

- [ ] figure tables, resp. IMT XML embedding
- [x] footnotes
- [ ] keyword cloud (most common nouns)
- [x] links to SLUB

### Downloadable packages

- [ ] journals
- [ ] articles
- [ ] CMDI files

### Miscellaneous stuff

- [ ] GND/BEACON file
- [ ] list of curious articles
- [ ] 404 page
- [x] use dwds.de search API

## Directory structure

* `data`: generated files
  * `articles`: articles extracted from volumes
  * `cmdi`: CMDI metadata for articles
* `images`: facsimile images
* `scripts`: processing tools
* `sources`: project sources
  * `volumes`: volumes as TEI P5 XML
    * `…/$volume`: table figures
* `web`: files for web presentation 
  * `documentation`: project documentation
  * `site`: (generated) site content
    * `assets`: static site assets
      * `bootstrap`: Bootstrap files
      * `css`: CSS files
      * `fonts`: font files
      * `images`: image files
      * `js`: Javascript files
  * `xslt`: XSLT files for various pages

## Known issues

- [ ] faksimiles for vol. 8 are dis-ordered
- [ ] vol. 12: lot of thumbnails only instead of real size images
