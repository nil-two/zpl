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
  -s, --separator=SEP  separate lines by SEP in addition to files
      --help           print usage and exit
EOL

sub print_error_and_abort {
    my ($error) = @_;
    chomp $error;
    print STDERR "$cmd_name: $error\n";
    exit 1;
}

sub read_lines_by_line_index_from_argf {
    my ($separator) = @_;
    my $lines_by_line_index = [[]];
    my $last_argv           = "";
    my $last_argf_i         = -1;
    my $last_line_i         = -1;
    while (my $line = <>) {
        chomp $line;
        if ($ARGV ne $last_argv) {
            $last_argv = $ARGV;
            $last_argf_i++;
            $last_line_i = -1;
        }
        if (defined($separator) && $line eq $separator) {
            $last_argf_i++;
            $last_line_i = -1;
            next;
        }
        $last_line_i++;
        if (!defined($lines_by_line_index->[$last_line_i])) {
            $lines_by_line_index->[$last_line_i] = [];
        }
        $lines_by_line_index->[$last_line_i][$last_argf_i] = $line;
    }
    return $lines_by_line_index;
}

sub fill_lines_by_line_index_with_empty_line {
    my ($lines_by_line_index, $separator) = @_;
    my $max_argf_index = -1;
    for my $lines (@$lines_by_line_index) {
        if ($#$lines > $max_argf_index) {
            $max_argf_index = $#$lines;
        }
    }
    for (my $line_i = 0; $line_i <= $#$lines_by_line_index; $line_i++) {
        for (my $argf_i = 0; $argf_i <= $max_argf_index; $argf_i++) {
            if (!defined($lines_by_line_index->[$line_i][$argf_i])) {
                $lines_by_line_index->[$line_i][$argf_i] = "";
            }
        }
    }
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
        my $lines_by_line_index = read_lines_by_line_index_from_argf($separator);
        fill_lines_by_line_index_with_empty_line($lines_by_line_index);
        dump_lines_by_line_index($lines_by_line_index);
    };
    if ($@) {
        print_error_and_abort($@);
    }
}
main;
