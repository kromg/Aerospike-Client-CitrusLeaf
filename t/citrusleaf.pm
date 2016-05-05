# Aerospike::Client::CitrusLeaf's citrusleaf mock implementation

# ---------- BASE METHODS -------------

package citrusleaf;

use strict;
use warnings;

sub cdata {
    return;
}

sub memmove {
    return;
}

sub new_intp {
    return;
}

sub copy_intp {
    return;
}

sub delete_intp {
    return;
}

sub intp_assign {
    return;
}

sub intp_value {
    return;
}

sub new_cl_bin_p {
    return;
}

sub copy_cl_bin_p {
    return;
}

sub delete_cl_bin_p {
    return;
}

sub cl_bin_p_assign {
    return;
}

sub cl_bin_p_value {
    return;
}

sub new_charp {
    return;
}

sub copy_charp {
    return;
}

sub delete_charp {
    return;
}

sub charp_assign {
    return;
}

sub charp_value {
    return;
}

sub new_cf_digest_p {
    return;
}

sub copy_cf_digest_p {
    return;
}

sub delete_cf_digest_p {
    return;
}

sub cf_digest_p_assign {
    return;
}

sub cf_digest_p_value {
    return;
}

sub citrusleaf_init {
    return;
}

sub citrusleaf_shutdown {
    return;
}

sub citrusleaf_cluster_create {
    return 1;
}

sub citrusleaf_cluster_use_nbconnect {
    return;
}

sub citrusleaf_cluster_add_host {
    return;
}

sub citrusleaf_cluster_destroy {
    return;
}

sub cl_write_parameters_set_default {
    return;
}

sub citrusleaf_object_init {
    return;
}

sub citrusleaf_object_init_str {
    return;
}

sub citrusleaf_object_init_str2 {
    return;
}

sub citrusleaf_object_init_blob {
    return;
}

sub citrusleaf_object_init_blob2 {
    return;
}

sub citrusleaf_object_init_int {
    return;
}

sub citrusleaf_object_init_null {
    return;
}

sub citrusleaf_put {
    return;
}

sub citrusleaf_get {
    return;
}

sub citrusleaf_get_all {
    return;
}

sub citrusleaf_get_digest {
    return;
}

sub citrusleaf_put_digest {
    return;
}

sub citrusleaf_delete_digest {
    return;
}

sub citrusleaf_delete {
    return;
}

sub get_name {
    return;
}

sub get_object {
    return;
}

sub citrusleaf_bins_free {
    return;
}

sub citrusleaf_batch_get {
    return;
}

sub citrusleaf_calculate_digest {
    return;
}

sub free {
    return;
}

sub citrusleaf_free_bins {
    return;
}

sub citrusleaf_operate {
    return;
}

sub citrusleaf_use_shm {
    return;
}

sub citrusleaf_async_initialize {
    return;
}

sub citrusleaf_async_put_forget {
    return;
}

sub citrusleaf_async_put_digest_forget {
    return;
}


use constant        CL_NULL        => 0x00;
use constant        CL_INT         => 0x01;
use constant        CL_FLOAT       => 0x02;
use constant        CL_STR         => 0x03;
use constant        CL_BLOB        => 0x04;
use constant        CL_TIMESTAMP   => 0x05;
use constant        CL_DIGEST      => 0x06;
use constant        CL_JAVA_BLOB   => 0x07;
use constant        CL_CSHARP_BLOB => 0x08;
use constant        CL_PYTHON_BLOB => 0x09;
use constant        CL_RUBY_BLOB   => 0x0a;
use constant        CL_PHP_BLOB    => 0x0b;
use constant        CL_UNKNOWN     => 666666;

use constant        CITRUSLEAF_FAIL_ASYNCQ_FULL            => -3;
use constant        CITRUSLEAF_FAIL_TIMEOUT                => -2;
use constant        CITRUSLEAF_FAIL_CLIENT                 => -1;
use constant        CITRUSLEAF_OK                          => 0;
use constant        CITRUSLEAF_FAIL_UNKNOWN                => 1;
use constant        CITRUSLEAF_FAIL_NOTFOUND               => 2;
use constant        CITRUSLEAF_FAIL_GENERATION             => 3;
use constant        CITRUSLEAF_FAIL_PARAMETER              => 4;
use constant        CITRUSLEAF_FAIL_KEY_EXISTS             => 5;
use constant        CITRUSLEAF_FAIL_BIN_EXISTS             => 6;
use constant        CITRUSLEAF_FAIL_CLUSTER_KEY_MISMATCH   => 7;
use constant        CITRUSLEAF_FAIL_PARTITION_OUT_OF_SPACE => 8;
use constant        CITRUSLEAF_FAIL_SERVERSIDE_TIMEOUT     => 9;
use constant        CITRUSLEAF_FAIL_NOXDS                  => 10;
use constant        CITRUSLEAF_FAIL_UNAVAILABLE            => 11;
use constant        CITRUSLEAF_FAIL_INCOMPATIBLE_TYPE      => 12;
use constant        CITRUSLEAF_FAIL_RECORD_TOO_BIG         => 13;
use constant        CITRUSLEAF_FAIL_KEY_BUSY               => 14;

use constant        CL_OP_WRITE                            => 0x00;
use constant        CL_OP_READ                             => 0x01;
use constant        CL_OP_INCR                             => 0x02;
use constant        CL_OP_MC_INCR                          => 0x03;
use constant        CL_OP_PREPEND                          => 0x04;
use constant        CL_OP_APPEND                           => 0x05;
use constant        CL_OP_MC_PREPEND                       => 0x06;
use constant        CL_OP_MC_APPEND                        => 0x07;
use constant        CL_OP_TOUCH                            => 0x08;
use constant        CL_OP_MC_TOUCH                         => 0x09;

1;


