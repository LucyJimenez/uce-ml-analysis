# Load necessary libraries
library(tidyverse)  # Includes ggplot2, dplyr, tidyr, readr, etc.
library(dplyr)      # Provides data manipulation functions
library(stringr)    # Useful for string operations


### PANAGROLAIMIDAE ###

# Load and process Panagrolaimidae data
# Reads a tab-delimited file containing species and UCE (Ultra-Conserved Elements) data
panagrolaimidae_data <- read.table("/data/uce_species_list_panagrolaimidae.txt", 
                                   header = FALSE, col.names = c("Species", "UCE"))

# Convert the dataset into a presence-absence matrix
# Each row represents a species, and each UCE is a column (1 = present, 0 = absent)
panagrolaimidae_matrix <- panagrolaimidae_data %>%
  mutate(Presence = 1) %>% 
  pivot_wider(names_from = UCE, values_from = Presence, values_fill = 0)

# Save the presence-absence matrix for Panagrolaimidae
write.csv(panagrolaimidae_matrix, "/results/presence_absence_matrix_panagrolaimidae.csv", row.names = FALSE)



### RHABDITIDAE ###

# Load and process Rhabditidae data
# Reads a tab-delimited file containing species and UCE data
rhabditidae_data <- read.table("/data/uce_species_list_rhabditidae.txt", 
                               header = FALSE, col.names = c("Species", "UCE"))

# Convert the dataset into a presence-absence matrix
rhabditidae_matrix <- rhabditidae_data %>%
  mutate(Presence = 1) %>% 
  pivot_wider(names_from = UCE, values_from = Presence, values_fill = 0)

# Clean the Species column in Rhabditidae data
# - Convert species names to uppercase
# - Standardize naming format
rhabditidae_matrix <- rhabditidae_matrix %>%
  mutate(Species = str_to_upper(Species),
         Species = str_replace(Species, "^(\\w+)_([0-9]+)_([0-9]+).*", "\\1_\\2.\\3"))
# Standardize long species identifiers to GCA accession format (e.g., GCA_XXXXXXXXX.X)
rhabditidae_matrix <- rhabditidae_matrix %>%
  mutate(
    Species = str_replace(Species, "GCA_000143925_2_C_BRENNERI_6_0.1", "GCA_000143925.2"),
    Species = str_replace(Species, "GCA_000147155_1_C_JAPONICA_7_0.1", "GCA_000147155.1"),
    Species = str_replace(Species, "GCA_000186765_1_CAENORHABDITIS_SP11_JU1373_3_0.1", "GCA_000186765.1"),
    Species = str_replace(Species, "GCA_000939815_1_C_ELEGANS_BRISTOL_N2_V1_5.4", "GCA_000939815.1"),
    Species = str_replace(Species, "GCA_000975215_1_CAEL_CB4856_1.0", "GCA_000975215.1"),
    Species = str_replace(Species, "GCA_002742825_1_NIGONI_PC_2016_07.14", "GCA_002742825.1")
  )

# Save the presence-absence matrix for Rhabditidae
write.csv(rhabditidae_matrix, "/results/presence_absence_matrix_rhabditidae.csv", row.names = FALSE)
