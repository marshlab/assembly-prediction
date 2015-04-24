#!/usr/bin/perl

$pdb = (split '\/', $ARGV[0])[-1];

unless (-e "$pdb.interfaces"){
	print "Calculating all pairwise interfaces for $pdb. This could take awhile...\n";
	for(`ls tmpchain/*.pdb`){
		$cx = (split '\.', (split '\/')[1])[0];
		push @cx, $cx;
	}

	for $a (@cx){
		$sa  = sasa($a);
		for $b (@cx){
			next unless ($b gt $a);
			$sb  = sasa($b);
			$sab = sasa("$a-$b");

			$i = $sa+$sb-$sab;
			$i = 0 if ($i < 0);
			$out .= sprintf "$a\t$b\t%.1f\n", $i;
		}
	}
	open OUT, "> $pdb.interfaces";
	print OUT $out;
	close OUT;
}

system "cp $pdb.interfaces interfaces.txt";



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
