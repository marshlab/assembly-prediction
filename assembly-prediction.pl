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
system "out_chains.pl $pdb"; #Replace this with out_chains_old.pl if you want to replicate the chain naming for the (dis)assembly pathways in "Gene order is optimized for ordered protein complex assembly" or "Protein complexes are under evolutionary selection to assemble via ordered pathways". This is an older version of the script that ignores nucleic acids and ligands, and can result in different chain ids for some complexes.

for(`chains.pl`){
	@c=split;
	$l = length($c[6]);
	if ($l > 1 and length($c[1])==1){
		print "*Chain $c[0] maps to chain $c[1] in input structure, $l residue protein, sequence: $c[6]\n";
		$chains .= "$c[0] ";
	}else{
		$c = 'chain';
		if (length($c[1]) > 1){
			$c .= 's' ;
		}
		print "*Chain $c[0] maps to $c $c[1] in structure, not protein\n";
		if ($flag{useall}){
			$chains .= "$c[0] ";
		}
	}
}

if ($flag{dis}){
	$form = "broken";
	print "Disassembling from full complex, assuming additive interface sizes (fast)\n";
	system "calc_interfaces.pl $pdb";
	$script = "disassemble_additive.pl";
	$sort = "| sort_disassembly.pl";
}elsif($flag{disfull}){
	$form = "broken";
	print "Disassembling from full complex, using non-additive interface sizes (this can be very slow for big complexes)\n";
	system "calc_interfaces.pl $pdb";
	$script = "disassemble_nonadditive.pl $pdb";
	$sort = "| sort_disassembly.pl";
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
$sort = '';
for(`$script $chains $sort`){
	$N++;
	($a,$b,$i) = split " ";
	print "Step $N: $a + $b, $i Å^2 interface $form\n"; 
}
