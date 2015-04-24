#!/usr/bin/perl

#if filename $pdb exists, it will use that; otherwise it will try to download from PDB
#iterates at TER or ENDMDL

$pdb = $ARGV[0];
@cs = (A..Z);
push @cs, (0..9);
push @cs, (a..z); #gets us above 60 
for $a (a..z){
	for $b (A..Z){
		push @cs, "$a$b";
	}
}

system "rm -rf tmpchain";
mkdir 'tmpchain';

if (-e $pdb){
	$f = $pdb;
}elsif (-e "$pdb.pdb1"){
	$f = "$pdb.pdb1";
}else{
	print STDERR "Downloading from http://www.rcsb.org/pdb/files/$pdb.pdb1\n";
	$url = "http://www.rcsb.org/pdb/files/$pdb.pdb1";
	system "curl $url > $pdb.pdb1";
	$f = "$pdb.pdb1";
}
unless (-e $f){
	die "ERROR: no PDB file $f\n";
}

open PDB, "< $f";
while(<PDB>){
	$cx = $cs[$cxcount];
	if (length($cx)==1){
		$cx = " $cx";
	}
	if (/^(TER|ENDMDL)/){
		$cxcount++;
	}
	next unless (/^(ATOM|HETATM)/);
	$lina = substr $_, 0, 20;
	$cxpisa = substr $_, 20,2;
	$map{$cx} .= $cxpisa;
	s/^$lina$cxpisa/$lina$cx/;
	$aa = substr $_, 17,3;
	$aa =~ s/\s//g;
	$atom = substr $_, 13, 3;
	$atom =~ s/\s//g;
	$res = substr $_, 22,5;
	$res =~ s/\s//g;
	next if ($aa eq 'HOH');
	next if (int($res) ne $res);
	next if ($done{"$res $atom $cx"});

	push @pdb, $_;
	$done{"$res $atom $cx"}=1;

	$chains{$cx}++;
}
close PDB;

open M, "> map.tmp";
for(sort(keys %map)){
	$a = $_;
	$b = $map{$_};
	$a =~ s/\s//g;
	$b =~ s/\s//g;
	%b=();
	for(split '', $b){
		$b{$_}=1;
	}

	printf M "$a\t%s\n", join '', sort(keys %b);
}
close M;

for(@pdb){
	$cx = substr $_, 20,2;
	next unless ($chains{$cx});
	$cx =~ s/\s//g;
	$res = substr $_, 22,5;
	$res =~ s/\s//g;
	$aa = substr $_, 17,3;
	$aa =~ s/\s//g;
	if ($cx ne $last){
		close OUT;
		open OUT, ">> tmpchain/$cx.pdb";
		$Ncx++;
	}
	print OUT;
	$atomcount{$cx}++;
	$last = $cx;
}
