#!/usr/bin/perl
#uses areaimol to calculate the solvent accessible surface area (SASA) of a structure
#need to install CCP4 first, and make sure to source the required environment variables
#areaimol should be in your $PATH
#CCP4 is distributed separately, visit http://ccp4.ac.uk
#areaimol can crash on big structures. to fix this, you can recompile it setting the MAXATOM value to be much bigger
#in principle, any program for SASA calculation could be used (e.g. naccess). you just need to wrap it into a script like this that returns a single SASA value

unlink 'sasa.tmp';

unless (`which areaimol`){
	die "areaimol does not seem to be installed. Download the CCP4 package and make sure to source the initialization scripts\n";
}

open OUT, "> occ.pdb"; #fill in unoccupied atoms, because areaimol ignores them
for(`cat $ARGV[0]`){
	if (/^(ATOM|HETATM)/){
		$line = substr($_, 0, 56);
		$line .= "1.00";
		$line .= substr($_,60,50);
		print OUT "$line";
	}else{
		print OUT;
	}
}
close OUT;

for (`echo "OUTPUT" | areaimol XYZIN occ.pdb XYZOUT sasa.tmp`){
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
	print "-1\n";
}
