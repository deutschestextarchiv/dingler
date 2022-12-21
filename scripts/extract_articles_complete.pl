#!/usr/bin/perl

use 5.03;
use warnings;

use utf8;
use File::Basename qw(basename);
use File::Path qw(make_path);
use File::Temp qw(tempfile);
use Getopt::Long;
use XML::LibXML;
use XML::LibXSLT;

binmode( STDOUT, ':utf8' );

my ($source, $target, $help, $man, $verbose);

$dir = '/home/fw/dingler';
$svn = '/media/fw/dingler/home/fw/src/kuwi/dingler';

GetOptions(
    'source=s'  => \$source,
    'target=s'  => \$target,
    'help|?'    => \$help,
    'man|h'     => \$man,
    'verbose|v' => \$verbose,
) or pod2usage(2);
pod2usage(1) if $help;

my $xpc = XML::LibXML::XPathContext->new;
$xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );

my $parser = XML::LibXML->new;
my $xslt = XML::LibXSLT->new;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $today = sprintf '%04d-%02d-%02d', $year+1900, $mon+1, $mday;

my $i = 0;
foreach my $file ( glob sprintf '%s/dingler-articles/*.xml', $dir ) {
    my $id = basename($file) =~ s/\..*//r;
    say $id;

    open( my $fh, '<:utf8', $file ) or die $!;
    my $xml; $xml = do { local $/; <$fh> };
    close $fh;

    $xml =~ s{(<teiHeader>)(.*)(</teiHeader>)}{$1 . norm_chars($2) . $3}se;

    my ($journal) = grep { !/_mets/ } glob sprintf('%s/pj%s/*.xml', $svn, $id =~ /^(?:ar|mi)(\d{3})/);
    die "$file: no journal file found" if !$journal;
    my $barcode = basename $journal, '.xml';

    my %xslt_params = (
        XML::LibXSLT::xpath_to_string( barcode => $barcode ),
        XML::LibXSLT::xpath_to_string( id      => $id ),
        XML::LibXSLT::xpath_to_string( today   => $today ),
    );

    my $article_source = XML::LibXML->load_xml( string => $xml ) or die $!;
    my $style_doc = XML::LibXML->load_xml( location => 'article2article.xsl' );
    my $stylesheet = $xslt->parse_stylesheet($style_doc);

    my $results = $stylesheet->transform( $article_source, %xslt_params );
    my $res = $stylesheet->output_as_chars($results);
    my $pretty = pretty($res);

    my $article_file = sprintf '%s/new-articles/%s.xml', $dir, $id;
    open( $fh, '>:utf8', $article_file ) or die $!;
    print $fh $pretty;
    close $fh;

    # CMDI
    $article_source = XML::LibXML->load_xml( location => $article_file ) or die $!;
    $style_doc = XML::LibXML->load_xml( location => 'article2cmdi.xsl' );
    $stylesheet = $xslt->parse_stylesheet($style_doc);

    $results = $stylesheet->transform( $article_source, %xslt_params );
    $res = $stylesheet->output_as_chars($results);
    $pretty = pretty($res);

    my $cmdi_file = sprintf '%s/cmdi/%s.cmdi.xml', $dir, $id;
    open( $fh, '>:utf8', $cmdi_file ) or die $!;
    print $fh $pretty;
    close $fh;
}

sub norm_chars {
    my $str = shift;
    for ( $str ) {
        s/ſ/s/g;
        s/aͤ/ä/g;
        s/oͤ/ö/g;
        s/uͤ/ü/g;
        s/ - / – /g;
        s/S\. (\d)-(\d)/S. $1–$2/g;
    }
    return $str;
}

sub pretty {
    my $in = shift;
    my ($tempfh, $tempname) = tempfile( DIR => '/tmp/' );
    binmode( $tempfh, ":utf8" );
    print $tempfh $in;
    close $tempfh;

    my $pretty = join '' => `xmllint --encode utf8 -format "$tempname" 2>&1 | tail -n +2`;
    unlink $tempname;

    utf8::decode($pretty);
    $pretty = '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . $pretty;
    return $pretty;
}

__END__

    my $a_lx; eval { $a_lx = $parser->load_xml(string => $xml); 1 };
    die $@ if $@;

    my ($journal) = grep { !/_mets/ } glob sprintf('%s/pj%s/*.xml', $svn, $id =~ /^(?:ar|mi)(\d{3})/);
    die "$file: no journal file found";
    my $barcode = basename $journal, '.xml';

    my $j_lx; eval { $j_lx = $parser->load_xml(location => $journal); 1 };
    die $@ if $@;

    my $article_xml = $a_lx->toString(1);
    for ( $article_xml ) {
    }

    my %m; # meta data
    $m{id} = $id;
    $m{article_type} = $r->{type};

    # Haupttitel
    if ( $r->{type} eq 'misc_undef' ) {
        my ($title_main) = $xpc->findnodes( "//*[\@xml:id='$id']//tei:head", $article );
        $m{title_main} = $title_main ? normalize( $title_main->textContent ) : '[Ohne Titel]';
    }
    else {
        my ($title_main) = $xpc->findnodes( "//*[\@xml:id='$id']//tei:titlePart[\@type='main']", $article );
        next unless $title_main;
        $m{title_main} = normalize( $title_main->textContent );
    }

    # Untertitel
    my @title_sub;
    foreach my $title_sub ( $xpc->findnodes( "//*[\@xml:id='$id']//tei:titlePart[\@type='sub']", $article ) ) {
        push @{ $m{title_sub} }, normalize( $title_sub->textContent );
    }

    # Haupttitel der Zeitschrift
    my ($journal_title) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title', $xml );
    $m{journal_title} = normalize( $journal_title->textContent );

    # Untertitel der Zeitschrift
    # Jahrgang
    my ($journal_volume) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date', $xml );
    $m{journal_volume} = normalize( $journal_volume->textContent );

    # Heft
    my ($journal_issue) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope[@type="volume"]', $xml );
    $m{journal_issue} = normalize( $journal_issue->textContent );

    # Herausgeber
    my ($journal_editor) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:editor', $xml );
    $m{journal_editor} = $journal_editor ? normalize( $journal_editor->textContent ) : undef;

    # Seitenangabe
    if ( $r->{pagestart} eq $r->{pageend} ) {
        $m{pages} = sprintf "S. %s", $r->{pagestart};
    }
    else {
        $m{pages} = sprintf "S. %s–%s", $r->{pagestart}, $r->{pageend};
    }

    # Autor -- entfällt
    # Druckort
    my ($pubplace) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace', $xml );
    $m{pubplace} = normalize( $pubplace->textContent );

    # Jahr
    my ($pubdate) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date', $xml );
    $m{pubdate} = normalize( $pubdate->textContent );

    # Verlag
    my ($publisher) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher', $xml );
    $m{publisher} = normalize( $publisher->textContent );

    # Bibliothek
    my ($lib) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:note', $xml );
    $m{lib} = normalize( $lib->textContent );

    # Signatur
    $m{signature} = $r->{barcode};

    # Link in Katalog
    $m{link} = sprintf "https://www.polytechnischesjournal.de/article/%s/%s", $r->{journal}, $r->{id};

    # Kurztitel
    if ( $m{journal_editor} ) {
        $m{bibfull} = sprintf "%s In: %s (Hg. %s), Jg. %s/%s, %s. %s, %s.", $m{title_main}, $m{journal_title}, $m{journal_editor}, $m{journal_volume}, $m{journal_issue}, $m{pages}, $m{pubplace}, $m{pubdate};
    }
    else {
        $m{bibfull} = sprintf "%s In: %s, Jg. %s/%s, %s. %s, %s.", $m{title_main}, $m{journal_title}, $m{journal_volume}, $m{journal_issue}, $m{pages}, $m{pubplace}, $m{pubdate};
    }

    my $t = Template->new;
    $t->process( \$template, { m => \%m, code => $code }, \my $output ) || die $t->error;

    # full XML
    open( my $fh, '>:utf8', sprintf('/home/fw/dingler-articles/%s.orig.xml', $id) ) or die $!;
    print $fh $output;
    close $fh or die $!;

    # CMDI metadata
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $now = sprintf '%04d-%02d-%02d', $year+1900, $mon+1, $mday;
    my ( $header ) = $output =~ m{(<teiHeader>.*?</teiHeader>)}s;

    for ( $header ) {
        s/<!--.*?-->//gs;
        s/\R\s*\R/\n/g;

        s{<orgName\s+ref="https://www.clarin-d.de">(.*?)</orgName>}{<orgName>$1</orgName>}gs;
        s{<((?:pers|org)Name) ref="(.*?)">(.*?)</\1>}{<$1>$3 <idno><idno type="PND">$2</idno></idno></$1>}sg;
        s{<altIdentifier>(.*?)</altIdentifier>}{$1}gs;
        s{(<orgName>.*?</orgName>)}{<orgName>$1</orgName>}gs;
        s{(\Q<orgName role="project">Deutsches Textarchiv (Dingler)</orgName>\E)\s*(\Q<orgName role="hostingInstitution" xml:lang="en">Berlin-Brandenburg Academy of Sciences and Humanities</orgName>\E)\s*(\Q<orgName role="hostingInstitution" xml:lang="de">Berlin-Brandenburgische Akademie der Wissenschaften (BBAW)</orgName>\E)}{<orgName>$1\n$2\n$3</orgName>};
        s{<editor corresp="#DTACorpusPublisher">}{<editor>}g;
        s{<publisher xml:id="DTACorpusPublisher">}{<publisher>};
        s{(<persName>)(.*?)(</persName>)}{$1 . reorder_names($2) . $3}gse;
        s{(<p>)(.*?)(</p>)}{$1 . cleanup_p($2) . $3}gse;
        s{(<publicationStmt>.*?)((?:<publisher>.*?</publisher>(?:\s*<publisher>.*?</publisher>)*|<publisher/>))(.*?)(<date type="publication">.*?</date>(?:\s*<date.*?</date>)*)(.*?</publicationStmt>)}{$1$3$4$2$5}gs;

        s{(<profileDesc>)}{$1<abstract><p>„Dingler Online – Das digitalisierte Polytechnische Journal“</p></abstract>};

        # attach cmdp namespace to all elements
        s{<(/?)(\w+)}{<$1cmdp:$2}g;
    }

    my $cmdi = <<"CMDI";
<?xml version="1.0" encoding="UTF-8"?>
<cmd:CMD xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:cmd="http://www.clarin.eu/cmd/1"
  xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1381926654438"
  xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1381926654438/xsd"
  CMDVersion="1.2">
  <cmd:Header>
    <cmd:MdCreator>Deutsches Textarchiv (Dingler)</cmd:MdCreator>
    <cmd:MdCreationDate>$now</cmd:MdCreationDate>
    <cmd:MdProfile>clarin.eu:cr1:p_1381926654438</cmd:MdProfile>
    <cmd:MdCollectionDisplayName>Dinglers Polytechnisches Journal</cmd:MdCollectionDisplayName>
  </cmd:Header>

  <cmd:Resources>
    <cmd:ResourceProxyList>
      <!--
      <cmd:ResourceProxy id="dingler-$id.landing_page">
        <cmd:ResourceType>LandingPage</cmd:ResourceType>
        <cmd:ResourceRef>$m{link}</cmd:ResourceRef>
      </cmd:ResourceProxy>
      -->
      <cmd:ResourceProxy id="dingler-$id.xml">
        <cmd:ResourceType mimetype="application/xml">Resource</cmd:ResourceType>
        <cmd:ResourceRef>https://www.deutschestextarchiv.de/dingler/download/articles/$id.xml</cmd:ResourceRef>
      </cmd:ResourceProxy>
      <cmd:ResourceProxy id="dingler-$id.search">
        <cmd:ResourceType mimetype="application/sru+xml">SearchService</cmd:ResourceType>
        <cmd:ResourceRef>http://dspin.dwds.de:8088/ddc-sru/dingler/</cmd:ResourceRef>
      </cmd:ResourceProxy>
    </cmd:ResourceProxyList>
    <cmd:JournalFileProxyList></cmd:JournalFileProxyList>
    <cmd:ResourceRelationList></cmd:ResourceRelationList>
  </cmd:Resources>

  <cmd:Components>
    $header
  </cmd:Components>
</cmd:CMD>
CMDI

    $cmdi =~ s/<!--.*?-->//gs;
    utf8::decode($cmdi);

    my ($tempfh, $tempname) = tempfile( DIR => '/tmp/' );
    binmode( $tempfh, ":utf8" );
    print $tempfh $cmdi;
    close $tempfh;

    my $pretty = join '' => `xmllint --encode utf8 -format "$tempname" 2>&1 | tail -n +2`;
    unlink $tempname;

    utf8::decode($pretty);
    $pretty = '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . $pretty;
    open( $fh, '>:utf8', sprintf('/home/fw/dingler-meta/%s.cmdi.xml', $id) ) or die $!;
    print $fh $pretty;
    close $fh or die $!;

    $i++;
#    last if $i == 1;
}

sub debug {
    print STDERR @_;
}

sub normalize {
    my $str = shift || '';
    for ( $str ) {
        s/\s+/ /g;
        s/^\s*|\s*$//g;
        s/aͤ/ä/g;
        s/oͤ/ö/g;
        s/uͤ/ü/g;
        s/ſ/s/g;
        s/ - / – /g;
    }
    return $str;
}

sub reorder_names {
    my $str = shift;
    my @parts = qw/surname forename nameLink genName addName roleName idno/;

    my @ret;

    foreach my $part ( @parts ) {
        my $pat = qr/<$part>(.*)<\/$part>/s;
        if ( $str =~ /($pat)/s ) {
            push @ret, $1;
        }
    }

    my $ret = join "\n", @ret;
    return $ret;
}

sub cleanup_p {
    my $str = shift;
    $str =~ s{<ref\b.*?>(.*?)</ref>}{$1}gs;
    return $str;
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
<teiHeader>
  <fileDesc>
    <titleStmt>
      <title type="main">[% m.title_main | xml %]</title>
      [% FOREACH st IN m.title_sub -%]
      <title type="sub">[% st | xml %]</title>
      [%- END %]
      <editor>
        <orgName>Dingler Online – Das digitalisierte Polytechnische Journal</orgName>
      </editor>
      <respStmt>
        <orgName>Humboldt-Universität zu Berlin</orgName>
        <resp>
          <note type="remarkResponsibility">Projektträger</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName ref="http://d-nb.info/gnd/141535091">
          <surname>Kassung</surname>
          <forename>Christian</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Projektleitung Humboldt-Universität</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Hug</surname>
          <forename>Marius</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Wissenschaftlicher Mitarbeiter Humboldt-Universität</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Zehnder</surname>
          <forename>Deborah</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Projektkoordination</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Luzardo</surname>
          <forename>Laura</forename>
        </persName>
        <persName>
          <surname>Schäfer</surname>
          <forename>Una</forename>
        </persName>
        <persName>
          <surname>Bechmann</surname>
          <forename>Antonia</forename>
        </persName>
        <persName>
          <surname>Daniel</surname>
          <forename>Diana</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Studentische Hilfskräfte</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Wiegand</surname>
          <forename>Frank</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Programmierung</note>
        </resp>
      </respStmt>
      <respStmt>
        <orgName>Sächsische Landesbibliothek – Staats- und Universitätsbibliothek Dresden</orgName>
        <resp>
          <note type="remarkResponsibility">Kooperationspartner Bibliothek</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Rohrmüller</surname>
          <forename>Marc</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Projektkoordination Bibliothek</note>
        </resp>
      </respStmt>
      <respStmt>
        <orgName>Deutsche Forschungsgemeinschaft</orgName>
        <resp>
          <note type="remarkResponsibility">Projektförderung</note>
        </resp>
      </respStmt>
      <respStmt>
        <orgName>Editura GmbH &amp; Co. KG, Berlin</orgName>
        <resp>
          <note type="remarkResponsibility">Volltextdigitalisierung</note>
        </resp>
      </respStmt>
      <respStmt>
        <persName>
          <surname>Gödel</surname>
          <forename>Martina</forename>
        </persName>
        <resp>
          <note type="remarkResponsibility">Projektkoordination und Basic Encoding nach den Richtlinien der TEI für die Editura GmbH &amp; Co. KG</note>
        </resp>
      </respStmt>
      <respStmt>
        <orgName ref="https://www.clarin-d.de">CLARIN-D</orgName>
        <resp>
          <note type="remarkResponsibility">Langfristige Bereitstellung</note>
        </resp>
      </respStmt>
    </titleStmt>
    <editionStmt>
      <edition>Vollständig digitalisierte Ausgabe</edition>
    </editionStmt>
    <publicationStmt>
      <publisher>
        <email>wiegand@bbaw.de</email>
        <orgName role="project">Deutsches Textarchiv (Dingler)</orgName>
        <orgName role="hostingInstitution" xml:lang="en">Berlin-Brandenburg Academy of Sciences and Humanities</orgName>
        <orgName role="hostingInstitution" xml:lang="de">Berlin-Brandenburgische Akademie der Wissenschaften (BBAW)</orgName>
        <address>
          <addrLine>Jägerstr. 22/23, 10117 Berlin</addrLine>
          <country>Germany</country>
        </address>
      </publisher>
      <pubPlace>Berlin</pubPlace>
      <date type="publication">2014-04-10</date>
      <availability>
        <licence target="https://creativecommons.org/licenses/by-sa/4.0/deed.de">
          <p>Die Textdigitalisate des Polytechnischen Journals stehen unter der Creative-Commons-Lizenz CC BY-SA 4.0.</p>
        </licence>
      </availability>
      <idno>
        <!-- <idno type="URLWeb">[% m.link | xml %]</idno> -->
        <idno type="URLXML">https://www.deutschestextarchiv.de/dingler/download/articles/[% m.id | xml %].xml</idno>
      </idno>
    </publicationStmt>
    <sourceDesc>
      <bibl>[% m.bibfull | xml %]</bibl>
      <biblFull>
        <titleStmt>
          <title level="a" type="main">[% m.title_main | xml %]</title>
          [%- FOREACH st IN m.title_sub -%]
          <title level="a" type="sub">[% st | xml %]</title>
          [%- END -%]
          [% IF m.journal_editor %]<editor>
            <persName>[% m.journal_editor | xml %]</persName>
          </editor>[% END %]
        </titleStmt>
        <editionStmt>
            <edition n="1"/>
        </editionStmt>
        <publicationStmt>
          <publisher>
            <name>[% m.publisher | xml %]</name>
          </publisher>
          <pubPlace>[% m.pubplace | xml %]</pubPlace>
          <date type="publication">[% m.pubdate | xml %]</date>
        </publicationStmt>
        <seriesStmt>
          <title level="j" type="main">[% m.journal_title | xml %]</title>
          <biblScope unit="volume">[% m.journal_volume | xml %]</biblScope>
          <biblScope unit="issue">[% m.journal_issue | xml %]</biblScope>
          <biblScope unit="pages">[% m.pages | xml %]</biblScope>
        </seriesStmt>
      </biblFull>
      <msDesc>
        <msIdentifier>
          <repository>SLUB Dresden</repository>
          <idno>
            <idno type="shelfmark">[% m.signature | xml %]</idno>
          </idno>
        </msIdentifier>
      </msDesc>
    </sourceDesc>
  </fileDesc>
  <encodingDesc>
    <editorialDecl>
      <p>Es gelten die Transkriptions- und Auszeichnungsrichtlinien des Projekts „Dingler Online – Das digitalisierte Polytechnische Journal“.</p>
    </editorialDecl>
  </encodingDesc>
  <profileDesc>
    <langUsage>
      <language ident="deu">deutsch</language>
    </langUsage>
    <textClass>
      <classCode scheme="http://www.deutschestextarchiv.de/doku/klassifikation#DTACorpus">dingler</classCode>
    </textClass>
  </profileDesc>
</teiHeader>
[% IF m.article_type == 'misc_undef' %]
<text><body>[% code %]</body></text>
[% ELSE %]
[% code %]
[% END %]
</TEI>
