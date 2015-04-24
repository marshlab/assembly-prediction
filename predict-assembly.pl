#!/usr/bin/perl

use Getopt::Long;

$pdb = $ARGV[0];

GetOptions("dis"=>\$flag{dis},
        "useall"=>\$flag{useall},
        "additive"=>\$flag{additive});

unless ($pdb){
	die "No PDB specified. See README for usage\n";
}

print "Outputting chains to tmpchain. These chain names are not the same as in the PDB\n";
system "out_chains_wna.pl $pdb";

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

unless ($flag{dis}){
	$form = "formed";
	unless ($flag{additive}){
		print "Assembling from free subunits, using non-additive interface sizes";
		$script = "assemble_nonadditive.pl $pdb";
	}else{
		print "Assembling from free subunits, assuming additive interface sizes";
		$script = "assemble_additive.pl";
		$calci=1;
	}
}else{
	$form = "broken";
	unless ($flag{additive}){
		print "Disassembling from full complex, using non-additive interface sizes";
		$script = "disassemble_nonadditive.pl $pdb";
		$calci=1;
	}else{
		print "Disassembling from full complex, assuming additive interface sizes";
		$script = "disassemble_additive.pl";
		$calci=1;
	}
}
if ($flag{useall}){
	print ", including all chains (including non-protein)\n";
}else{
	print ", including only protein chains\n";
}
system "calc_interfaces.pl $pdb" if ($calci);
for(`$script $chains`){
	$N++;
	($a,$b,$i) = split " ";
	print "Step $N: $a + $b, $i Å^2 interface $form\n"; 
}

unlink 'tmpsub.pdb';
unlink 'occ.pdb';
unlink 'sasa.tmp';
unlink 'map.tmp';
unlink 'interfaces.txt';
