# DigForWhat

This repository contains the code used for making the app [DigForWhat](https://vftgustav.shinyapps.io/DigForWhat/).<br/> 
DigForWhat is an interactive app that lets you explore ancient findings in Denmark from the dataset [Fund og Fortidsminder](https://www.kulturarv.dk/fundogfortidsminder/).<br/>

The app was created by [Frida](github.com/frillecode/), [Marie](github.com/marmor97), and [Gustav](github.com/guscode/) as a part of our exam in [spatial analytics](https://kursuskatalog.au.dk/da/course/101991/Spatial-Analytics) at Aarhus University. 

<p align="center">
  <a href="https://github.com/Guscode/DigForWhat/">
    <img src="readme_files/github_gif_map.gif" alt="Logo" width=750 height=375>
  </a>

</p>

## How To Run

Here is a guide for using the code in this repository on your local machine. All the code was produced and tested on an Ubunto operating system (Version: 18.04.5 LTS (Bionic Beaver))

### Running the app on your own computer

In order to launch the app on your own computer please follow these steps: <br/>
Requirements: <br/>
- [R](https://www.r-project.org/) Version >= 4.0
- [Rstudio](https://www.rstudio.com/products/rstudio/download/#download) Version >= 1.3
- [Git](https://git-scm.com/)


1. Clone this repository to your own computer <br/>

Please copy the code below into your terminal
```bash
git clone https://github.com/Guscode/DigForWhat.git
cd DigForWhat
```


2. Add the 'Fund og Fortidsminder data <br/>

The data should be downloaded from here: [fund og fortidsminder](https://www.kulturarv.dk/fundogfortidsminder/Download/) <br/>
Please download the shapefile with CRS WGS84 by selecting the following
- Geometritype: Punkter
- Format: ESRI Shapefile
- Referencesystem: Længde-bredde/WGS84 

Afterwards, please download the version with CRS UTM 32N:
- Geometritype: Punkter
- Format: ESRI Shapefile
- Referencesystem: UTM 32N/ETRS89

When the data is downloaded, please unzip the file and place all files in the data folder <br/>

3. Launch the app <br/>
Open digforwhat.r in rstudio and press run app. <br/>
If English version is needed, please select digforwhat_english.r instead.

In order to combat possible encoding errors caused by ÆÅØ, please run:
```bash
Sys.setlocale(category = "LC_ALL", locale = "UTF-8")
```


_enjoy_

### Running analyses on your own computer

1. Clone this repository to your own computer <br/>


Please copy the code below into your terminal
```bash
git clone https://github.com/Guscode/DigForWhat.git
cd DigForWhat
```


2. Add elevation raster <br/>


- Before the data kan be accessed, one needs to create a user on https://kortforsyningen.dk/indhold/min-side-0.
- To access the terrain elevation model of Denmark, a file transfer protocol folder is downloaded through ftp://ftp.kortforsyningen.dk/HIP/randbetingelser/oevrige/terraenmodel/
- The link will ask you to open in finder, where you can log in with your username and password.

Please place the files in the analyses folder

3. Run analyses <br/>


In Rstudio open and run elevation.r and point_patterns.r

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/Guscode/DigForWhat/blob/main/LICENSE) file for details.


## Contact
For further questions, please get in touch with us here gustavaarup0111@gmail.com. 
