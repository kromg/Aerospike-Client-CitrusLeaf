use Test::More tests => 1;

use lib "./t";

BEGIN {
    use_ok( 'Aerospike::Client::CitrusLeaf' );
}

diag( "Testing Aerospike::Client::CitrusLeaf $Aerospike::Client::CitrusLeaf::VERSION" );
