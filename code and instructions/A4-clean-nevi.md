Neighborhood Environmental Vulnerability Index, 2019: Cleaning NEVI Data
from ToxPi GUI Output
================
Stephen P. Uong; Contributors: Jiayi Zhou, Jeanette A. Stingone
3/29/2022

Below are steps to clean the output from the ToxPi GUI that we used to
calculate the NEVI.

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

### 3. Import the Index Generated from the ToxPi GUI

Import the NEVI calculated from the ToxPi GUI to clean the dataset.

``` r
tract_toxpi <- import('data/processed/preprocessing/toxpi/results/nevi_toxpi_results.csv')
tract_nevi_features <- readRDS("data/processed/preprocessing/nevi_tract_features.rds")
```

### 4. Clean Output from the ToxPi GUI

Rename the subdomain slices and calculate domain-specific NEVI scores.

``` r
# CLEAN: Data from ToxPi GUI
tract_toxpi_clean <- tract_toxpi %>%
  dplyr::rename(SID = Source, nevi = `ToxPi Score`) %>% 
  dplyr::mutate(SID = as.character(SID) %>% trimws()) %>% 
  dplyr::select(-c(`HClust Group`, `KMeans Group`, Name)) %>% 
  # Demographics Domain
  dplyr::rename_at(vars(starts_with('DemographicsAge')), funs(paste0('score_demo_age'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsFemaleLed')), funs(paste0('score_demo_femaleled'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsImmigration')), funs(paste0('score_demo_immigration'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsDisability')), funs(paste0('score_demo_disability'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsSingleParent')), funs(paste0('score_demo_singleparent'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsMobility')), funs(paste0('score_demo_mobility'))) %>% 
  dplyr::rename_at(vars(starts_with('DemographicsLiveAlone')), funs(paste0('score_demo_livealone'))) %>% 
  # Economic Domain
  dplyr::rename_at(vars(starts_with('Economic IndicatorsIncomePoverty')), funs(paste0('score_economic_incomepoverty'))) %>% 
  dplyr::rename_at(vars(starts_with('Economic IndicatorsServiceManualJobs')), funs(paste0('score_economic_servicemanual'))) %>% 
  dplyr::rename_at(vars(starts_with('Economic IndicatorsGini')), funs(paste0('score_economic_gini'))) %>% 
  dplyr::rename_at(vars(starts_with('Economic IndicatorsEmployment')), funs(paste0('score_economic_employment'))) %>% 
  dplyr::rename_at(vars(starts_with('Economic IndicatorsEducation')), funs(paste0('score_economic_education'))) %>% 
  dplyr::rename_at(vars(starts_with('Economic IndicatorsVehicleAvail')), funs(paste0('score_economic_vehicleavail'))) %>% 
  # Residential Domain
  dplyr::rename_at(vars(starts_with('Residential DensityPopDensity')), funs(paste0('score_residential_popdensity'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityGroupQuarters')), funs(paste0('score_residential_groupquarters'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityOccPerRoom')), funs(paste0('score_residential_occperroom'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityStrAge')), funs(paste0('score_residential_structage'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityStrAttached')), funs(paste0('score_residential_structattach'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityMove1Yr')), funs(paste0('score_residential_move1yr'))) %>% 
  dplyr::rename_at(vars(starts_with('Residential DensityVacancy')), funs(paste0('score_residential_vacancy'))) %>% 
  # Health status Domain
  dplyr::rename_at(vars(starts_with('Health StatusLifestyle')), funs(paste0('score_healthstatus_lifestyle'))) %>% 
  dplyr::rename_at(vars(starts_with('Health StatusCondition')), funs(paste0('score_healthstatus_condition'))) %>% 
  dplyr::rename_at(vars(starts_with('Health StatusPreventive')), funs(paste0('score_healthstatus_preventive'))) %>% 
  dplyr::rename_at(vars(starts_with('Health StatusLackInsurance')), funs(paste0('score_healthstatus_lackinsurance'))) %>% 
  # Checked: Calculated NEVI score is same as one calculated in toxpi (just rounding differences)
  dplyr::mutate(score_demo = (score_demo_age + score_demo_femaleled + score_demo_immigration + score_demo_disability + score_demo_singleparent + score_demo_mobility + score_demo_livealone)/7,
                score_economic = (score_economic_incomepoverty + score_economic_servicemanual + score_economic_gini + score_economic_employment + score_economic_education + score_economic_vehicleavail)/6,
                score_residential = (score_residential_popdensity + score_residential_groupquarters + score_residential_occperroom + score_residential_structage + score_residential_structattach + score_residential_move1yr + score_residential_vacancy)/7,
                  score_healthstatus = (score_healthstatus_lifestyle + score_healthstatus_condition + score_healthstatus_preventive + score_healthstatus_lackinsurance)/4)
```

    ## Warning: `funs()` was deprecated in dplyr 0.8.0.
    ## Please use a list of either functions or lambdas: 
    ## 
    ##   # Simple named list: 
    ##   list(mean = mean, median = median)
    ## 
    ##   # Auto named with `tibble::lst()`: 
    ##   tibble::lst(mean, median)
    ## 
    ##   # Using lambdas
    ##   list(~ mean(., trim = .2), ~ median(., na.rm = TRUE))
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.

### 5. Merge the NEVI with the NEVI features and clusters

Merge the NEVI with NEVI features.

``` r
tract_nevi <- tract_nevi_features %>% # NEVI features
  dplyr::left_join(tract_toxpi_clean, by = "SID") %>%  # NEVI (cleaned from the ToxPi GUI)
  dplyr::rename(Tract_FIPS = SID) %>% 
  dplyr::relocate(nevi, score_demo, score_economic, score_residential, score_healthstatus, .after = Tract_FIPS) %>% 
  dplyr::select(-c(row, CASRN, Name)) 
```

### 6. (Optional) Specify Counties/Boroughs

Create a column specifying the New York City borough in which the Census
tract is located.

``` r
tract_nevi <- tract_nevi %>%
  dplyr::mutate(County_FIPS = substr(Tract_FIPS, 1, 5),
                borough = case_when(
                  County_FIPS == '36005' ~ 'Bronx',
                  County_FIPS == '36047' ~ 'Brooklyn',
                  County_FIPS == '36061' ~ 'Manhattan',
                  County_FIPS == '36081' ~ 'Queens',
                  County_FIPS == '36085' ~ 'Staten Island'
                )) %>%
  dplyr::select(-County_FIPS) %>%
  dplyr::relocate(borough, .after = nevi)
```

### 7. Export data with the NEVI, features, and clusters

After completing all importing and data cleaning steps, we exported our
final dataset, which included the NEVI, NEVI features, and NEVI
clusters.

``` r
saveRDS(tract_nevi, file = "data/processed/preprocessing/nevi_tract_noclusters.rds")
```
