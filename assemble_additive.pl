#!/usr/bin/perl

#assuming chains are in tmpchain

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
	$i{"$c[0] $c[1]"} = $c[2];
        $all{$c[0]}=1;
        $all{$c[1]}=1;
}

for(sort(keys %all)){
	push @pool, $_;
}

for(1..$#pool){
	$max = -999;
	for $a (@pool){
		for $b (@pool){
			next unless ($b gt $a);
			$I =0;
			for(keys %i){
				@c=split;
				$I += $i{$_} if ($a =~ /$c[0]/ and $b =~ /$c[1]/);
				$I += $i{$_} if ($a =~ /$c[1]/ and $b =~ /$c[0]/);
			}
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
	return $sa{$x};
}

sub sortc{
        my @chars;
	for (split '\-', $_[0]){
                push @chars, $_ 
        }
        return (join "-", sort(@chars));
}
