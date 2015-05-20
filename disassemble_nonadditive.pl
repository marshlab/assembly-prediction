#!/usr/bin/perl

$pdb = (split '\/', (shift @ARGV))[-1];

if (-e "$pdb.sasa"){
	open S, "< $pdb.sasa";
	while(<S>){
		@c=split;
		$sa{$c[0]}=$c[1];
	}
}
close S;
open S, ">> $pdb.sasa";

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

	$on{$_} = 1 for (split '\-', $sub);
	for(@interfaces){
		@c=split;
		next unless ($on{$c[0]} and $on{$c[1]});
		$ixn{$c[0]}[++$n{$c[0]}] = $c[1];
		$ixn{$c[1]}[++$n{$c[1]}] = $c[0];
		push @is, "$c[0] $c[1] $c[2]";
	}

	$best=$bestx=$rest="";
	for $l (1..(int(slength($sub)/2))){ #go through all possible subcomplexes up to half the size of the full complex
		%done=();
		for $ca (sort(keys %on)){
			nsi($ca, $l); #nsi sets the global variables $best and $bestx, representing the subcomplex that requires the smallest amount of interface to be formed from the current (sub)complex
		}
		
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
close S;

sub nsi { #uses recursion to go through all possible connected subcomplexes of size $nl, starting from subunit or subcomplex $x
	my ($x, $nl)=@_;
	$x = sortc($x);
	return "" if ($done{$x});
	$done{$x}=1;
	return "" if (repeats($x)); #stop if we've repeated a subunit
	if (slength($x)==$nl){ #recursively calls itself until subcomplex length is equal to $nl
		$ix = checki($x);
		if ($ix < $best or $best eq ''){
			$best = $ix;
			$bestx = $x;
		}
	}else{
		%duni=();
		for $cx (split '\-', $x){
			for (1..$n{$cx}){
				$i = $ixn{$cx}[$_];
				next if ($duni{$i});
				$duni{$cx}=1;
				nsi("$x-$i", $nl);
			}
		}
	}
}

sub sortc{
	my @chars;
	for $cx (split '\-', $_[0]){
		push @chars, $cx;
	}
	return (join "-", sort(@chars));
}
sub repeats{
	my %charon;
	for $cx (split '\-', $_[0]){
		$charon{$cx}++;
		return 1 if ($charon{$cx} > 1);
	}
	return 0;
}

sub slength{
	my $sln=0;
	$sln++ for (split '\-', $_[0]);
	return $sln;
}

sub checki{
        $oth = '';
        %xon=();
        for(split '\-', $_[0]){
                $xon{$_}=1;
        }
        for(split '\-', $sub){
                unless ($xon{$_}){
                        $oth .= "$_-";
                }
        }
        $ii = sasa($_[0]) + sasa($oth) - sasa($sub);
        return $ii;
}

sub sasa{
        $x = sortc($_[0]);
        if ($sa{$x} ne ''){
                return $sa{$x};
        }
        unless ($x =~ /\-/){ #if its a monomer
                $f = "tmpchain/$x.pdb";
        }else{
                unlink 'tmpsub.pdb';
                for(split '\-', $x){
                        system "cat tmpchain/$_.pdb >> tmpsub.pdb";
                }
                $f = "tmpsub.pdb";
        }
        $sa{$x} = `sasa.pl $f`;
        chomp $sa{$x};
	print S "$x\t$sa{$x}\n";
        return $sa{$x};
}
