# Neighborhood Environmental Vulnerability Index 
***

**Citation:** We are in the process of preparing a manuscript describing the creation of this vulnerability index and will include a citation here when it is available. Our manuscript will include more information about the creation and potential applications of the index.

## 1. Overview
We developed a Neighborhood Environmental Vulnerability Index (NEVI) to measure vulnerability to environmental pollution using publicly available data. We applied the [Toxicological Prioritization Index (ToxPi)](https://toxpi.org/) to integrate data across different domains, characterize neighborhood vulnerability to environmental pollution in New York City (NYC), and determine if sources of vulnerability varied across neighborhoods.

## 2. Downloading the NEVI for NYC
The NEVI as we have currently created it can be downloaded in the data/processed/ folder. The data file is available in multiple formats at the following spatial scales:

*Census tract-level*
- CSV: nevi_final.csv
- R Data file: nevi_final.rds

*Zip code-level*
- CSV: nevi_final_zip.csv
- R Data file: nevi_final_zip.rds

## 2. Folder and File Structure
### Folder Structure
We have organized relevant files in the creation of the NEVI in the following folders:
- **code and instructions:** Code for the creation of the index
- **data:** 
	- **data/raw:** data files downloaded before any data cleaning/processing
	- **data/processed:** data files after any data cleaning/processing or created manually
- **figures and tables:** figures and tables created from our code.


## 3. Data Sources
We used the two primary data sources for the following features used to calculate the NEVI:
- [U.S. American Community Survey, 5-year estimates from 2015-2019](https://www.census.gov/data/developers/data-sets/acs-5year.2019.html): demographics, economic indicators, and residential characteristics
	- Request a U.S. Census API key [here](https://api.census.gov/data/key_signup.html)
- [U.S. Centers for Disease Control and Prevention PLACES 2020](https://chronicdata.cdc.gov/500-Cities-Places/PLACES-Local-Data-for-Better-Health-Place-Data-202/q8xq-ygsk): health status information (health behaviors, conditions, preventive practices, and insurance access)

Other data sources to create zip code-level NEVI.
- [Modified zip code tabulation areas](https://data.cityofnewyork.us/Health/Modified-Zip-Code-Tabulation-Areas-MODZCTA-/pri4-ifjk)
- Zip Tract Crosswalk


## 4. Calculating the NEVI
Please follow the following steps to calculate the NEVI
### Requirements
1. Download the following software: 
- [R](https://cran.r-project.org/bin/windows/base/)
- [RStudio](https://www.rstudio.com/products/rstudio/download/#download) or another R graphical user interface
- [ToxPi Graphical User Interface](https://toxpi.org/)
2. Run the following code in R to install the required packages:
- These are needed for the creation of the NEVI. The cluster package is optional 
	```installation_nevi	
	install.packages(c(''tidyverse','tidycensus','rio','cluster','nycgeo'), dependencies = TRUE)
	```
- These are needed for the creation of clusters and related figures and tables.
	```installation_figs_tabs
	install.packages(c('skimr','janitor','factoextra','sf','ggpubr','ggsn','ggspatial','tigris','ggsflabel','ggpubr','colorBlindness','ggpattern','gplots'), dependencies = TRUE)
	```
3. We used the following versions of software and packages:
- **Software**:
	- *R:* 4.1.1 ("Kick Things")
	- *RStudio:* 2021.09.0+382 ("Ghost Orchid")
	- *ToxPi GUI:* version 2.3, August 2019 update
- **Packages**:
	- *tidyverse:* 1.3.1 
	- *tidycensus:* 1.1.2 
	- *rio:* 0.5.29 
	- *cluster:* 2.1.2 
	- *nycgeo:* 0.1.0.9000 
- **Optional Packages**
	- *skimr:* 2.1.3 
	- *janitor:* 2.1.0 
	- *factoextra:* 1.0.7 
	- *sf:* 1.0.3 
	- *ggpubr:* 0.4.0 
	- *ggsn:* 0.5.0 
	- *ggspatial:* 1.1.5 
	- *tigris:* 1.5 
	- *ggsflabel:* 0.0.1 
	- *ggpubr:* 0.4.0 
	- *colorBlindness:* 0.1.9 
	- *ggpattern:* 0.2.0 
	- *gplots:* 3.1.1 


### Downloading the Required Data for Creating the NEVI
Download the following data:
- U.S. Centers for Disease Control and Prevention PLACES 2020
	- Download [here]().
- U.S. American Community Survey, 5-year estimates from 2015-2019
	- To download the data in refer to code/01-download-census-data.Rmd 
	- More information about the [here](https://www.census.gov/data/developers/data-sets/acs-5year.2019.html).



### Code and Instructions
To calculate the NEVI, you will need to follow the instruction in these documents:
- A1-download-census-data.Rmd: Download features from the U.S. Census American Community Survey needed to calculate the index
- A2-preprocess-nevi-features.Rmd: Prepare features to input into ToxPi.
- A3-calculate-nevi-toxpi-gui.docx: Create the NEVI and subdomain scores using Toxpi.
- A4-clean-nevi.Rmd: Clean the output from ToxPi and create domain scores.

There are also other code available to accomplish other tasks:
- B1-create-nevi-clusters.Rmd: Create clusters based on NEVI subdomain scores and their corresponding weights using hierarchical clustering
- B2-calculate-ndi-svi.Rmd: Create previously created indices, the Neighborhood Deprivation Index (NDI) and SVI (Social Vulnerability Index)
- B3-create-figures-tables.Rmd: Create tables and figures used in the manuscript.
- B4-calculate-nevi-zip.Rmd: Calculate zip code-level NEVI


## 5. Grant Information
This creation of this index was supported by grants from the Health Effects Institute (#4985-RFA20-1B/21-8) and the National Institute of Environmental Health Sciences, National Institutes of Health (T32ES007322, R00ES027022, P30ES023515, R01ES030717, and P30ES009089).

