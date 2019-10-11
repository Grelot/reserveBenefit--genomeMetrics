#!/usr/bin/perl

use warnings;
use strict;

my ($lib, $file) = @ARGV;

unless (-e $lib and -e $file) {
    print "Usage: filter_fis.pl out.geno.ld data.vcf\n\n"; exit;
}

open my $LIB, "<", $lib or die "Could not open file $lib:!$\n";

my %lib;
while (<$LIB>) {
   chomp;
   next if /^#/;
   my @f = (split /\t/);
   my $id = "$f[0]_$f[1]";
   my $R2 = $f[4];
   
   $lib{$id} = 1 if $R2 > 0.8 or $R2 eq "-nan";
}

close $LIB;

open my $FILE, "<", $file or die "Could not open file $file:!$\n";

my $n = 0;
while (<$FILE>) {
   if (/^#/) {
      print;
      next;
   }
   
   my @f = (split /\t/);
   my $id = "$f[0]_$f[1]";
   
   unless (exists $lib{$id}) {
    print;
    $n++;
   }
}

print STDERR "\nKept $n loci.\n";