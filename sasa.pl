#!/usr/bin/perl

unlink 'sasa.tmp';

$areaimol = "areaimol";

open OUT, "> occ.pdb"; #fill in unoccupied atoms, because areaimol ignores them

for(`cat $ARGV[0]`){
	if (/^ATOM/){
		$line = substr($_, 0, 56);
		$line .= "1.00";
		$line .= substr($_,60,50);
		print OUT "$line";
	}else{
		print OUT;
	}
}
close OUT;

for (`echo "OUTPUT" | $areaimol XYZIN occ.pdb XYZOUT sasa.tmp`){
	print OUT;
	@c=split;
	if ($c[0] eq 'TOTAL' and $c[1] eq 'AREA:'){
		$sasa = $c[2];
	}
}

if ($sasa){
	print "$sasa\n";
}else{
	print STDERR "Failed on sasa for $ARGV[0]\n";
	print "\n";
}
