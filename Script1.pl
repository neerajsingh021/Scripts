use strict;
use warnings;

my ($path, @files, %stats);

$path = 'D:/scripts/file/';

opendir(DIR, $path) or die "Cannot read $path: $!";
@files = grep { /\.txt$/ } readdir(DIR);
closedir(DIR);

foreach my $f (@files) {
	my ($longest, @words, @sentence);

	open(FH, "<$path$f") or die "Cannot read $f: $!";
	while (<FH>) {
		push @sentence, split (/[.]/, $_);

		$_ =~ s/[?.():;!\"\',]//gio;
		@words = split (" ", lc $_);

		$stats{$f}{'WORDS'} += @words;
		$stats{$f}{'LINES'}++;

		grep { $stats{$f}{'common'}{$_}++; $stats{'OVERALL'}{'common'}{$_}++; } @words;
	}
	close(FH);

	map { $_ =~ s/^\s+//} @sentence;

	$longest = ( sort { length($b) <=> length($a) } @sentence)[0];

	$stats{$f}{'SIZE'} = -s $path.$f; 
	$stats{$f}{'LONGEST_SENTENCE'} = $longest; 

	$stats{'OVERALL'}{'WORDS'} += $stats{$f}{'WORDS'};
	$stats{'OVERALL'}{'LINES'} += $stats{$f}{'LINES'};
	$stats{'OVERALL'}{'SIZE'}  += $stats{$f}{'SIZE'};

	push @{$stats{'OVERALL'}{'LONGEST_SENTENCE'}}, $longest;

	@{$stats{$f}{'TEN_MOST_COMMON_WORDS'}} = ( sort { $stats{$f}{'common'}{$b} <=> $stats{$f}{'common'}{$a} } keys %{$stats{$f}{'common'}})[0..9];
	delete $stats{$f}{'common'};
}

$stats{'OVERALL'}{'LONGEST_SENTENCE'} = (sort { length($b) <=> length($a) } @{$stats{'OVERALL'}{'LONGEST_SENTENCE'}})[0];
@{$stats{'OVERALL'}{'TEN_MOST_COMMON_WORDS'}} = ( sort { $stats{'OVERALL'}{'common'}{$b} <=> $stats{'OVERALL'}{'common'}{$a} } keys %{$stats{'OVERALL'}{'common'}})[0..9];
delete $stats{'OVERALL'}{'common'};

$" = "\t";
foreach my $k1 (keys %stats) {
	print "\n***********\n";
	print "$k1:\n";
	print "***********\n\n";

	foreach my $k2 (keys %{$stats{$k1}}) {
		print $k2,":\t\t",ref($stats{$k1}{$k2}) eq 'ARRAY' ? "@{$stats{$k1}{$k2}}" : $stats{$k1}{$k2},"\n";
	}
}

__END__

use Data::Dumper;
print Dumper \%stats;

