# DigForWhat data
This folder contains the data needed for building the app and performing the analysis.
The shapefile for the __Fund og Fortidsminder__ data is too large for Github, why it should be downloaded here:
[fund og fortidsminder](https://www.kulturarv.dk/fundogfortidsminder/Download/)


When downloading it, please select the following
- Geometritype: Punkter
- Format: ESRI Shapefile
- Referencesystem: Længde-bredde/WGS84

Files in this folder:
- municipality_mil_united.shp: shapefile containing polygons of municipalities
- preprocessed/anlaeg_description.csv: descriptions of finding-types scraped using scrape_descriptions.rmd in the preprocessing folder
- preprocessed/color_category.csv: colors for all finding types made using the colors.r script in the preprocessing folder
- preprocessed/municipality_analysis.csv: plotting metrics for all municipalities made with the municipality_analysis.rmd in the preprocessing folder
- preprocessed/labs_list.csv: list of unique finding types
- preprocessed/municipal_elevation.csv: elevation data on finding types per municipality made with the script elevation.r in the analyses folder


For more details on the project, please see [project readme](https://github.com/Guscode/DigForWhat)
