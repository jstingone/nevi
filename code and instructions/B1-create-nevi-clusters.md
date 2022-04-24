Neighborhood Environmental Vulnerability Index, 2019: Creating NEVI
Clusters
================
Stephen P. Uong; Contributors: Jiayi Zhou, Jeanette A. Stingone
3/29/2022

Below are steps to create clusters using the NEVI subdomains.

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

``` r
library(factoextra)
```

    ## Welcome! Want to learn more? See two factoextra-related books at https://goo.gl/ve3WBa

``` r
library(cluster)
```

    ## Warning: package 'cluster' was built under R version 4.1.3

### 3: Import the Index Generated from the ToxPi GUI

Import the NEVI calculated from the ToxPi GUI to clean the dataset.

``` r
tract_toxpi <- import('data/processed/preprocessing/toxpi/results/nevi_toxpi_results.csv')
tract_nevi_noclusters <- readRDS("data/processed/preprocessing/nevi_tract_noclusters.rds")
```

### 4. Create NEVI Clusters

#### 4.1. Visualize Gap Statistic

Visualize the gap statistic to help determine optimal number of
clusters. We chose 6 clusters based on the plot and the
characteristics/geographic distribution of the clusters.

``` r
scaled_tract_toxpi = scale(tract_toxpi[-c(1:5)])
mydist<-function(x)dist(x, method="euclidian")
mycluster <- function(x,k) list(cluster=cutree(hclust(mydist(x), method = "complete"),k=k))
gap_stat_10 <- clusGap(scaled_tract_toxpi, FUN = mycluster, K.max = 10, B = 50)
fviz_gap_stat(gap_stat_10) # Choose 6 clusters based on this plot and what we observed when characterizing the clusters.
```

![](B1-create-nevi-clusters_files/figure-gfm/check_clusters-1.png)<!-- -->

#### 4.2 Perform Hierarchical Clustering

Create clusters from the NEVI subdomains (ToxPi slices) using
hierarchical clustering.

``` r
# CREATE: Clusters, Code adapted from the developers of ToxPi 
set.seed(123)
  # Get slice weights
w <- sapply(sapply(names(tract_toxpi)[-c(1:5)],function(x) strsplit(x, "!")),"[",2)
w <- sapply(strsplit(w,split="/"),function(x) {y <- ifelse(length(x)==2,x[2],1);as.numeric(x[1])/as.numeric(y)})
  # Generate cluster
hc <- hclust(dist(tract_toxpi[,-c(1:5)]*rep(w,each=nrow(tract_toxpi))), method="complete")
nevi_cluster_result <- cutree(hc, k = 6) # Cut into 6 clusters using HClusts 
  # Create data frame for cluster data
tract_nevi_cluster <- tract_toxpi %>% 
  dplyr::mutate(Tract_FIPS = Source %>% as.character() %>% trimws(),
                nevi_cluster_orig = nevi_cluster_result %>% as.factor(),
                nevi_cluster = case_when(
                  nevi_cluster_orig == "1" ~ "6",
                  nevi_cluster_orig == "2" ~ "5",
                  nevi_cluster_orig == "3" ~ "4",
                  nevi_cluster_orig == "4" ~ "3",
                  nevi_cluster_orig == "5" ~ "2",
                  nevi_cluster_orig == "6" ~ "1"
                ) %>% as.factor()) %>% 
  dplyr::select(Tract_FIPS, nevi_cluster)
```

### 5. Merge the NEVI Clusters with the NEVI and NEVI Features

Merge the newly created NEVI clusters with the NEVI scores and NEVI
features.

``` r
tract_final <- tract_nevi_noclusters %>% 
  dplyr::left_join(tract_nevi_cluster, by = "Tract_FIPS") %>%  # NEVI clusters
  dplyr::relocate(nevi_cluster, .after = nevi)
```

### 6. Export the Final Data with the NEVI, Features, and Clusters

Export our final dataset, which includes the NEVI, NEVI features, and
NEVI clusters.

``` r
export(tract_final, paste0("data/processed/nevi_tract_final.csv"))
saveRDS(tract_final, file = "data/processed/nevi_tract_final.rds")
```
