# Dingler Online

This repository contains all data created and compiled by the
DFG project “Digitalisierung des Polytechnischen Journals”.

NB: **Any facsimile images and generated content to run a website are
not included.**

## A website with minimal requirements

## Prerequisites to generate a static website

- [GNU make](https://www.gnu.org/software/make/) (maybe other `make`s will fit)
- [xsltproc](https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home)

## Building a static website

```bash
make -C web all

# or, when you’re impatient and have the power of multi-cores:
make -C web all -j 10
```

## Running a static website

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

## TODO

### Images

- [ ] XSLT processing for IMT
- [ ] thumbnail generation

### Search

- [ ] basic dstar search
- [ ] documentation
- [ ] time series plots

### Registers

- [ ] patents
- [ ] persons
- [ ] sources
- [ ] tables (aka figures)

### Article rendering

- [ ] figure tables, resp. IMT XML embedding
- [ ] footnotes
- [ ] keyword cloud (most common nouns)
- [ ] links to SLUB

### Downloadable packages

- [ ] journals
- [ ] articles
- [ ] CMDI files

### Miscellaneous stuff

- [ ] GND/BEACON file
- [ ] list of curious articles

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
      * `css`: CSS files
      * `fonts`: font files
      * `images`: image files
      * `js`: Javascript files