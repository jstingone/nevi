Neighborhood Environmental Vulnerability Index, 2019: Preprocessing NEVI
Features
================
Stephen P. Uong; Contributors: Jiayi Zhou, Jeanette A. Stingone
3/29/2022

Below are steps to preprocess the features used to calculate the NEVI
with the Toxicological Priority Index Graphical User Interface (ToxPi
GUI).

### 1. Set Working Directory

Set the working directory to one folder up from the RMarkdown file for
later data export.

``` r
knitr::opts_knit$set(root.dir = '..') 
```

### 2. Load Required Libraries

Load the following required libraries.

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 4.1.3

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.5     v dplyr   1.0.7
    ## v tidyr   1.1.4     v stringr 1.4.0
    ## v readr   2.0.2     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(rio)
```

    ## Warning: package 'rio' was built under R version 4.1.3

### 3. Import the Data

We imported the following Census tract-level data files:

-   [U.S. Centers for Disease Control and Prevention PLACES in
    2020](https://chronicdata.cdc.gov/500-Cities-Places/PLACES-Local-Data-for-Better-Health-Place-Data-202/q8xq-ygsk)

    -   We previously downloaded this data in the link above and saved
        the file in `data/raw/US CDC PLACES`

-   [U.S. Census American Community Survey, 2015-2019 5-year
    estimates](https://www.census.gov/data/developers/data-sets/acs-5year.2019.html)

    -   We previously downloaded this data using our code
        `A1-download-census-data.Rmd` and saved the file in
        `data/raw/US Census`

``` r
setwd('C:/Users/steph/OneDrive - cumc.columbia.edu/Phi/My Courses/Columbia/Work/Research - Jeanette/projects/covid-vulnerability-index/comms/git nvi')
# US CDC PLACES data, 2020 release
PLACES_orig <- rio::import('data/raw/US CDC PLACES/PLACES_2020_release.csv')
# US Census, American Community Survey data 2015-2019 5-Year Estimates
census_orig <- readRDS( file = "data/raw/US Census/us_census_acs_2019.rds")
```

### 4. Clean the data

#### 4.1. Clean U.S. CDC PLACES Data

We first cleaned the U.S. CDC PLACES data, transforming variables so
that larger, more positive values of features would correspond to
greater vulnerability.

``` r
PLACES_clean <- PLACES_orig %>% 
  dplyr::mutate(tract = as.character(TractFIPS),
                CHECKUP_CrudePrev = -CHECKUP_CrudePrev - min(-CHECKUP_CrudePrev, na.rm = TRUE),
                COREM_CrudePrev = -COREM_CrudePrev - min(-COREM_CrudePrev, na.rm = TRUE),
                COREW_CrudePrev = -COREW_CrudePrev - min(-COREW_CrudePrev, na.rm = TRUE),
                DENTAL_CrudePrev = -DENTAL_CrudePrev - min(-DENTAL_CrudePrev, na.rm = TRUE),
                CERVICAL_CrudePrev = -CERVICAL_CrudePrev - min(-CERVICAL_CrudePrev, na.rm = TRUE),
                CHOLSCREEN_CrudePrev = -CHOLSCREEN_CrudePrev - min(-CHOLSCREEN_CrudePrev, na.rm = TRUE),
                COLON_SCREEN_CrudePrev = -COLON_SCREEN_CrudePrev - min(-COLON_SCREEN_CrudePrev, na.rm = TRUE),
                MAMMOUSE_CrudePrev = -MAMMOUSE_CrudePrev - min(-MAMMOUSE_CrudePrev, na.rm = TRUE)) %>% 
  dplyr::select(tract,
    'CSMOKING_CrudePrev',  'BINGE_CrudePrev',  'LPA_CrudePrev',  'OBESITY_CrudePrev',  'SLEEP_CrudePrev',  
    'BPHIGH_CrudePrev',  'BPMED_CrudePrev',  'CANCER_CrudePrev',  'CASTHMA_CrudePrev',  'CHD_CrudePrev',  
    'STROKE_CrudePrev',  'COPD_CrudePrev',  'DIABETES_CrudePrev',  'HIGHCHOL_CrudePrev',  'KIDNEY_CrudePrev',  
    'MHLTH_CrudePrev',  'PHLTH_CrudePrev',  'TEETHLOST_CrudePrev',  'CHECKUP_CrudePrev',  'COREM_CrudePrev',  
    'COREW_CrudePrev',  'DENTAL_CrudePrev',  'CERVICAL_CrudePrev',  'CHOLSCREEN_CrudePrev',  
    'COLON_SCREEN_CrudePrev',  'MAMMOUSE_CrudePrev',  'ACCESS2_CrudePrev') 
```

#### 4.2. Clean U.S. Census ACS Data

We cleaned the U.S. Census ACS data, calculating proportions and
transforming features so that larger values of features would correspond
to greater vulnerability. This code below still includes population
(`misc_pop`) to later generate a list of excluded tracts and race and
ethnicity variables that are not included in the NEVI (only used in
sensitivity analysis).

``` r
census_features <- census_orig %>% 
  dplyr::as_tibble() %>% 
  dplyr::transmute(
    GEOID = as.character(GEOID),
    ### Demographics
    # Age
    prop_age_under18 = S0101_C02_022E/100,
    prop_age_65plus = S0101_C02_030E/100, 
    # Female-led households with children
    female_led_hh_prop = (B11005_007E + B11005_010E)/B11005_001E,
    # race/ethnicity
    white_prop = B02001_002E/B02001_001E,
    black_prop = B02001_003E/B02001_001E,
    asian_prop = B02001_005E/B02001_001E,
    aian_prop = B02001_004E/B02001_001E,
    nhpi_prop = B02001_006E/B02001_001E, 
    race_other_prop = B02001_007E/B02001_001E,
    race_mult_prop = B02001_008E/B02001_001E,
    aian_nhpi_mult_other_prop = aian_prop + nhpi_prop + race_other_prop + race_mult_prop,
    hisp_prop = B03003_003E/B03003_001E,
       # race/ethnicity, not hispanic
    white_nonhisp_prop = B03002_003E/B03002_001E, 
    black_nonhisp_prop = B03002_004E/B03002_001E,
    asian_nonhisp_prop = B03002_006E/B03002_001E,
    aian_nonhisp_prop = B03002_005E/B03002_001E,
    nhpi_nonhisp_prop = B03002_007E/B03002_001E, 
    race_other_nonhisp_prop = B03002_008E/B03002_001E,
    race_mult_nonhisp_prop = B03002_009E/B03002_001E,
    aian_nhpi_mult_other_nonhisp_prop = aian_nonhisp_prop + nhpi_nonhisp_prop + race_other_nonhisp_prop + race_mult_nonhisp_prop,
    # language
    eng_lim_prop = (B16005_007E+B16005_008E+B16005_012E+B16005_013E+B16005_017E+B16005_018E+
                      B16005_022E+B16005_023E+B16005_029E+B16005_030E+B16005_034E+B16005_035E+
                      B16005_039E+B16005_040E+B16005_044E+B16005_045E)/B16005_001E,
    # US entry period
    usentry_2010_prop = B05005_002E/B05005_001E,
    # Nativity
    forborn_prop = B05002_013E/B05002_001E,
    # US Citizenship
    uscitizen_no_prop = B05001_006E/B05001_001E,
    # Disability status
    disability_prop = S1810_C03_001E/100,
    # Single Parent
    single_parent_prop = (B23008_008E+B23008_021E)/B23008_001E,
    # Means of transportation to work
    publictrans_taxi_mcycle_bike_walk_prop = (B08101_025E+B08101_041E+B08101_033E)/B08101_001E,
    # Travel time
    travel_time_work_minute = B08013_001E,
    # living alone
    prop_living_alone = B11001_008E/B11001_001E,
    ### Economic Indicators
    # Income
    income1yr_neg_median = -B19013_001E - min(-B19013_001E, na.rm = TRUE), # MADE NEGATIVE B/C REVERSE DIRECTION
    # Poverty
    poverty1yr_prop = B17001_002E/B17001_001E,
    # Occupation
    service_manual_prop = (C24010_019E+C24010_030E+C24010_034E+C24010_055E+C24010_066E+C24010_070E)/C24010_001E,
    # Gini index
    gini_index = B19083_001E,
    # Unemployment
    unemployment_prop = (B23001_015E+B23001_022E+B23001_029E+B23001_036E+B23001_043E+B23001_050E+B23001_057E+B23001_064E+B23001_071E+B23001_101E+B23001_108E+B23001_115E+B23001_122E+B23001_129E+B23001_136E+B23001_143E+B23001_150E+B23001_157E)/(B23001_013E+B23001_020E+B23001_027E+B23001_034E+B23001_041E+B23001_048E+B23001_055E+B23001_062E+B23001_069E+B23001_099E+B23001_106E+B23001_113E+B23001_120E+B23001_127E+B23001_134E+B23001_141E+B23001_148E+B23001_155E), # among those in labor force
    # Education
    education_less_hs_prop = (B15003_002E+B15003_003E+B15003_004E+B15003_005E+B15003_006E+B15003_007E+B15003_008E+B15003_009E+
                              B15003_010E+B15003_011E+B15003_012E+B15003_013E+B15003_014E+B15003_015E+B15003_016E)/B15003_001E,
    # Vehicle
    vehicle_avail_no_prop = B08014_002E/B08014_001E,
    ### Residential density
    # Population density
    pop_density = B01003_001E/(ALAND/2589988.1103), # denom: convert square meters to square miles
    # Group quarters
    group_quarters_prop = B26001_001E/B01003_001E,
    # Occupants per room
    occ_room_1_01plus_prop = (B25014_005E+B25014_006E+B25014_007E+B25014_011E+B25014_012E+B25014_013E)/B25014_001E,
    # Year structure built
    B25035_001E_update = ifelse(B25035_001E == 0, 1939, B25035_001E), # Plug in 1939 for values 1939 or earlier
    B25035_001E_update = ifelse(B25035_001E_update == 18, NA, B25035_001E_update), # Plug in missing for weird values of 18 for year for now
    age_structure_2019 = 2019 - B25035_001E_update,
    # Type of housing
    str_units_1att_2plus_mobile_boat_rv_van_prop = (B25024_003E+B25024_004E+B25024_005E+B25024_006E+B25024_007E+B25024_008E+B25024_009E+B25024_010E+B25024_011E)/B25024_001E,
    str_units_20plus = (B25024_008E+B25024_009E)/B25024_001E,
    # Geographic mobility
    move1yr_prop = (B07013_007E+B07013_010E+B07013_013E+B07013_016E)/B07013_001E,
    # Housing vacancy
    str_vacancy_prop = B25002_003E/B25002_001E,
    ##### MISC ##### 
    misc_pop = B01003_001E)
census_clean <- census_orig %>% 
  dplyr::transmute(row = row_number(),
                   tract = as.character(GEOID),
                   CASRN = '',
                   Name = '') %>% 
  dplyr::inner_join(census_features %>% dplyr::rename(tract = GEOID), by = "tract") %>%
  dplyr::select(-B25035_001E_update) 
```

### 5. Additional Preprocessing

#### 5.1. Prepare Exclusions List

-   We imported a list of Census tracts that we previously created to be
    excluded because they had

    1.  A population of less than 20 or

    2.  At least 1 missing feature used in the NEVI or Neighborhood
        Deprivation Index (NDI), one of the indices to which the NEVI
        was compared.

-   The exclusion list we used considers features used in *both* the
    NEVI and NDI.

    -   We have also provided code (commented out below) that can be
        used to create a list of Census tracts to be excluded *only*
        based on features used in the NEVI.

-   We do not currently include race and ethnicity in the NEVI, but we
    later include these variables for sensitivity analysis.

``` r
# Features not included in the NEVI
vars_raceeth <- c('white_prop', 'aian_prop', 'nhpi_prop', 'race_other_prop', 'race_mult_prop', 'black_prop', 'asian_prop', 'aian_nhpi_mult_other_prop',
                 'black_nonhisp_prop','asian_nonhisp_prop','aian_nhpi_mult_other_nonhisp_prop','hisp_prop', 'white_nonhisp_prop','aian_nonhisp_prop', 'nhpi_nonhisp_prop', 'race_other_nonhisp_prop', 'race_mult_nonhisp_prop')

## Example code to obtain exclution list
# tract_exclusions_list_id <- census_clean %>%  
#  dplyr::select(.dots = -c(vars_raceeth, CASRN, Name)) %>% 
#  dplyr::mutate(missing_n = rowSums(is.na(.))) %>%
#  dplyr::filter(misc_pop <= 20 | missing_n > 0) %>%
#  dplyr::transmute(SID = tract)

## Clean exclusions list
tract_exclusions_list <- import("data/processed/preprocessing/list_tract_exclusion_20210628.csv")
tract_exclusions_list_id <- tract_exclusions_list %>% 
  dplyr::filter(flag_exclude_FINAL == 1) %>% 
  dplyr::transmute(SID = as.character(GEOID))
```

#### 5.2. Merge Data and Apply Exclusions

We merged the data from the U.S. CDC 500 Cities project and the U.S.
Census before applying our exclusions that we described above.

#### 5.3. Add ToxPi Header to NEVI Features

We added a header that we manually created needed to specify options to
create the NEVI in the ToxPi GUI. The header contains information about
the slices, slice weights, name of the slices, and color of the slices.
For example:

``` r
# Import header needed for Toxpi GUI
header_toxpi <- read.csv("data/processed/preprocessing/toxpi/header/toxpi_header.csv", header = F, colClasses = rep("character",58))
# Create function to bind ToxPi header to NEVI features
bind_toxpi_header <- function(df_header, df_features){
  colnames_features <- names(df_features)
  df_colnames_features <- data.frame(matrix(ncol = length(colnames_features), colnames_features))
  rbind(setNames(df_header, colnames_features), # header
        setNames(df_colnames_features, colnames_features),  # column names
        df_features) # features
}
# Bind ToxPi header to NEVI features
toxpi_export <- bind_toxpi_header(header_toxpi, tract_nevi_features_final)
```

### 6. Export NEVI Features with and without ToxPi Header

We exported our data into a spreadsheet with the NEVI features with and
without the header needed to import the spreadsheet into the ToxPi GUI.

``` r
export(toxpi_export, "data/processed/preprocessing/nevi_tract_features_toxpiheader.csv", col.names = FALSE)
saveRDS(tract_nevi_features_final, "data/processed/preprocessing/nevi_tract_features.rds")
```

### 7. (Optional) Repeat Steps 5-6 for Sensitivity Analysis of Race and Ethnicity

We repeated steps 5-6 to see how the NEVI may have change if we included
race and ethnicity variables.

#### 7.1 Merge Data and Apply Exclusions

``` r
# Overlapping race and ethnicity categories
tract_nevi_features_raceeth_olap <- tract_nevi_features_exclusions %>% 
  dplyr::select(-c(misc_pop, 
                   white_prop, aian_prop, nhpi_prop, race_other_prop, race_mult_prop, 
                   black_nonhisp_prop, asian_nonhisp_prop, aian_nhpi_mult_other_nonhisp_prop, white_nonhisp_prop, aian_nonhisp_prop, nhpi_nonhisp_prop, race_other_nonhisp_prop, race_mult_nonhisp_prop))
# Non-overlapping race and ethnicity categories
tract_nevi_features_raceeth_no_olap <- tract_nevi_features_exclusions %>% 
  dplyr::select(-c(misc_pop, 
                   white_prop, aian_prop, nhpi_prop, race_other_prop, race_mult_prop, black_prop, asian_prop, aian_nhpi_mult_other_prop, 
                   white_nonhisp_prop, aian_nonhisp_prop, nhpi_nonhisp_prop, race_other_nonhisp_prop, race_mult_nonhisp_prop))
```

#### 7.2 Add ToxPi Header to NEVI Features

``` r
# Import header needed for Toxpi GUI
header_toxpi_raceeth_hispsub <- read.csv("data/processed/sensitivity analysis/race and ethnicity/toxpi/header/toxpi_header_raceeth_hispsub.csv", header = F, colClasses = rep("character",62))
header_toxpi_raceeth <- read.csv("data/processed/sensitivity analysis/race and ethnicity/toxpi/header/toxpi_header_raceeth.csv", header = F, colClasses = rep("character",62))
# Bind ToxPi header to NEVI features
toxpi_export_raceeth_olap <- bind_toxpi_header(header_toxpi_raceeth, tract_nevi_features_raceeth_olap) # Overlapping race and ethnicity categories
toxpi_export_raceeth_no_olap <- bind_toxpi_header(header_toxpi_raceeth, tract_nevi_features_raceeth_no_olap) # Non-overlapping race and ethnicity categories
toxpi_export_raceeth_hispsub <- bind_toxpi_header(header_toxpi_raceeth_hispsub, tract_nevi_features_raceeth_no_olap) # Non-overlapping race and ethnicity categories, Hispanic as separate subdomain
```

#### 7.3 Export NEVI Features with ToxPi Header

``` r
export(toxpi_export_raceeth_olap, "data/processed/sensitivity analysis/race and ethnicity/nevi_tract_features_toxpiheader_raceeth_olap.csv", col.names = FALSE) # Overlapping race and ethnicity categories
export(toxpi_export_raceeth_no_olap, "data/processed/sensitivity analysis/race and ethnicity/nevi_tract_features_toxpiheader_raceeth_no_olap.csv", col.names = FALSE) # Non-overlapping race and ethnicity categories
export(toxpi_export_raceeth_hispsub, "data/processed/sensitivity analysis/race and ethnicity/nevi_tract_features_toxpiheader_raceeth_hispsub.csv", col.names = FALSE) # Non-overlapping race and ethnicity categories, Hispanic as separate subdomain
```

### 8. Generate the NEVI using the ToxPi GUI

To generate the NEVI in the ToxPi GUI, you will need to complete the
following steps in `A3-calculate-nevi-toxpi-gui.docx`.
