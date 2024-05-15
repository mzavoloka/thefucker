#!/usr/bin/perl
use v5.38;

use Proc::ProcessTable;
use Data::Dumper;

my $pt = Proc::ProcessTable->new;


my @fnames = ();
open my $fh, '<', 'fucklist.txt' or die 'Error opening file';
while ( readline $fh ) {
    s/\s+//g;
    push @fnames, $_;
}
close $fh;

open my $fhboolw, '>', 'isfuckeron.bool';
print $fhboolw '1';
close $fhboolw;

while (1) {
    open my $fhboolr, '<', 'isfuckeron.bool' or die 'Error opening file';
    my $ison = readline $fhboolr;
    close $fhboolr;
    $ison =~ s/\s+//g;
    next if $ison ne '1';

    for my $p (
        grep { $_->{fname} =~ join '|', @fnames } $pt->table->@*
    ) {
        say "Killing pid $p->{pid} FNAMe: $p->{fname} COMMAND: $p->{cmndline}";
        #delete $p->{environ}; say Dumper $p; next;
        $p->kill(9);
    }
}
continue {
    sleep(1);
}
exit;

NON_VERBOSE_WAY_TO_KILL:
use Proc::Killall qw(killall);
while (1) {
    killall(9, join('|', @fnames) );
    sleep(1);
}
