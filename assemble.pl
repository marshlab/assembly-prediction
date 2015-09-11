#!/usr/bin/perl

#assuming chains are in tmpchain

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

for(`ls tmpchain/*.pdb`){
	chomp;
	$chain = (split '\.', (split '\/')[1])[0]; 
	next unless ($chain_on{$chain} or $all_on);
	push @pool, $chain;
}

for(1..$#pool){
	$max = -999;
	for $a (@pool){
		for $b (@pool){
			next unless ($b gt $a);
			$sa = sasa($a);
			$sb = sasa($b);
			$sab = sasa("$a-$b");
			$I = $sa + $sb - $sab; 
			if ($I > $max){
				$max = $I;
				$best = "$a $b";
			}

		}
	}
	@newpool=();
	for(@pool){
		next if ($_ eq (split " ", $best)[0]);
		next if ($_ eq (split " ", $best)[1]);
		push @newpool, $_;
	}
	push @newpool, sortc(join "-", (split " ", $best));
	@pool = @newpool;
	printf "$best\t%.1f\n", $max;
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
	if ($sa{$x}<0){
		die "ERROR: failed to calculate SASA for $pdb chain(s) $x. Probably the structure is too big - try recompiling AREAIMOL with increased MAXATOM and MAXINT.\n";
	}
	print S "$x\t$sa{$x}\n";
	return $sa{$x};
}

sub sortc{
        my @chars;
	for (split '\-', $_[0]){
                push @chars, $_ 
        }
        return (join "-", sort(@chars));
}
