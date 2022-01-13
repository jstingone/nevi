
### Sensitivity analysis - clustering
```{r}
tract_toxpi_pre_raceeth_none <- import("data/processed/toxpi/archive 20211214 can delete/nvi_toxpi_raceeth_none_results.csv")
# CREATE: Clusters, Code from developers of toxpi
set.seed(123)
# Get slice weights
w_raceeth_none <- sapply(sapply(names(tract_toxpi_pre_raceeth_none)[-c(1:5)],function(x) strsplit(x, "!")),"[",2)
w_raceeth_none <- sapply(strsplit(w,split="/"),function(x) {y <- ifelse(length(x)==2,x[2],1);as.numeric(x[1])/as.numeric(y)})
# Generate cluster
hc_raceeth_none <- hclust(dist(tract_toxpi_pre_raceeth_none[,-c(1:5)]*rep(w,each=nrow(tract_toxpi_pre_raceeth_none))), method="complete")
nvi_cluster_result_raceeth_none <- cutree(hc_raceeth_none, k = 6) # Cut into 6 clusters using HClusts 
nvi_cluster_result_raceeth_none8 <- cutree(hc_raceeth_none, k = 8) # Cut into 8 clusters using HClusts 
# Check clusters
scaled_tract_toxpi_pre = scale(tract_toxpi_pre_raceeth_none[-c(1:5)])
mydist<-function(x)dist(x, method="euclidian")
mycluster <- function(x,k) list(cluster=cutree(hclust(mydist(x), method = "complete"),k=k))
# gap_stat_10 <- clusGap(scaled_tract_toxpi_pre, FUN = mycluster, K.max = 10, B = 50) # Uncomment when need, takes a lot of time to run
# fviz_gap_stat(gap_stat_10)
# Create data frame for cluster data
tract_toxpi_cluster_raceeth_none <- tract_toxpi_pre_raceeth_none %>% 
  dplyr::mutate(SID = Source %>% as.character() %>% trimws(),
                nvi_cluster_raceeth_none_orig = nvi_cluster_result_raceeth_none %>% as.factor(),
                nvi_cluster_raceeth_none = case_when(
                  nvi_cluster_raceeth_none_orig == "1" ~ "6", 
                  nvi_cluster_raceeth_none_orig == "2" ~ "5", 
                  nvi_cluster_raceeth_none_orig == "3" ~ "3", 
                  nvi_cluster_raceeth_none_orig == "4" ~ "4", 
                  nvi_cluster_raceeth_none_orig == "5" ~ "1", 
                  nvi_cluster_raceeth_none_orig == "6" ~ "2" 
                ) %>% as.factor(),
                # 8 clusters
                nvi_cluster_raceeth_none_orig8 = nvi_cluster_result_raceeth_none8 %>% as.factor(),
                nvi_cluster_raceeth_none_8 = case_when(
                  nvi_cluster_raceeth_none_orig8 == "1" ~ "6.2", 
                  nvi_cluster_raceeth_none_orig8 == "2" ~ "5", 
                  nvi_cluster_raceeth_none_orig8 == "3" ~ "6.1", 
                  nvi_cluster_raceeth_none_orig8 == "4" ~ "3.2", 
                  nvi_cluster_raceeth_none_orig8 == "5" ~ "4", 
                  nvi_cluster_raceeth_none_orig8 == "6" ~ "3.1",
                  nvi_cluster_raceeth_none_orig8 == "7" ~ "1",
                  nvi_cluster_raceeth_none_orig8 == "8" ~ "2"
                ) %>% as.factor()) %>% 
  dplyr::rename(Tract_FIPS = SID) %>% 
  dplyr::select(Tract_FIPS, nvi_cluster_raceeth_none, nvi_cluster_raceeth_none_8) 
# Merge cluster data with final NVI data
tract_toxpi_raceeth_none_df_subset <- tract_toxpi_raceeth_none_df %>% 
  dplyr::select(Tract_FIPS, nvi, score_demo, score_economic, score_residential, score_healthstatus) %>% 
  dplyr::rename(nvi_raceeth_none = nvi,
                score_demo_raceeth_none = score_demo, 
                score_economic_raceeth_none = score_economic, 
                score_residential_raceeth_none = score_residential, 
                score_healthstatus_raceeth_none = score_healthstatus)
tract_final_raceeth_none <- tract_final %>% 
  dplyr::mutate(Tract_FIPS = as.character(Tract_FIPS) %>% trimws()) %>% 
  dplyr::left_join(tract_toxpi_cluster_raceeth_none, by = "Tract_FIPS") %>% 
  dplyr::mutate(nvi_cluster_match = case_when(nvi_cluster == nvi_cluster_raceeth_none ~ "Cluster Match",
                                              nvi_cluster != nvi_cluster_raceeth_none ~ "No Cluster Match")) %>% 
  dplyr::left_join(tract_toxpi_raceeth_none_df_subset, by = "Tract_FIPS") 
# Spatial 
tract_final_raceeth_none_spatial <- tract_nyc_spatial %>% 
  dplyr::inner_join(tract_final_raceeth_none, by = "Tract_FIPS") # Checked: did not exclude any tracts, 8/11
# CHECK: double check scores-- confirmed only demographic only diff (others have rounding differences)
tract_final_raceeth_none %>% 
  dplyr::left_join(tract_toxpi_raceeth_none_df, by = "Tract_FIPS") %>% 
  dplyr::mutate(diff_demo = score_demo.x - score_demo.y,
                diff_economic = score_economic.x - score_economic.y,
                diff_residential = score_residential.x - score_residential.y,
                diff_healthstatus = score_healthstatus.x - score_healthstatus.y) %>% 
  dplyr::select(diff_demo, diff_economic, diff_residential, diff_healthstatus,
                score_demo.x, score_demo.y, score_economic.x, score_economic.y, score_healthstatus.x, score_healthstatus.y, score_healthstatus.x, score_healthstatus.y) %>% 
  skimr::skim()
# CHECK: percent comparison of clusters
# Match by orig NVI cluster
tract_final_raceeth_none %>% 
  janitor::tabyl(nvi_cluster, nvi_cluster_match) %>% 
  janitor::adorn_percentages() %>% 
  janitor::adorn_pct_formatting(digits = 2) %>% 
  janitor::adorn_ns() %>% 
  dplyr::rename(original_nvi_cluster = nvi_cluster)
# NVI cluster with no race/eth by orig NVI cluster
tract_final_raceeth_none %>% 
  janitor::tabyl(nvi_cluster, nvi_cluster_raceeth_none) %>% 
  janitor::adorn_percentages() %>% 
  janitor::adorn_pct_formatting(digits = 2) %>% 
  janitor::adorn_ns() %>% 
  dplyr::rename(original_nvi_cluster = nvi_cluster)
# CHECK: race/ethnicity by clusters, correlations
raceeth_none_perc_plot <- tract_final_raceeth_none %>% 
  tidyr::gather(cluster_no, )


tract_final_raceeth_none %>% 
  mutate(tot = hisp_prop + black_nonhisp_prop + asian_nonhisp_prop + aian_nhpi_mult_other_nonhisp_prop) %>% 
  tabyl(tot)
gen_df_raceeth_prop <- function(dfin, cluster, cluster_type){
  dfin %>% 
    dplyr::select(!!sym(cluster), hisp_prop, black_nonhisp_prop, asian_nonhisp_prop, aian_nhpi_mult_other_nonhisp_prop) %>% 
    tidyr::gather(key = raceeth_cat, value = raceeth_prop, hisp_prop, black_nonhisp_prop, asian_nonhisp_prop, aian_nhpi_mult_other_nonhisp_prop, -!!sym(cluster)) %>% 
    dplyr::group_by(!!sym(cluster), raceeth_cat) %>% 
    dplyr::summarize(raceeth_prop_mean = mean(raceeth_prop)) %>% 
    dplyr::mutate(raceeth_cat_new = case_when(raceeth_cat == 'hisp_prop' ~ 'HP',
                                              raceeth_cat == 'black_nonhisp_prop' ~ 'BA',
                                              raceeth_cat == 'asian_nonhisp_prop' ~ 'AS',
                                              raceeth_cat == 'aian_nhpi_mult_other_nonhisp_prop' ~ 'OT') %>% factor(levels = c("HP","BA","AS","OT")),
                  nvi_cluster_type = cluster_type) %>% 
    dplyr::rename(nvi_cluster = !!sym(cluster))
}
raceeth_prop_nvi_cluster_orig <- gen_df_raceeth_prop(tract_final_raceeth_none, 'nvi_cluster', 'Clusters - Original') %>% dplyr::mutate(nvi_cluster = factor(nvi_cluster))
raceeth_prop_nvi_cluster_none6 <- gen_df_raceeth_prop(tract_final_raceeth_none, 'nvi_cluster_raceeth_none', 'Clusters - No Race/Ethnicity (6)')
raceeth_prop_nvi_cluster_none8 <- gen_df_raceeth_prop(tract_final_raceeth_none, 'nvi_cluster_raceeth_none_8', 'Clusters - No Race/Ethnicity (8)')

raceeth_prop_nvi_cluster_comb <- rbind(raceeth_prop_nvi_cluster_orig, raceeth_prop_nvi_cluster_none6, raceeth_prop_nvi_cluster_none8) %>% 
  dplyr::mutate(nvi_cluster_type = fct_relevel(nvi_cluster_type, levels = c('Clusters - Original', 'Clusters - No Race/Ethnicity (6)', 'Clusters - No Race/Ethnicity (8)')),
                nvi_cluster = fct_relevel(nvi_cluster, levels = c('1','2','3','3.1','3.2','4','5','6','6.1','6.2')))

ggplot(data = raceeth_prop_nvi_cluster_comb, aes(x = raceeth_cat, y = raceeth_prop_mean, fill = raceeth_cat)) +
  geom_bar(stat = "identity") +
  facet_grid(nvi_cluster ~ nvi_cluster_type) +
  labs(title = "Race/Ethnicity Distribution by Cluster\nOriginal vs. No Race/Ethnicity (6 Clusters) vs. No Race/Ethnicity (8 Clusters)",
       x = "Race/Ethnicity\n(HP = Hispanic, BA = Non-Hispanic Black,AS = Non-Hispanic Asian,\nOT = Non-Hispanic American Indian/Alaskan Native/Native Hawaiian/Pacific Islander/Multiracial/Other)",
       y = "Race/Ethnicity Proportion",
       fill = 'Race/Ethnicity') +
  scale_y_continuous(expand = c(0,0)) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face = 'bold'),
        legend.position = 'bottom') 
ggsave('clusterfig_raceeth_none_props.png', width = 7, height = 10) # pixels: 1200 x 900 width = 13, height = 12


# Create pies again
colors_colorblindsafe <- c('#ffff6d','#ffb6db','#24ff24','#6db6ff','#920000','#490092') 
nvi_cat_levels <- c('Demographics', 'Economic', 'Residential', 'Health Status')
# Data Prep
clusterfig_part1_df <- tract_final_raceeth_none %>% 
  dplyr::group_by(nvi_cluster_raceeth_none) %>% 
  dplyr::summarize(n_obs = n(),
                   mean_nvi = mean(nvi_raceeth_none),
                   q1_nvi = quantile(nvi_raceeth_none, 0.25),
                   q3_nvi = quantile(nvi_raceeth_none, 0.75),
                   iqr_nvi = paste0(round(q1_nvi, 2), "-", round(q3_nvi,2)),
                   mean_demo_score = mean(score_demo_raceeth_none),
                   mean_economic_score = mean(score_economic_raceeth_none),
                   mean_residential_score = mean(score_residential_raceeth_none),
                   mean_healthstatus_score = mean(score_healthstatus_raceeth_none)) %>% 
  tidyr::gather(nvi_cat_prelim, mean, mean_demo_score:mean_healthstatus_score) %>% 
  dplyr::mutate(nvi_cat = case_when(nvi_cat_prelim == 'mean_demo_score'         ~ nvi_cat_levels[1],
                                    nvi_cat_prelim == 'mean_economic_score'     ~ nvi_cat_levels[2],
                                    nvi_cat_prelim == 'mean_residential_score'  ~ nvi_cat_levels[3],
                                    nvi_cat_prelim == 'mean_healthstatus_score' ~ nvi_cat_levels[4]) %>% factor(nvi_cat_levels),
                nvi_cluster_label = paste0("Cluster ", nvi_cluster_raceeth_none, " (n = ", n_obs, ",\nMean NVI = ", round(mean_nvi,2), ")"))
# Plotting
generate_clusterfig_part1_prelim <- function(df, fill_values, fill_labels){
  ggplot(df, aes(x = nvi_cat, y = mean, fill = nvi_cluster_label, pattern = nvi_cat)) +
    ggpattern::geom_bar_pattern(stat = "identity", color = "black") +
    geom_text(aes(label = round(mean, 2), y = mean + 0.25), size = 4) + # y = mean + 0.5
    coord_polar(start = (3*pi)/2, direction = -1, clip = "off") +
    ylim(-0.2, 1.1) + #1.1
    scale_fill_manual(values = fill_values, labels = fill_labels) +
    ggpattern::scale_pattern_manual(values = c("circle","stripe","crosshatch","none")) +
    facet_wrap(. ~ nvi_cluster_label, nrow = 2) +
    labs(fill = "Neighborhood\nVulnerability Index\nCluster", pattern = "Domain Score") +
    theme_minimal() +
    guides(fill = guide_legend(override.aes = list(pattern = "none"), nrow = 2, title.position = "top", title.hjust = 0.5, order = 1), # fill = FALSE 
           pattern = guide_legend(override.aes = list(fill = "white"), nrow = 6, title.position = "top", title.hjust = 0.5, order = 2)) +
    theme(legend.position = "right",
          legend.title = element_text(face = "bold"),
          legend.box = 'vertical',
          axis.title = element_blank(),
          axis.text = element_blank(),
          strip.text.x = element_text(size = 12, face = "bold"),
          panel.grid = element_blank(),
          plot.margin = unit(c(t = 0, r = 0, b = 0, l = 0), "cm"),
          panel.spacing = unit(0, "lines")) # strip.background.y = element_rect("transparent")
}
clusterfig_part1_prelim <- generate_clusterfig_part1_prelim(df = clusterfig_part1_df, fill_values = colors_colorblindsafe, fill_labels = c("1","2","3","4","5","6"))
clusterfig_part1_plot_build <- ggplot_build(clusterfig_part1_prelim)
for(i in 1:6){
  clusterfig_part1_plot_build[["layout"]][["panel_params"]][[i]][["r.range"]][2] <- 0.45
}
clusterfig_part1 <- ggplot_gtable(clusterfig_part1_plot_build)
## CREATE: PART 2 - CLUSTER MAP
gen_clusterfig_part2 <- function(dfin, dfexcl, fill_var, fill_color, fill_label, fill_increment){
  plot_choro <- ggplot() + 
    geom_sf(data = dfin, aes(fill = !!sym(fill_var)), color = NA) + 
    geom_sf(data = dfexcl, color = "gray90", fill = "gray90") + 
    theme_minimal() + 
    scale_fill_manual(values = fill_color, guide = guide_legend(direction = "horizontal", title.position = "top")) +
    labs(fill = fill_label) + 
    # guides(fill = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5)) +
    theme(legend.position = "none", # legend.title = element_text(face = "bold", size = 12), legend.text = element_text(size = 9), legend.spacing.x = unit(0.5, 'cm'), 
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          plot.margin = unit(c(t = 0, r = 0, b = 0, l = 0), "cm")) 
  return(plot_choro)
}
clusterfig_part2 <- gen_clusterfig_part2(dfin = tract_final_raceeth_none_spatial, dfexcl = tract_exclude_spatial, fill_var = "nvi_cluster_raceeth_none", fill_color = colors_colorblindsafe, fill_label = "Neighborhood Vulnerability Index Cluster") 
## COMBINED PLOT
clusterfig_raceeth_none <- ggarrange(clusterfig_part1, ggarrange(clusterfig_part2, ggplot() + theme_void(), ncol = 2), nrow = 2) + theme(plot.margin = margin(t = 0, r = 0, b = 0, l = 0, "cm"))
clusterfig_raceeth_none
# EXPORT
ggsave('clusterfig_raceeth_none.png', width = 7, height = 9) # pixels: 1200 x 900 width = 13, height = 12


######################### 8 clusters
# part 1
clusterfig_part1_8_df <- tract_final_raceeth_none %>% 
  dplyr::group_by(nvi_cluster_raceeth_none_8) %>% 
  dplyr::summarize(n_obs = n(),
                   mean_nvi = mean(nvi_raceeth_none),
                   q1_nvi = quantile(nvi_raceeth_none, 0.25),
                   q3_nvi = quantile(nvi_raceeth_none, 0.75),
                   iqr_nvi = paste0(round(q1_nvi, 2), "-", round(q3_nvi,2)),
                   mean_demo_score = mean(score_demo_raceeth_none),
                   mean_economic_score = mean(score_economic_raceeth_none),
                   mean_residential_score = mean(score_residential_raceeth_none),
                   mean_healthstatus_score = mean(score_healthstatus_raceeth_none)) %>% 
  tidyr::gather(nvi_cat_prelim, mean, mean_demo_score:mean_healthstatus_score) %>% 
  dplyr::mutate(nvi_cat = case_when(nvi_cat_prelim == 'mean_demo_score'         ~ nvi_cat_levels[1],
                                    nvi_cat_prelim == 'mean_economic_score'     ~ nvi_cat_levels[2],
                                    nvi_cat_prelim == 'mean_residential_score'  ~ nvi_cat_levels[3],
                                    nvi_cat_prelim == 'mean_healthstatus_score' ~ nvi_cat_levels[4]) %>% factor(nvi_cat_levels),
                nvi_cluster_label = paste0("Cluster ", nvi_cluster_raceeth_none_8, " (n = ", n_obs, ",\nMean NVI = ", round(mean_nvi,2), ")"))
clusterfig_part1_8_prelim <- generate_clusterfig_part1_prelim(df = clusterfig_part1_8_df, fill_values = c("#ffff6d","#ffb6db","#24ff24","forestgreen","#6db6ff","#920000","#490092","mediumpurple1"), fill_labels = c("1","2","3.1","3.2","4","5","6.1","6.2"))
clusterfig_part1_8_plot_build <- ggplot_build(clusterfig_part1_8_prelim)
for(i in 1:8){
  clusterfig_part1_8_plot_build[["layout"]][["panel_params"]][[i]][["r.range"]][2] <- 0.45
}
clusterfig_part1_8 <- ggplot_gtable(clusterfig_part1_8_plot_build)
# part 2
clusterfig_part2_8 <- gen_clusterfig_part2(dfin = tract_final_raceeth_none_spatial, dfexcl = tract_exclude_spatial, fill_var = "nvi_cluster_raceeth_none_8", fill_color = c("#ffff6d","#ffb6db","#24ff24","forestgreen","#6db6ff","#920000","#490092","mediumpurple1"), fill_label = "Neighborhood Vulnerability Index Cluster") 
# combine
clusterfig_raceeth_none_8 <- ggarrange(clusterfig_part1_8, ggarrange(clusterfig_part2_8, ggplot() + theme_void(), ncol = 2), nrow = 2) + theme(plot.margin = margin(t = 0, r = 0, b = 0, l = 0, "cm"))
clusterfig_raceeth_none_8
ggsave('clusterfig_raceeth_none_8.png', width = 8, height = 9) 

# View average NVI domains scores by cluster for text
fig4b_part1_df %>% distinct(nvi_cluster, mean_nvi, iqr_nvi)
tract_final %>% count(nvi_cluster, nvi_cluster_orig)

```

