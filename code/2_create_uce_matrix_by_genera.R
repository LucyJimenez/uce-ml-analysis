# Load necessary libraries
library(tidyverse)  # For data manipulation and visualization
library(dplyr)      # For data manipulation functions
library(stringr)    # For string manipulation

### PANAGROLAIMIDAE ###

# Load the presence-absence matrix for Panagrolaimidae
panagrolaimidae_matrix <- read.csv("/data/presence_absence_matrix_filtered_panagrolaimidae.csv", header = TRUE)

# Load genera codes for Panagrolaimidae species
panagrolaimidae_codes <- read_csv("/data/genera_codes_panagrolaimidae.csv", show_col_types = FALSE)

# Match genera information to the presence-absence matrix and rearrange columns
panagrolaimidae_result <- panagrolaimidae_matrix %>%
  left_join(panagrolaimidae_codes %>% select(taxa_code, Genera), 
            by = c("Species" = "taxa_code")) %>% # Match species with genera codes by taxa code
  relocate(Genera, .after = Species) %>%
  select(-Species)

# Save the final matrix with genera added for Panagrolaimidae
write.csv(panagrolaimidae_result, "/results/presence_absence_matrix_with_genera_panagrolaimidae.csv", row.names = FALSE)



### RHABDITIDAE ###

# Load the presence-absence matrix for Rhabditidae
rhabditidae_matrix <- read.csv("/data/presence_absence_matrix_filtered_rhabditidae.csv", header = TRUE)

# Load genera codes for Rhabditidae species
rhabditidae_codes <- read.csv("/data/genera_codes_rhabditidae.csv", header = TRUE)

# Match genera information to the Rhabditidae matrix and arrange columns
rhabditidae_result <- rhabditidae_matrix %>%
  left_join(rhabditidae_codes %>% select(Assembly.Accession, Organism.Name), 
            by = c("Species" = "Assembly.Accession")) %>%  # Match species with genera codes by accession number
  mutate(Genera = word(Organism.Name, 1)) %>%
  relocate(Genera, .after = Species) %>%
  select(-Organism.Name, -Species)

# Save the final Rhabditidae matrix with genera information
write.csv(rhabditidae_result, "/results/presence_absence_matrix_with_genera_rhabditidae.csv", row.names = FALSE)
