# Load required libraries
library(tidyverse)  # Includes ggplot2, dplyr, and other data manipulation tools
library(ggplot2)       # Plotting
library(VennDiagram)   # Venn diagrams


### PANAGROLAIMIDAE ###

# Load presence-absence matrix with genera info
df_panag <- read.csv("/data/presence_absence_matrix_with_genera_panagrolaimidae.csv", header = TRUE)

# Filter genera with more than one species
df_panag <- df_panag %>%
  group_by(Genera) %>%
  filter(n() > 1) %>%
  ungroup()

# Display the count of genera in the dataset
table(df_panag$Genera)

# Drop the UCE_Count column
if ("UCE_Count" %in% colnames(df_panag)) {
  df_panag <- df_panag %>% select(-UCE_Count)
}

# Summarize UCEs by genera
uce_sum_panag <- df_panag %>%
  group_by(Genera) %>%
  summarise(across(starts_with("UCE"), sum))

# Identify UCEs shared by all genera
uce_shared_panag <- uce_sum_panag %>%
  summarise(across(starts_with("uce"), ~ all(. > 0))) %>%
  pivot_longer(cols = everything(), names_to = "UCE", values_to = "Present") %>%
  filter(Present == TRUE)
print(uce_shared_panag$UCE)  

# Subset only shared UCEs
uce_shared_matrix_panag <- uce_sum_panag %>%
  select(Genera, all_of(uce_shared_panag$UCE))

# Prepare list of UCEs by genera
genera_uces_panag <- split(uce_sum_panag[, -1], uce_sum_panag$Genera)
genera_uces_panag <- lapply(genera_uces_panag, function(x) names(x)[colSums(x > 0) > 0])

# Draw Venn diagram for 5 genera
if (length(genera_uces_panag) == 5) {
  png("/results/venn_diagram_panagrolaimidae.png", width = 1200, height = 1000, res = 150)
  draw.quintuple.venn(
    area1 = length(genera_uces_panag[[1]]),
    area2 = length(genera_uces_panag[[2]]),
    area3 = length(genera_uces_panag[[3]]),
    area4 = length(genera_uces_panag[[4]]),
    area5 = length(genera_uces_panag[[5]]),
    n12 = length(intersect(genera_uces_panag[[1]], genera_uces_panag[[2]])),
    n13 = length(intersect(genera_uces_panag[[1]], genera_uces_panag[[3]])),
    n14 = length(intersect(genera_uces_panag[[1]], genera_uces_panag[[4]])),
    n15 = length(intersect(genera_uces_panag[[1]], genera_uces_panag[[5]])),
    n23 = length(intersect(genera_uces_panag[[2]], genera_uces_panag[[3]])),
    n24 = length(intersect(genera_uces_panag[[2]], genera_uces_panag[[4]])),
    n25 = length(intersect(genera_uces_panag[[2]], genera_uces_panag[[5]])),
    n34 = length(intersect(genera_uces_panag[[3]], genera_uces_panag[[4]])),
    n35 = length(intersect(genera_uces_panag[[3]], genera_uces_panag[[5]])),
    n45 = length(intersect(genera_uces_panag[[4]], genera_uces_panag[[5]])),
    n123 = length(Reduce(intersect, genera_uces_panag[1:3])),
    n124 = length(Reduce(intersect, genera_uces_panag[c(1, 2, 4)])),
    n125 = length(Reduce(intersect, genera_uces_panag[c(1, 2, 5)])),
    n134 = length(Reduce(intersect, genera_uces_panag[c(1, 3, 4)])),
    n135 = length(Reduce(intersect, genera_uces_panag[c(1, 3, 5)])),
    n145 = length(Reduce(intersect, genera_uces_panag[c(1, 4, 5)])),
    n234 = length(Reduce(intersect, genera_uces_panag[c(2, 3, 4)])),
    n235 = length(Reduce(intersect, genera_uces_panag[c(2, 3, 5)])),
    n245 = length(Reduce(intersect, genera_uces_panag[c(2, 4, 5)])),
    n345 = length(Reduce(intersect, genera_uces_panag[c(3, 4, 5)])),
    n1234 = length(Reduce(intersect, genera_uces_panag[1:4])),
    n1235 = length(Reduce(intersect, genera_uces_panag[c(1, 2, 3, 5)])),
    n1245 = length(Reduce(intersect, genera_uces_panag[c(1, 2, 4, 5)])),
    n1345 = length(Reduce(intersect, genera_uces_panag[c(1, 3, 4, 5)])),
    n2345 = length(Reduce(intersect, genera_uces_panag[2:5])),
    n12345 = length(Reduce(intersect, genera_uces_panag)),
    category = names(genera_uces_panag),
    fill = c("#440154FF", "#21908CFF", "#FDE725FF", "#3B528BFF", "#5DC863FF"),
    lty = "blank",
    cex = 2,
    cat.cex = 1
  )
  dev.off() 
} else {
  print("There are not exactly 5 Genera for the Venn diagram.")
}



### RHABDITIDAE ###

# Load presence-absence matrix with genera info
df_rhab <- read.csv("/data/presence_absence_matrix_with_genera_rhabditidae.csv", header = TRUE)

# Filter genera with more than one species
df_rhab <- df_rhab %>%
  group_by(Genera) %>%
  filter(n() > 1) %>%
  ungroup()

# Display the count of genera in the dataset
table(df_rhab$Genera)

# Drop the UCE_Count column
if ("UCE_Count" %in% colnames(df_rhab)) {
  df_rhab <- df_rhab %>% select(-UCE_Count)
}

# Summarize UCEs by genera
uce_sum_rhab <- df_rhab %>%
  group_by(Genera) %>%
  summarise(across(starts_with("UCE"), sum))

# Identify UCEs shared by all genera
uce_shared_rhab <- uce_sum_rhab %>%
  summarise(across(starts_with("uce"), ~ all(. > 0))) %>%
  pivot_longer(cols = everything(), names_to = "UCE", values_to = "Present") %>%
  filter(Present == TRUE)
print(uce_shared_rhab$UCE)

# Subset only shared UCEs
uce_shared_matrix_rhab <- uce_sum_rhab %>%
  select(Genera, all_of(uce_shared_rhab$UCE))

# Prepare list of UCEs by genera
genera_uces_rhab <- split(uce_sum_rhab[, -1], uce_sum_rhab$Genera)
genera_uces_rhab <- lapply(genera_uces_rhab, function(x) names(x)[colSums(x > 0) > 0])

# Draw Venn diagram for 4 genera
if (length(genera_uces_rhab) == 4) {
  png("/results/venn_diagram_rhabditidae.png", width = 1200, height = 1000, res = 150)
  draw.quad.venn(
    area1 = length(genera_uces_rhab[[1]]),
    area2 = length(genera_uces_rhab[[2]]),
    area3 = length(genera_uces_rhab[[3]]),
    area4 = length(genera_uces_rhab[[4]]),
    n12 = length(intersect(genera_uces_rhab[[1]], genera_uces_rhab[[2]])),
    n13 = length(intersect(genera_uces_rhab[[1]], genera_uces_rhab[[3]])),
    n14 = length(intersect(genera_uces_rhab[[1]], genera_uces_rhab[[4]])),
    n23 = length(intersect(genera_uces_rhab[[2]], genera_uces_rhab[[3]])),
    n24 = length(intersect(genera_uces_rhab[[2]], genera_uces_rhab[[4]])),
    n34 = length(intersect(genera_uces_rhab[[3]], genera_uces_rhab[[4]])),
    n123 = length(Reduce(intersect, genera_uces_rhab[1:3])),
    n124 = length(Reduce(intersect, genera_uces_rhab[c(1, 2, 4)])),
    n134 = length(Reduce(intersect, genera_uces_rhab[c(1, 3, 4)])),
    n234 = length(Reduce(intersect, genera_uces_rhab[2:4])),
    n1234 = length(Reduce(intersect, genera_uces_rhab)),
    category = names(genera_uces_rhab),
    fill = c("#440154FF", "#21908CFF", "#FDE725FF", "#3B528BFF"),
    lty = "blank",
    cex = 2,
    cat.cex = 2
  )
  dev.off() 
} else {
  print("There are not exactly 4 Genera for the Venn diagram.")
}
