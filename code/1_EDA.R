# Load required libraries
library(tidyverse)  # Includes ggplot2, dplyr, and other data manipulation tools
library(grid)       # For adjusting plot margins with unit()


### PANAGROLAIMIDAE ###

# Load dataset and species codes
df_pan <- read.csv("/data/presence_absence_matrix_panagrolaimidae.csv", header = TRUE)
species_codes_pan <- read.csv("/data/species_codes_panagrolaimidae.csv", header = TRUE)

# Explore the data structure and check for missing values
str(df_pan)
str(species_codes_pan)
sum(is.na(df_pan))
summary(df_pan$Species)

# Count UCEs
df_pan$UCE_Count <- rowSums(df_pan[ , -which(names(df_pan) == "Species")])
summary(df_pan$UCE_Count)

# Replace codes with species names
df_pan_named <- df_pan %>%
  mutate(Species_original = Species) %>%
  left_join(species_codes_pan, by = "Species") %>%
  mutate(Species = Name) %>%
  select(-Name)

# Check for unmapped species
unmapped_pan <- df_pan_named %>%
  filter(is.na(Species)) %>%
  pull(Species_original) %>%
  unique()
print(unmapped_pan)

# Plot UCE counts per species
plot_pan <- ggplot(df_pan_named, aes(x = reorder(Species, UCE_Count), y = UCE_Count)) +
  geom_point(color = "#440154FF", alpha = 0.7, size = 1.5) +
  coord_flip() +
  labs(x = "Species", y = "Number of UCEs") +
  theme_minimal(base_size = 10) +
  theme(axis.text.y = element_text(size = 10, face = "bold.italic"))

ggsave("/results/panagrolaimidae_uce_counts_per_species.png", plot_pan, width = 8, height = 10)


### Identify and Remove Outliers Based on UCE Count ###

# Set lower threshold
lower_threshold_pan <- quantile(df_pan$UCE_Count, 0.01, na.rm = TRUE)

# Filter species with UCE count >= threshold
df_pan_filtered <- df_pan[df_pan$UCE_Count >= lower_threshold_pan, ]
summary(df_pan_filtered$UCE_Count)

# Identify and print outlier species
outliers_pan <- subset(df_pan, UCE_Count < lower_threshold_pan)
cat("Number of species for panagrolaimidae:", nrow(df_pan) - nrow(df_pan_filtered), "\n", "Name:", outliers_pan$Species)

# Save the filtered dataset
write.csv(df_pan_filtered, "/results/presence_absence_matrix_filtered_panagrolaimidae.csv", row.names = FALSE)


### Distribution of UCE Frequencies ###
# Count how many species each UCE appears in
uce_counts_pan <- colSums(df_pan_filtered[, !names(df_pan_filtered) %in% c("Species", "UCE_Count")])

# Create a dataframe of UCE frequencies
uce_freq_df_pan <- data.frame(UCE = names(uce_counts_pan), Frequency = uce_counts_pan) %>% arrange(desc(Frequency))

# Plot histogram of UCE frequency
hist_pan <- ggplot(uce_freq_df_pan, aes(x = Frequency)) +
  geom_histogram(binwidth = 5, fill = "#440154FF", color = "#e0e0e0", alpha = 0.7) +
  labs(x = "Frequency", y = "Number of UCEs") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 16),
    plot.margin = unit(c(0.2, 1.0, 0.2, 0.2), "cm")
  )

ggsave("/results/panagrolaimidae_uce_frequency_histogram.png", hist_pan, width = 8, height = 6)



### RHABDITIDAE ###

# Load dataset and species codes
df_rhab <- read.csv("/data/presence_absence_matrix_rhabditidae.csv", header = TRUE)
species_codes_rhab <- read.csv("/data/species_codes_rhabditidae.csv", header = TRUE)

# Explore the data structure and check for missing values
str(df_rhab)
str(species_codes_rhab)
sum(is.na(df_rhab))
summary(df_rhab$Species)

# Count UCEs
df_rhab$UCE_Count <- rowSums(df_rhab[ , -which(names(df_rhab) == "Species")])
summary(df_rhab$UCE_Count)

# Replace codes with species names
df_rhab_named <- df_rhab %>%
  mutate(Species_original = Species) %>%
  left_join(species_codes_rhab, by = "Species") %>%
  mutate(Species = Name) %>%
  select(-Name)

# Check for unmapped species
unmapped_rhab <- df_rhab_named %>%
  filter(is.na(Species)) %>%
  pull(Species_original) %>%
  unique()
print(unmapped_rhab)

# Plot UCE counts per 
plot_rhab <- ggplot(df_rhab_named, aes(x = reorder(Species, UCE_Count), y = UCE_Count)) +
  geom_point(color = "#440154FF", alpha = 0.7, size = 1.5) +
  coord_flip() +
  labs(x = "Species", y = "Number of UCEs") +
  theme_minimal(base_size = 10) +
  theme(axis.text.y = element_text(size = 10, face = "bold.italic"))

ggsave("/results/rhabditidae_uce_counts_per_species.png", plot_rhab, width = 8, height = 10)


### Identify and Remove Outliers Based on UCE Count ###

# Set lower threshold
lower_threshold_rhab <- quantile(df_rhab$UCE_Count, 0.01, na.rm = TRUE)

# Filter species with UCE count >= threshold
df_rhab_filtered <- df_rhab[df_rhab$UCE_Count >= lower_threshold_rhab, ]
summary(df_rhab_filtered$UCE_Count)

# Identify and print outlier species
outliers_rhab <- subset(df_rhab, UCE_Count < lower_threshold_rhab)
cat("Number of species for rhabditidae:", nrow(df_rhab) - nrow(df_rhab_filtered), "\n", "Name:", outliers_rhab$Species)

# Save the filtered dataset
write.csv(df_rhab_filtered, "/results/presence_absence_matrix_filtered_rhabditidae.csv", row.names = FALSE)


### Distribution of UCE Frequencies ###
# Count how many species each UCE appears in
uce_counts_rhab <- colSums(df_rhab_filtered[, !names(df_rhab_filtered) %in% c("Species", "UCE_Count")])

# Create a dataframe of UCE frequencies
uce_freq_df_rhab <- data.frame(UCE = names(uce_counts_rhab), Frequency = uce_counts_rhab) %>% arrange(desc(Frequency))

# Plot histogram of UCE frequency
hist_rhab <- ggplot(uce_freq_df_rhab, aes(x = Frequency)) +
  geom_histogram(binwidth = 5, fill = "#440154FF", color = "#e0e0e0", alpha = 0.7) +
  labs(x = "Frequency", y = "Number of UCEs") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 16),
    plot.margin = unit(c(0.2, 1.0, 0.2, 0.2), "cm")
  )

ggsave("/results/rhabditidae_uce_frequency_histogram.png", hist_rhab, width = 8, height = 6)
