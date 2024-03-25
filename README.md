# MINFLUX data Viewer

## Description
A MATLAB application with UI to provide visualization, processing, and analysis tools for MINFLUX data.
It is initially created in order to support a user project, which is to tracking Rotor movement with labelled fluorescent molecule with MINFLUX microscopy.


## Prerequisite
- MATLAB R2016a or later release
- MINFLUX raw data (.mat format; if overlay of confocal channel will be needed, you will also need the .msr format raw data).



## How to use

1. Clone / Download the main branch to a folder on disk;
2. Right click on the script initApp.m, and Run. If in case there's no Run option, open it in MATLAB and run it. The main UI of the MINFLUX data plot application should appear.
3. Click on the Load Data button to load a MATLAB (.mat) format raw data of MINFLUX. The data can be:    
    - directly exported from Abberior Imspector software;
    - converted from numpy format (with this [python script](/code/additional_functions/npy2mat.py) as SMAP workflow);
    - converted from zarr format (with this [python script](/code/additional_functions/zarr2mat.py));




## Debug and Error report
 In case of error or bugs, please contact <ziqiang.huang@embl.de>, or create a issue to this repo.

## Version
 v1.0: 2023.10.12   initial commit to EMBL gitlab
 v1.1: 2024.03.25   new function added: filter import/export; parser of new Abberior data format

## Known issues
 - histogram plot sometimes won't update correctly, with attribute has single constant value, or most identical values.

## Publication

- Please upload data on public archives (such as [Bioimage archive](https://www.ebi.ac.uk/bioimage-archive/)) for publication purposes.
