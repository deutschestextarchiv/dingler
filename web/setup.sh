#!/usr/bin/env bash
  
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

DIR_ARTICLES=site/articles
DIR_JOURNALS=site/journals

#echo "Generating article HTML files ..."
#mkdir -p "$DIR_ARTICLES"
#for i in sources/articles/*.xml; do
#  b=`basename "$i" .xml`
#  echo "  $b ..."
#  xsltproc xslt/article-full.xsl "$i" > "$DIR_ARTICLES"/"$b".html
#done

echo "Generating journal index ..."
{
  echo '<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">'
  for i in sources/journals/*.xml; do
    b=`basename "$i" .xml`
    xsltproc xslt/journal-single.xsl "$i";
  done
  echo '</teiCorpus>'
} | xsltproc xslt/journal-listing.xsl - > "$DIR_JOURNALS"/index.html

echo "Generating static documentation HTML files ..."
for i in documentation/*.html; do
  b=`basename "$i" .html`
  echo "  $b ..."
  xsltproc xslt/documentation.xsl "$i" > html/"$b".html
done

echo "Generating journal listing HTML files ..."
mkdir -p "$DIR_JOURNALS"
for i in sources/journals/*.xml; do
  b=`basename "$i" .xml`
  echo "  $b ..."
  xsltproc xslt/journal.xsl "$i" > "$DIR_JOURNALS"/"$b".html
done

echo "Generating article HTML files ..."
mkdir -p "$DIR_ARTICLES"
for i in sources/articles/*.xml; do
  b=`basename "$i" .xml`
  echo "  $b ..."
  xsltproc xslt/article-full.xsl "$i" > "$DIR_ARTICLES"/"$b".html
done
