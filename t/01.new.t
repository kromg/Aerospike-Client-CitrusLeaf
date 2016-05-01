use Test::More tests => 2;

use Aerospike::Client::CitrusLeaf;
SKIP: {

skip('Aerospike::Client::CitrusLeaf has no new() method', 2) unless Aerospike::Client::CitrusLeaf->can( 'new' );

ok( my $new = Aerospike::Client::CitrusLeaf->new(), 'new() is broken' );
isa_ok( $new, Aerospike::Client::CitrusLeaf, 'Generated object is not a Aerospike::Client::CitrusLeaf' );

}

diag( "Testing Aerospike::Client::CitrusLeaf new()" );
