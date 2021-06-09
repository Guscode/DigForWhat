# DigForWhat analyses
This folder contains the data and scripts for conducting analyses.
The elevation raster used is too large for Github, why it should be donloaded like this:


1. Before the data kan be accessed, one needs to create a user on https://kortforsyningen.dk/indhold/min-side-0.
2. To access the terrain elevation model of Denmark, a file transfer protocol folder is downloadeded through ftp://ftp.kortforsyningen.dk/HIP/randbetingelser/oevrige/terraenmodel/



When downloading it, please select the following
- Geometritype: Punkter
- Format: ESRI Shapefile
- Referencesystem: Længde-bredde/WGS84

files in this folder:
- elevation.r: script for performing elevation analysis
- point_patterns.r: script for performing point pattern analysis



