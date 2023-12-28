#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);
use File::Basename qw(basename);                                             
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat bundling);

use open IO => ":encoding(UTF-8)";
binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $cmd_name  = basename($0);
my $cmd_usage = <<EOL;
usage: $cmd_name [<option(s)>] [<file(s)>]
zip lines by the line number.

options:
  -s, --separator=<sep>  separate lines by sep in addition to files
      --help             print usage and exit
EOL

sub print_error_and_abort {
    my ($error) = @_;
    chomp $error;
    print STDERR "$cmd_name: $error\n";
    exit 1;
}

sub read_lines_by_argf_index_from_argf {
    my $lines_by_argf_index = [[]];
    my $last_argv           = "";
    my $last_argf_i         = -1;
    while (my $line = <>) {
        chomp $line;
        if ($ARGV ne $last_argv) {
            $last_argv = $ARGV;
            $last_argf_i++;
            $lines_by_argf_index->[$last_argf_i] = [];
        }
        push @{$lines_by_argf_index->[$last_argf_i]}, $line;
    }
    return $lines_by_argf_index;
}

sub zip_lines_by_line_index {
    my ($lines_by_argf_index, $separator) = @_;
    my $lines_by_line_index = [[]];
    my $last_line_i         = 0;
    my $last_argf_i         = 0;
    for my $lines (@$lines_by_argf_index) {
        $last_line_i = 0;
        for my $line (@$lines) {
            if (defined($separator) && $line eq $separator) {
                $last_line_i = 0;
                $last_argf_i++;
                next;
            }
            if (!defined($lines_by_line_index->[$last_line_i])) {
                $lines_by_line_index->[$last_line_i] = [];
            }
            $lines_by_line_index->[$last_line_i][$last_argf_i] = $line;
            $last_line_i++;
        }
        $last_argf_i++;
    }

    my $lines_by_line_index_filled_with_empty_line = $lines_by_line_index;
    for my $lines (@$lines_by_line_index_filled_with_empty_line) {
        for (my $line_i = 0; $line_i < $last_argf_i; $line_i++) {
            if (!defined($lines->[$line_i])) {
                $lines->[$line_i] = "";
            }
        }
    }
    return $lines_by_line_index_filled_with_empty_line;
}

sub dump_lines_by_line_index {
    my ($lines_by_line_index) = @_;
    for my $lines (@$lines_by_line_index) {
        for my $line (@$lines) {
            print "$line\n";
        }
    }
}

sub main {
    local $SIG{__WARN__} = \&print_error_and_abort;

    my $separator = undef;
    my $is_help   = 0;
    foreach (@ARGV) {
        $_ = decode_utf8($_);
    }
    GetOptions(
        "s|separator=s" => \$separator,
        "help"          => \$is_help,
    );
    if ($is_help) {
        print $cmd_usage;
        return;
    }

    eval {
        my $lines_by_argf_index = read_lines_by_argf_index_from_argf();
        my $lines_by_line_index = zip_lines_by_line_index($lines_by_argf_index, $separator);
        dump_lines_by_line_index($lines_by_line_index);
    };
    if ($@) {
        print_error_and_abort($@);
    }
}
main;
