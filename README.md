assembly-prediction - predicting ordered assembly pathways from protein complex structures

Joseph Marsh (joseph.marsh@igmm.ed.ac.uk)
MRC Human Genetics Unit
Institute of Genetics and Molecular Medicine
University of Edinburgh
www.josephmarsh.net

REFERENCES
Well JA, Bergendahl LT, Teichmann SA & Marsh JA (2015) Operon gene order is optimized for protein complex assembly.
Marsh JA, Hernandez H, Hall Z, Ahnert SE, Perica T, Robinson CV & Teichmann SA (2013) Protein complexes are under evolutionary selection to assemble via ordered pathways. Cell 153:461-470

INTRODUCTION
This is a set of scripts for predicting assembly and disassembly pathways from protein complex structures. It requires the program "areaimol" from the CCP4 suite (ccp4.ac.uk), although it could easily be adapted to use a different program for calculating solvent accessible surface area (SASA).

INSTALLING CCP4
Go to ccp4.ac.uk and install. Tested on Linux and Mac. Make sure to source scripts.

USAGE
assembly-prediction.pl pdb [-options]

DESCRIPTION

The default behaviour is to predict assemlby pathways descripte. Normal 4 letter pdb biological unit. Designed to work with biological unit format PDB. However, you can also specificy a filename and it will run on that file.

Other options can be set:
-dis: calculates the disassembly pathway as in Marsh et al (Cell 2013). This assumes additive SASA, which is not true, but it is way faster. Outputs a pdb.interfaces file, makes it much faster upon recalculation.

-disfull: calculates the disassembly pathway, without assuming additive SASA. This can be extremely slow (days for a complex with >20 subunits), and usually gives the same or very similar results. Both default mode and this create a pdb.sasa file that stores SASA values of subcomplexes, making it much faster upon re-calculation, or upon resuming if calculation is interupted.

-useall: normally only protein chains are considered. This will consider other chains be they nucleic acid or small ligands. 

