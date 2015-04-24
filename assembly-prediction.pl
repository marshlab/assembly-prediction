#!/usr/bin/perl

use Getopt::Long;

$pdb = $ARGV[0];

GetOptions("dis"=>\$flag{dis},
        "useall"=>\$flag{useall},
        "disfull"=>\$flag{disfull});

unless ($pdb){
	die "No PDB specified. See README for usage\n";
}

print "Outputting chains to tmpchain. These chain names are not the same as in the PDB\n";
system "out_chains.pl $pdb";

for(`chains.pl`){
	@c=split;
	$l = length($c[6]);
	if ($l > 1){
		print "chain $c[0] maps to chain $c[1] in input structure, $l residue protein\n";
		$chains .= "$c[0] ";
	}else{
		$c = 'chain';
		if (length($c[1]) > 1){
			$c .= 's' ;
		}
		print "chain $c[0] maps to $c $c[1] in structure, not protein\n";
		if ($flag{useall}){
			$chains .= "$c[0] ";
		}
	}
}

if ($flag{dis}){
	$form = "broken";
	$script = "disassemble_additive.pl";
	print "Disassembling from full complex, assuming additive interface sizes (fast)\n";
	system "calc_interfaces.pl $pdb";
}elsif($flag{disfull}){
	$form = "broken";
	$script = "disassemble_nonadditive.pl $pdb";
	print "Disassembling from full complex, using non-additive interface sizes (this can be very slow for big complexes)\n";
}else{
	$form = "formed";
	print "Assembling from free subunits\n";
	$script = "assemble.pl $pdb";
}
if ($flag{useall}){
	print "Including all chains (including non-protein)\n";
}else{
	print "Including only protein chains\n";
}
for(`$script $chains`){
	$N++;
	($a,$b,$i) = split " ";
	print "Step $N: $a + $b, $i Å^2 interface $form\n"; 
}
