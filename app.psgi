package MetaCPAN::Web;

# ABSTRACT: Modern front-end for MetaCPAN
use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/lib";
use MetaCPAN::Web;
use Plack::App::File;
use Plack::Middleware::Assets;
use Plack::Middleware::Runtime;
use Plack::Middleware::ReverseProxy;

my $api = 'http://' . ( $ENV{METACPAN_API} || 'api.metacpan.org' );

MetaCPAN::Web->setup_engine('PSGI');

my $app = Plack::App::URLMap->new;
$app->map( '/static/' => Plack::App::File->new( root => 'root/static' ) );
$app->map( '/favicon.ico' => Plack::App::File->new( file => 'root/static/icons/favicon.ico' ) );
$app->map( '/' => sub { MetaCPAN::Web->run(@_) } );
$app = Plack::Middleware::Runtime->wrap($app);
$app = Plack::Middleware::Assets->wrap( $app, files => [<root/static/css/*.css>] );
$app = Plack::Middleware::Assets->wrap(
    $app,
    files => [
        map { "root/static/js/$_.js" }
          qw(jquery.min jquery.tablesorter jquery.cookie jquery.relatize_date jquery.ajaxQueue jquery.autocomplete.pack shCore shBrushPerl cpan)
    ],
    minify => 0,
);
Plack::Middleware::StackTrace->wrap($app);

Plack::Middleware::ReverseProxy->wrap($app);

# ABSTRACT: A Front End for MetaCPAN