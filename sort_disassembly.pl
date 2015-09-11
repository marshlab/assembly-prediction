#!/usr/bin/perl

#becasue of the way the disassembly algorithm works, it can give inconsistent results for some complexes where disassembly splits into two parallel paths
#for example, if A-A-B-B first breaks into A-A and B-B, the algorithm will consider A-A and B-B separately, without considering which has a larger interface
#this script takes the output of the disassembly script and sorts it so that the smallest interface will always be broken first
#that is, if A-A has a smaller interface than B-B, then The breaking of A-A will come first in the sorted output, even though B-B might have been outputted first by the main disassembly script
#really this just comes down to the difficulty of trying to represent parallel processes whith a single linear pathway, but this way at least gives consistent results

while(<>){
	@c=split;
	$step{"$c[0] $c[1]"} = $c[2];
	$x{$_} =1 for(split '\-', $c[0]);
	$x{$_} =1 for(split '\-', $c[1]);
	$N++;
}

for(sort(keys %x)){
	$sub .= "$_-";
}

$sub = sortc($sub);
$sub{$sub}=1;


for(1..$N){
	for(sort {$step{$a} <=> $step{$b} || $a cmp $b} keys %step){
		next if ($done{$_});
		($i,$j) = split " ", $_;
		$sub = sortc("$i-$j");
		next unless ($sub{$sub});
		print "$_\t$step{$_}\n";
		$done{$_}=1;
		$sub{$i}=1;
		$sub{$j}=1;
		last;
	}
}

sub sortc{
        my @chars;
	for(split '\-', $_[0]){
                push @chars, $_;
        }
        return (join "-", sort(@chars));
}
