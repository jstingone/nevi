### CREATE: List of tracts to exclude for preparation of zip code-level NEVI
## PREP DATA
census_sub_exclusion <- census_nyc_ztracts %>% 
  dplyr::as_tibble() %>% 
  dplyr::transmute(GEOID = as.character(GEOID),
                   ### Demographics
                   # Age
                   prop_age_under18 = S0101_C02_022E/100,
                   prop_age_65plus = S0101_C02_030E/100, 
                   # Female-led households with children
                   female_led_hh_prop = (B11005_007E + B11005_010E)/B11005_001E,
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
                   income1yr_median = B19013_001E, 
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
                   pop = B01003_001E
  ) %>% 
  dplyr::select(-B25035_001E_update)

## CREATE: Exclusion data frame
exclude_ztracts_detailed <- census_sub_exclusion %>% 
  dplyr::mutate(nmiss = rowSums(is.na(.)),
                flag_pop_lt20 = ifelse(pop < 20, 1, 0),
                flag_missing_var = ifelse(nmiss > 0, 1, 0)) %>% 
  dplyr::filter(flag_pop_lt20 == 1 | flag_missing_var == 1)

## CREATE: Exclusion tract list      
exclude_ztracts <- exclude_ztracts_detailed %>% 
  dplyr::mutate(flag_exclude_reason = case_when(
    flag_missing_var == 1 & flag_pop_lt20 == 1 ~ 'Population <= 20',
    flag_missing_var == 1 & flag_pop_lt20 == 0 ~ 'Population > 20, but feature missing for NDI or ToxPi Index')
    ) %>% 
  select(GEOID, flag_pop_lt20, flag_missing_var, nmiss, flag_exclude_reason) # select & reorder variables to export

## EXPORT: Exclusion data frame and list
export(exclude_ztracts, "data/processed/EXCLUSION_LIST_ZTRACTS.csv")
export(exclude_ztracts_detailed, "data/processed/EXCLUSION_LIST_ZTRACTS_detailed.csv")






