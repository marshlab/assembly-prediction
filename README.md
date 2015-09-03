assembly-prediction - predicting ordered assembly pathways from protein complex structures
Copyright (C) 2015 Joseph Marsh, University of Edinburgh

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

INTRODUCTION
This is a set of scripts for predicting assembly and disassembly pathways from protein complex structures. In the current implementation, it requires that you install program AREAIMOL from the CCP4 suite (ccp4.ac.uk). 

To install AREAIMOL, go to ccp4.ac.uk and follow the instructions. Importantly, you need to source the CCP4 initialisation scripts, e.g. on a Mac run the command: 
source /Applications/ccp4-6.5/bin/ccp4.setup-sh

This method, with CCP4, has been tested on Linux and Mac OSX systems.

In principle it should be relatively easy to adapt it to any other program that can calculate SASA (eg NACCESS or POPS). All that would need to be done is to create a replacement for the sasa.pl script that calls your desired program and returns the total SASA for the protein molecule.

USAGE
assembly-prediction.pl pdbid [-options]

pdbid can either be a 4 letter PDB ID, in which case the biological unit will automatically be downloaded, or it can be the name of a pdb file.

The default behaviour is to predict assembly pathways, considering only protein chains. However, there are some other options you can set:

-dis: This calculates the disassembly pathway as in Marsh et al, Cell 2013. In this case, we start from the full complex and iteratively break the smallest possible interface, as described in that paper. It will output a file called pdbid.interfaces that stores the sizes of the pairwise interfaces between subunits, which will make it much faster if re-run. This method assumes that sasa between chains is pairwise additive, which is not always true. For example, given a complex ABC with three different subunits, it will assume that the interface formed between A and BC is equal to the interface between A and B plus the interface between A and C. This can be wrong in some cases, but it is a useful approximation that makes the calculations much much faster, and usually gives the same assembly pathway.

-disfull: This calculates the disassembly pathway, without assuming additive SASA. This can be extremely slow (days for a complex with >20 subunits), and usually gives the same or very similar results as -dis. Both this and the default assembly mode and this create a pdbd.sasa file that stores SASA values of subcomplexes, making it much faster upon re-calculation, or upon resuming if calculation is interupted.

-useall: Normally only protein chains are considered. This will include other chains be they nucleic acid or small ligands. We have not validated this experimentally, but it could be useful or interesting in some circumstances.

The script out_chains.pl converts the pdb file of your complex into a set of files corresponding to each chain in the structure. These are created in the 'tmpchain' directory. The chain IDs output are not necessarily the same as those present in the pdb file, since pdb biological units can contain repeated chains. Instead, they are named sequentially A, B, C, etc according to the order they appear in pdb file. The current version of out_chains.pl also outputs individual ligands to their own files, but this means that chain names are not always the same as in refs 1 & 2. To get chain names that are identical to these publications, replace out_chains.pl with out_chains_old.pl within assembly-prediction.pl

REFERENCES

1) Wells JA, Bergendahl LT & Marsh JA (2015) Operon gene order is optimized for protein complex assembly.
2) Marsh JA, Hernandez H, Hall Z, Ahnert SE, Perica T, Robinson CV & Teichmann SA (2013) Protein complexes are under evolutionary selection to assemble via ordered pathways. Cell 153:461-470

CONTACT
Dr Joseph Marsh
MRC Human Genetics Unit
Institute of Genetics and Molecular Medicine
University of Edinburgh
Edinburgh EH4 2XU
United Kingdom

joseph.marsh@igmm.ed.ac.uk
