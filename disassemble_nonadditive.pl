#!/usr/bin/perl

$pdb = shift @ARGV;

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
	push @interfaces, "$c[0] $c[1]\n";
	$all{$c[0]}=1;
	$all{$c[1]}=1;
}
close I;

$start = join "-", sort(keys %all);
push @subs, $start;

while(@subs){
	$sub = pop (@subs);

	%on=%ixn=%n=();

	$on{$_} = 1 for (split '-', $sub);

	for(@interfaces){
		@c=split;
		next unless ($on{$c[0]} and $on{$c[1]});
		$ixn{$c[0]}[++$n{$c[0]}] = $c[1];
		$ixn{$c[1]}[++$n{$c[1]}] = $c[0];
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
			for (1..$n{$cx}){
				$i = $ixn{$cx}[$_];
				next if ($duni{$i});
				$duni{$i}=1;
				$y = sortc("$x-$i");
				next if ($done{$y});
				nsi($y, $nl);
			}
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

sub slength{
	my $sln=0;
	$sln++ for (split '-', $_[0]);
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
