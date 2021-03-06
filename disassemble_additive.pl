#!/usr/bin/perl

if (@ARGV){
        $chain_on{$_}=1 for(@ARGV);
}else{
        $all_on=1;
}

open I, "< interfaces.txt";
while(<I>){
	@c=split;
	next unless ($c[2] > 1);
	next unless ($all_on or ($chain_on{$c[0]} and $chain_on{$c[1]}));
	push @interfaces, "$c[0] $c[1] $c[2]\n";
	$isize{"$c[0] $c[1]"} = $c[2];
	$isize{"$c[1] $c[0]"} = $c[2];
	$ni++;
	$all{$c[0]}=1;
	$all{$c[1]}=1;
}
close I;

$start = join "-", sort(keys %all);
push @subs, $start;

while(@subs){
	$sub = pop (@subs);

	%on=%ixn=%n=();
	@is=();

	$on{$_} = 1 for (split '-', $sub);

	for(@interfaces){
		@c=split;
		next unless ($on{$c[0]} and $on{$c[1]});
		$ixn{$c[0]}[++$n{$c[0]}] = $c[1];
		$ixn{$c[1]}[++$n{$c[1]}] = $c[0];
		push @is, "$c[0] $c[1] $c[2]";
	}

	$best=$bestx=$rest="";
	%done=();
	#try all possible connected subcomplexes, up to half the size of the complex
	for $ca (sort(keys %on)){
		nsi($ca, int(slength($sub)/2));
	}

	for(sort(keys %on)){
		unless ($bestx =~ /$_/){
			$rest .= "$_-";
		}
	}

	$rest = sortc($rest);

	if (slength($bestx) > 1){
		push @subs, $bestx;
	}
	if (slength($rest) > 1){
		push @subs, $rest;
	}
	printf "$bestx $rest\t%.1f\n", $best;
}

sub nsi { #recursion!
	my ($x, $nl)=@_;
	$done{$x}=1;
	$ix = checki($x);
	if ($ix < $best or $best eq ''){
		$best = $ix;
		$bestx = $x;
	}
	if (slength($x) < $nl){
		my %duni=();
		$duni{$_} = 1 for (split '-', $x);
		for $cx (split '-', $x){
			$max=0;
			for (1..$n{$cx}){
				$i = $ixn{$cx}[$_];
				next if ($duni{$i});
				$duni{$i}=1;
				$inew=0;
				for $cx (split '-', $x){
					$inew += $isize{"$i $cx"};
				}
				if ($inew > $max){ #add the subunit that forms the most interface with the subcomplex
					$max = $inew;
					$addi = $i;
				}
			}
			$y = sortc("$x-$addi");
			next if ($done{$y});
			nsi($y, $nl);
		}
	}
}

sub sortc{
	my @chars;
	for $cx (split '-', $_[0]){
		push @chars, $cx;
	}
	return (join "-", sort(@chars));
}

sub checki{
	$ii=0;
	%son=();
	$son{$_} = 1 for (split '-', $_[0]);
	for(@is){
		($a,$b,$i) = split;
		if (($son{$a}==1 and $son{$b}!=1) or ($son{$a}!=1 and $son{$b}==1)){ #check for broken interfaces
			$ii += $i;
		}
	}
	return $ii;
}

sub slength{
	my $sln=0;
	$sln++ for (split '-', $_[0]);
	return $sln;
}
