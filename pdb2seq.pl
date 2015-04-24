#!/usr/bin/perl

($pdb, $chain) = @ARGV;

$chain = " " if ($chain eq '_');
$nam = (split("\/", $pdb))[-1];
$nam =~ s/\..*$//;
$disorder = 0;

for(`cat $pdb`){
        $cx = substr $_, 21,1;
        $ter{$cx} = 1 if (/^TER/);
        next unless (/^(ATOM|HETATM)/);
        next if ($ter{$cx});
        next unless ($cx eq $chain or $chain eq '.');
        $atom = substr $_, 13, 3;
        $atom =~ s/\s//g;
        next unless ($atom eq 'CA');

        $res = substr $_, 22,5;
        $res =~ s/\s//g;

        $occ = substr $_, 56, 4;
        $occ =~ s/\s//g;
        #next unless ($occ >= 0.5);

        $aa = substr $_, 17,3;
        next if ($aa =~ /^(ACE)$/);
        $xxx=$res;
        next if (int($res) ne $res);

        $lines{$res}{++$nr{$res}}=$_;

}

for $i(sort {$a<=>$b} keys %lines){
        for(1..$nr{$i}){
                $line = $lines{$i}{$_};
                push @out, $lines{$i}{$_};
        }
}

for(@out){
        $atom = substr $_, 13, 3;
        $atom =~ s/\s//g;
        next unless ($atom eq 'CA');

        $res = substr $_, 22,5;
        $res =~ s/\s//g;
        $aa = substr $_, 17,3;


        if ($last eq ''){
                $start = $res;
        }

        if (($last ne '') and  ($res-$last > 1)){
                for(2..($res-$last)){
                        $disorder++;
                }
        }
        if (($res < $last) and ($last ne '')){
                print STDERR "$pdb $res out of order\n";
                next;
        }

        $last = $res;


        $aa =~ s/ALA/A/;
        $aa =~ s/CYS/C/;
        $aa =~ s/ASP/D/;
        $aa =~ s/GLU/E/;
        $aa =~ s/PHE/F/;
        $aa =~ s/GLY/G/;
        $aa =~ s/HIS/H/;
        $aa =~ s/ILE/I/;
        $aa =~ s/LYS/K/;
        $aa =~ s/LEU/L/;
        $aa =~ s/MET/M/;
        $aa =~ s/ASN/N/;
        $aa =~ s/PRO/P/;
        $aa =~ s/GLN/Q/;
        $aa =~ s/ARG/R/;
        $aa =~ s/SER/S/;
        $aa =~ s/THR/T/;
        $aa =~ s/VAL/V/;
        $aa =~ s/TRP/W/;
        $aa =~ s/TYR/Y/;

        $aa =~ s/MSE/M/;
        $aa =~ s/SOC/C/; #dioxyselocysteine
        $aa =~ s/P1L/C/; #palmitolyation
        $aa =~ s/5HP/E/; #pyroglutamic acid
        $aa =~ s/KCX/K/; #
        $aa =~ s/MLY/K/; #dimethyl lysine
        $aa =~ s/SEP/S/; #
        $aa =~ s/TPO/T/; #
        $aa =~ s/CGU/E/; #
        $aa =~ s/PCA/D/; #could also be N
        $aa =~ s/IAS/D/; #
        $aa =~ s/MLE/L/; #
        $aa =~ s/PTR/Y/; #
        $aa =~ s/CSO/C/; #
        $aa =~ s/SMC/C/; #
        $aa =~ s/CME/C/; #
        $aa =~ s/CMH/C/; #
        $aa =~ s/CSD/C/; #
        $aa =~ s/HYP/P/; #
        $aa =~ s/MVA/V/; #

        if (length($aa)>1){
                print STDERR "$pdb can't covert $aa\n";
                $output .= "X";
        }else{
                $output .= "$aa";
        }
}
print ">$nam $start $disorder\n$output\n";
