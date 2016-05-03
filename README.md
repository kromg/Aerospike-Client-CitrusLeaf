NAME

    Aerospike::Client::CitrusLeaf - Aerospike OO client based on citrusleaf

VERSION

    version 0.01.11

SYNOPSIS

    See SAMPLE USAGE

CAVEATS

    This thing is a work in progress. Interface may change without warning.

SAMPLE USAGE

            #!/usr/bin/perl
    
            use strict;
            use warnings;
            use v5.010.001;
            use utf8;
    
            use citrusleaf;
            use Aerospike::Client::CitrusLeaf;
            use Data::Dumper;
    
    
            my $a = Aerospike::Client::CitrusLeaf->new(
                host         => '192.168.100.157',
                ns           => 'test',
                set          => 'testset',
                conn_timeout => 10
            );
    
            my $b = Aerospike::Client::CitrusLeaf->new(
                host         => '192.168.100.239',
                ns           => 'test',
                set          => 'testset',
                conn_timeout => 10
            );
    
            $a->connect();
            $b->connect();
    
            $a->write(
                "testkey",
                [
                    { name => 'bin1', data => 'a string', type => citrusleaf::CL_STR },
                    { name => 'bin2', data => 1,          type => citrusleaf::CL_INT },
                ]
            );
    
            $b->write(
                "testkey2",
                [
                    { name => 'bin1', data => 'another string', type => citrusleaf::CL_STR },
                    { name => 'bin2', data => 2,                type => citrusleaf::CL_INT },
                ]
            );
    
            say Data::Dumper->Dump( [ $a->read("testkey") ] );
            say Data::Dumper->Dump( [ $b->read("testkey2") ] );
    
    
    
    
            my $write_params = undef;
            $a->operate(
                "testkey",
                [
                    { name => 'bin2', data => 2, type => citrusleaf::CL_INT, op => citrusleaf::CL_OP_INCR, },
                ],
                $write_params,
            );
    
    
            $b->operate(
                "testkey2",
                [
                    { name => 'bin1', data => "just ", type => citrusleaf::CL_STR, op => citrusleaf::CL_OP_MC_PREPEND, },
                    { name => 'bin3', data => 2, type => citrusleaf::CL_INT, op => citrusleaf::CL_OP_WRITE, },
                ],
                $write_params,
            );
    
    
            say Data::Dumper->Dump( [ $a->read("testkey") ] );
            say Data::Dumper->Dump( [ $b->read("testkey2") ] );
    
            $a->delete( "testkey" );
            $b->delete( "testkey2" );
    
            $a->close();
            $b->close();

AUTHOR

    Giacomo Montagner <kromg@entirelyunlike.net>

COPYRIGHT AND LICENSE

    This software is copyright (c) 2016 by Giacomo Montagner.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

