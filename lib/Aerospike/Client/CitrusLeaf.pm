package Aerospike::Client::CitrusLeaf;

=pod

=encoding UTF-8

=cut

# ABSTRACT: Aerospike OO client based on citrusleaf

use v5.010.001;
use strict;
use warnings;
use Carp;
use utf8;

our $VERSION = '0.01.11';

use citrusleaf;
use perl_citrusleaf;

use File::Spec;



# ------------------------------------------------------------------------------
#  Internal configurations
# ------------------------------------------------------------------------------
# Getters and setters names
my @attributes = (qw(
    asc
    host
    port
    conn_timeout
    read_timeout
    connected
    ns
    set
));




# ------------------------------------------------------------------------------
#  citrusleaf::citrusleaf_init()
# ------------------------------------------------------------------------------
BEGIN {
    # citrusleaf_init() prints client version, redirect it to null
	# Save STDERR
    open( my $orig, ">&", \*STDERR ) or croak "Can't dup STDERR: $!";
    open( STDERR, ">", File::Spec->devnull )
        or croak "Couldn't open null device";

    # Initialize citrusleaf once
    citrusleaf::citrusleaf_init();

    open( STDERR, ">&", $orig ) or croak "Can't restore STDERR: $!";
	close( $orig );
}




# ------------------------------------------------------------------------------
#  Private methods
# ------------------------------------------------------------------------------

sub _cl_wp {
    my ($self, $wp) = @_;

    my $cl_wp = undef;
    if ($wp && ref( $wp ) && ref( $wp ) eq 'HASH') {
        $cl_wp = new citrusleaf::cl_write_parameters();
        citrusleaf::cl_write_parameters_set_default($cl_wp);
        while (my ($param, $value) = each %$wp) {
            $cl_wp->{$param} = $value;
        }
    }

    return $cl_wp;

}




# ------------------------------------------------------------------------------
#  Public methods
# ------------------------------------------------------------------------------

=head1 SYNOPSIS

See SAMPLE USAGE

=cut

sub new {
    my $class = shift;

    # Boilerplate
    ref($class) && croak "new() is a static method, you must call it on ".__PACKAGE__;

    my %args =
        ref($_[0])     ?
            %{ $_[0] } :
            @_;

    for my $attr (keys( %args )) {
        croak "Invalid attribute passed: $attr"
            unless grep { $_ eq $attr } @attributes;
    }

    # Create a cluster with a particular starting host
    my $asc = citrusleaf::citrusleaf_cluster_create()
        or croak "citrusleaf::citrusleaf_cluster_create() failed!";

    # Useful defaults (here? Hmmm...)
    $args{ asc  }           = $asc;
    $args{ host }         ||= '127.0.0.1';
    $args{ port }         ||= 3000;
    $args{ conn_timeout } ||= 1000;
    $args{ read_timeout } ||= 100;

    return bless( {%args}, $class );
}


sub connect {
    my ($self) = @_;

    unless ($self->connected()) {
        citrusleaf::citrusleaf_cluster_add_host(
            $self->asc(),
            $self->host(),
            $self->port(),
            $self->conn_timeout(),
        ) == citrusleaf::CITRUSLEAF_OK
            ? $self->set_connected( 1 )
            : $self->set_connected( 0 );
    }

    return $self->connected();

}

sub namespace {
    &ns;        # tail call -- pass @_ efficiently
}

sub close {
    my ($self) = @_;
    citrusleafc::citrusleaf_cluster_destroy( $self->asc() );
}

sub DESTROY {
    my ($self) = @_;
    citrusleaf::citrusleaf_shutdown();
}



sub write {
    my $self = shift;

    $self->ns() && $self->set()
        or croak "Default namespace and set are not defined.";

    $self->write_to(
        $self->ns(),
        $self->set(),
        @_,
    );
}

sub write_to {
    my ($self, $ns, $set, $key, $data, $wp) = @_;

    # set up the key. Create a stack object, set its value to a string
    my $key_obj = new citrusleaf::cl_object();
    citrusleaf::citrusleaf_object_init_str($key_obj, $key);

    # Declaring an array in this interface
    my $ndata = scalar @$data;
    my $bins = new citrusleaf::cl_bin_arr($ndata);

    # Provide values for those bins and then initialize them.
    # Initializing bin of type string
    for (my $idx =0; $idx < $ndata; ++$idx) {
        my $b = $bins->getitem( $idx );
        $b->{bin_name} = $data->[$idx]->{name};

        for my $type ($data->[$idx]->{type}) {
            if      ($type == citrusleaf::CL_STR) {
                citrusleaf::citrusleaf_object_init_str($b->{object}, $data->[$idx]->{data});
            } elsif ($type == citrusleaf::CL_BLOB) {
                citrusleaf::citrusleaf_object_init_blob($b->{object}, $data->[$idx]->{data}, length( $data->[$idx]->{data} ));
            } elsif ($type == citrusleaf::CL_INT) {
                citrusleaf::citrusleaf_object_init_int($b->{object}, $data->[$idx]->{data} + 0);    # Force Perl to give us a number
            } else {
                croak "Invalid cl_object type: $type";
            }
        }

        $bins->setitem($idx, $b);
    }


    my $cl_wp = $self->_cl_wp( $wp );


    my $rv = citrusleaf::citrusleaf_put(
        $self->asc(),
        $ns,
        $set,
        $key_obj,
        $bins,
        $ndata,
        $cl_wp
    );
    if ($rv != citrusleaf::CITRUSLEAF_OK ) {
       croak "Failure setting values ", $rv;
    }

}


sub read {
    my $self = shift;

    $self->ns() && $self->set()
        or croak "Default namespace and set are not defined.";

    $self->read_from(
        $self->ns(),
        $self->set(),
        $_[0],
    );
}


sub read_from {
    my ($self, $ns, $set, $key) = @_;

    # set up the key. Create a stack object, set its value to a string
    my $key_obj = new citrusleaf::cl_object();
    citrusleaf::citrusleaf_object_init_str($key_obj, $key);

    my $size = citrusleaf::new_intp();
    my $generation = citrusleaf::new_intp();

    # Declare a reference pointer for cl_bin *
    my $bins_get_all = citrusleaf::new_cl_bin_p();

    my $rv = citrusleaf::citrusleaf_get_all(
        $self->asc(),
        $ns,
        $set,
        $key_obj,
        $bins_get_all ,
        $size,
        $self->read_timeout(),
        $generation
    );

    croak "Read failed: $rv"
        unless $rv == citrusleaf::CITRUSLEAF_OK;

    # Number of bins returned
    my $number_bins = citrusleaf::intp_value($size);

    # Use helper function get_bins to get the bins from pointer bins_get_all and the number of bins
    my $bins = perl_citrusleaf::get_bins ($bins_get_all, $number_bins);

    # Printing value received
    my @bins;
    for (my $i=0; $i < $number_bins; $i++) {
        my %bininfo;
        my $bin = $bins->getitem($i);

        $bininfo{name} = my $name = $bin->{bin_name};
        $bininfo{type} = my $type = $bin->{object}->{type};

        if ($type == citrusleaf::CL_STR) {
            $bininfo{data} = my $data = $bin->{object}->{u}->{str};
            print "Bin name: ", $name," Resulting string: ",$data, "\n";
        } elsif ($type == citrusleaf::CL_INT) {
            $bininfo{data} = my $data = $bin->{object}->{u}->{i64};
            print "Bin name: ",$name," Resulting int: ",$data, "\n";
        } elsif ($type == citrusleaf::CL_BLOB) {
            $bininfo{data} = my $data = citrusleaf::cdata($bin->{object}->{u}->{blob}, $bin->{object}->{sz});
            print "Bin name: ",$name," Resulting decompressed blob: ",uncompress($data), "\n";
        } else{
            print "Bin name: ",$name," Unknown bin type: ",$type, "\n";
        }

        push @bins, \%bininfo;

    }


    # Free memory before returning
    citrusleaf::citrusleaf_free_bins($bins, $number_bins, $bins_get_all);
    citrusleaf::delete_intp($size);
    citrusleaf::delete_intp($generation);
    citrusleaf::delete_cl_bin_p($bins_get_all);


    return \@bins;

}





sub delete {
    my $self = shift;

    $self->ns() && $self->set()
        or croak "Default namespace and set are not defined.";

    $self->delete_from(
        $self->ns(),
        $self->set(),
        $_[0],
    );
}


sub delete_from {
    my ($self, $ns, $set, $key, $wp) = @_;

    # set up the key. Create a stack object, set its value to a string
    my $key_obj = new citrusleaf::cl_object();
    citrusleaf::citrusleaf_object_init_str($key_obj, $key);

    my $cl_wp = $self->_cl_wp( $wp );

    my $rv = citrusleaf::citrusleaf_delete(
        $self->asc(),
        $ns,
        $set,
        $key_obj,
        $cl_wp,
    );

    croak "Delete failed: $rv"
        unless $rv == citrusleaf::CITRUSLEAF_OK;
}



sub operate {
    my $self = shift;

    $self->ns() && $self->set()
        or croak "Default namespace and set are not defined.";

    $self->operate_onto(
        $self->ns(),
        $self->set(),
        @_,
    );
}

sub operate_onto {
    my ($self, $ns, $set, $key, $data, $wp) = @_;

    # set up the key.
    my $key_obj = new citrusleaf::cl_object();
    citrusleaf::citrusleaf_object_init_str($key_obj, $key);

    my $gen_count = citrusleaf::new_intp();

    my $ndata = ~~@$data;
    my $ops = new citrusleaf::cl_op_arr($ndata);

    for (my $idx = 0; $idx < $ndata; ++$idx) {
        my $op = $ops->getitem( $idx );
        $op->{bin}->{bin_name} = $data->[$idx]->{name};
        $op->{op} = $data->[$idx]->{op};    # TODO: export citrusleaf operation or tell user she must import them manually


        for my $type ($data->[$idx]->{type}) {
            if      ($type == citrusleaf::CL_STR) {
                citrusleaf::citrusleaf_object_init_str($op->{bin}->{object}, $data->[$idx]->{data});
            } elsif ($type == citrusleaf::CL_BLOB) {
                citrusleaf::citrusleaf_object_init_blob($op->{bin}->{object}, $data->[$idx]->{data}, length( $data->[$idx]->{data} ));
            } elsif ($type == citrusleaf::CL_INT) {
                citrusleaf::citrusleaf_object_init_int($op->{bin}->{object}, $data->[$idx]->{data} + 0);    # Force Perl to give us a number
            } else {
                croak "Invalid cl_object type: $type";
            }
        }
        $ops->setitem($idx,$op);
    }

    # Write params, if any
    my $cl_wp = $self->_cl_wp( $wp );

    # the operate call does all
    citrusleaf::citrusleaf_operate($self->asc(), $ns, $set, $key_obj, $ops, $ndata, $cl_wp, 0, $gen_count);

}




# ------------------------------------------------------------------------------
#  Getters and setters - auto generation via closures
# ------------------------------------------------------------------------------

for my $attr (@attributes) {
    my $getter =        $attr;
    my $setter = "set_".$attr;

    my $gmethod = sub {
        my ($self) = @_;
        return $self->{ $attr };
    };

    my $smethod = sub {
        my $self = shift;
        return $self->{ $attr } = $_[0];
    };

    {
        no strict "refs";
        *$getter = $gmethod;
        *$setter = $smethod;
    }
}


=head1 CAVEATS

This thing is a work in progress. Interface may change without warning.

=head1 SAMPLE USAGE

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





=cut



1; # End of Aerospike::Client::CitrusLeaf

__END__


