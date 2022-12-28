use FindBin;
use Test::More qw(no_plan);
use XML::LibXML;
use utf8;

my $parser = XML::LibXML->new;
my $xpc = XML::LibXML::XPathContext->new;
$xpc->registerNs( 't', 'http://www.tei-c.org/ns/1.0' );

my $article_dir = sprintf "%s/../data/articles", $FindBin::Bin;

# article title with footnote
xml_is( 'ar001047', '//t:fileDesc/t:titleStmt/t:title[@type="main"]', 'Methode, Elfenbein-Papier zum Gebrauche für Künstler zu bereiten.' );

# multiple subtitles
xml_is( 'ar001042', '//t:fileDesc/t:titleStmt/t:title[@type="sub"][1]', 'Von der Wittwe des sel. S. Brierly.' );
xml_is( 'ar001042', '//t:fileDesc/t:titleStmt/t:title[@type="sub"][2]', 'Mit Abbildungen Tab. 10.' );
xml_is( 'ar001042', '//t:fileDesc/t:titleStmt/t:title[@type="sub"][3]', 'Aus den Transactions of the Society for Encouragement of arts, Manufactures u. Commerce.' );

# choice[sic and corr] in subtitle
xml_is( 'ar001026', '//t:fileDesc/t:titleStmt/t:title[@type="sub"][2]', 'Mit Abbildungen Tab. VIII.' );

xml_is( 'mi001024_02', '//t:fileDesc/t:titleStmt/t:title[@type="main"]', 'Nachricht von einem, vom Professor Jan in Parma herauszugebenden, technologisch-ökonomischen Herbarium.' );
xml_like( 'mi001024_02', '//t:sourceDesc/t:bibl[@type="JA"]', qr/S\. 251\.$/ );
xml_is( 'mi001024_02', '//t:biblScope[@unit="pages"]', 'S. 251' );

sub xml_is {
    my ( $article, $xpath, $str ) = @_;
    my $test_name = sprintf "%s: %s", $article, $xpath;
    my $source = $parser->load_xml( location => sprintf "%s/%s.xml", $article_dir, $article ) or die $!;
    my ($res) = $xpc->findnodes( $xpath, $source );
    return fail( $test_name ) unless $res;
    return is( $res->textContent, $str, $test_name );
}

sub xml_like {
    my ( $article, $xpath, $str ) = @_;
    my $test_name = sprintf "%s: %s", $article, $xpath;
    my $source = $parser->load_xml( location => sprintf "%s/%s.xml", $article_dir, $article ) or die $!;
    my ($res) = $xpc->findnodes( $xpath, $source );
    fail( $test_name ) unless $res;
    return like( $res->textContent, $str, $test_name );
}
