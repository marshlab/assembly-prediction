#!/usr/bin/perl

@cs = (A..Z);
push @cs, (0..9);
push @cs, (a..z); #gets us above 60 

$lim = 1;
$pdb = $ARGV[0];

system "rm -rf tmpchain";
mkdir 'tmpchain';

if (-e $pdb){
	$f = $pdb;
}elsif (-e "$pdb.pdb1"){
	$f = "$pdb.pdb1";
}else{
	print STDERR "Downloading from http://www.rcsb.org/pdb/files/$pdb.pdb1\n";

	if (`which curl`){
		$url = "http://www.rcsb.org/pdb/files/$pdb.pdb1";
		system "curl $url > $pdb.pdb1";
		$f = "$pdb.pdb1";
	}elsif (`which wget`){
		system "wget \"$url\"";
	}else{
		die "ERROR: need curl or wget to download PDB file\n";
	}
}
unless (-e $f){
	die "ERROR: no PDB file $f\n";
}

open PDB, "< $f";

while(<PDB>){
	$cx = $cs[$cxcount];
	if (/^TER/){
		$cxcount++;
	}
	next unless (/^(ATOM|HETATM)/);
	$lina = substr $_, 0, 21;
	$cxpisa = substr $_, 21,1;
	s/^$lina$cxpisa/$lina$cx/;
	$aa = substr $_, 17,3;
	$aa =~ s/\s//g;
	next if ($aa =~ /^(U|C|G|T|A|CA)$/); #skip nucleic acids
	next if ($aa =~ /^(ACE)$/);
	next if ($aa =~ /^(3TL)$/);
	if (/^HETATM/){
		next unless ($aa =~ /(MSE|TPO|KCX|HYP|MLY|MLZ|SEP|CSO|CME|PCA|PTR|CGU|DAL|CSD|FME|OCS|ABA|SMC|CAS|CSS|CSX|CSW|CXM|YOF|MEN|MLE|M3L|XCP|TPQ|ALY|MVA)/); #should be fixed by ca $res$aa
	}
	$atom = substr $_, 13, 3;
	$atom =~ s/\s//g;
	$res = substr $_, 22,5;
	$res =~ s/\s//g;
	next if (int($res) ne $res);
	next if ($done{$res}{$atom}{$cx});

	push @pdb, $_;
	$done{$res}{$atom}{$cx}=1;

	if ($atom eq 'CA'){
		$ca{"$res$aa"}{$cx}=1;
		$chains{$cx}++;
	}
}
close PDB;

for(@pdb){
	$cx = substr $_, 21,1;
	$res = substr $_, 22,5;
	$res =~ s/\s//g;
	$aa = substr $_, 17,3;
	$aa =~ s/\s//g;
	next unless ($ca{"$res$aa"}{$cx});
	next unless ($chains{$cx} >= $lim);
	if ($cx ne $last){
		close OUT;
		open OUT, ">> tmpchain/$cx.pdb";
	}
	print OUT;
	$last = $cx;
}
