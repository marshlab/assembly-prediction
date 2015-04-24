#!/usr/bin/perl

for(`cat map.tmp`){
	@c=split;
	$map{$c[0]}=$c[1];
}

for $p (`ls tmpchain/*.pdb`){
	chomp $p;
	$cx = substr $p,9,1;
	$cx = (split '\.', (split '\/', $p)[1])[0];
	$a=$h=$o=$y=0;
	%n=();
	for(`cat $p`){
		@c=split;
		$n{$c[-1]}++;
		if ($c[-1] eq 'H'){
			$y++;
		}elsif (/^ATOM/){
			$a++;
		}else{
			$h++;
		}
	}
	print "$cx\t$map{$cx}\t$a\t$h\t$y\t";
	for(keys %n){
		print "$_-$n{$_},";
	}
	print "\t";
	system "pdb2seq.pl $p . | tail -1";
}
