# Install packages needed
install.packages("glmnet")
install.packages("MLmetrics")

# Load only necessary libraries
library(caret)         # For model training and preprocessing
library(dplyr)         # For data manipulation
library(randomForest)  # Random Forest model
library(glmnet)        # Logistic Regression with regularization
library(xgboost)       # XGBoost model
library(pROC)          # For AUC and ROC calculation
library(e1071)         # Required for some caret models like KNN
library(ggplot2)       # For plotting
library(MLmetrics)



### RHABDITIDAE ###
### Data Loading and Preprocessing ###

# Load the dataset from a CSV file
df <- read.csv("/data/presence_absence_matrix_with_genera_rhabditidae.csv",
               header = TRUE, sep = ",")
#
df_grouped <- df %>%
  select(Genera, UCE_Count) %>%  # Select only the columns of interest
  group_by(Genera) %>%           # Group by Genera
  summarise(UCE_Count = sum(UCE_Count, na.rm = TRUE))  # Summarize the UCE_Count

# Print the result
print(df_grouped)

# Display the count of genera in the dataset
table(df$Genera)

# Remove the identifier column 'UCE_Count' if it exists
if ("UCE_Count" %in% colnames(df)) {
  df <- df %>% select(-UCE_Count)
}

# Convert 'Genera' to a factor and filter out genera with only one occurrence
df <- df %>%
  mutate(Genera = as.factor(Genera)) %>%
  group_by(Genera) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  na.omit()


### Data Splitting ###

# Perform stratified split: 65% for training and 35% for testing
set.seed(42)
trainIndex <- createDataPartition(df$Genera, p = 0.65, list = FALSE)
train_data <- df[trainIndex, ]
test_data <- df[-trainIndex, ]

# Separate features and labels for both training and testing data
train_features <- train_data %>% select(-Genera)
train_labels <- train_data$Genera
test_features <- test_data %>% select(-Genera)
test_labels <- test_data$Genera


### Model Training and Evaluation ###

# Calculate class weights to address class imbalance
class_counts <- table(train_labels)
class_weights <- length(train_labels) / (length(class_counts) * class_counts)

# Define evaluation metrics using cross-validation
ctrl <- trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = multiClassSummary)

# Initialize a list to store model results
results <- list()

### Random Forest with parameter tuning ###
set.seed(42)
rf_grid <- expand.grid(mtry = c(2, 3, 4))
rf_model <- train(train_features, train_labels,
                  method = "rf",
                  trControl = ctrl,
                  metric = "AUC",
                  tuneGrid = rf_grid, 
                  classwt = class_weights)
rf_predictions <- predict(rf_model, test_features)
rf_probs <- predict(rf_model, test_features, type = "prob")
rf_auc <- multiclass.roc(test_labels, rf_probs)$auc
results$RandomForest <- list(model = rf_model, predictions = rf_predictions, auc = rf_auc, probs = rf_probs) # save the probabilities


### Logistic Regression with PCA ###
set.seed(42)

# Remove columns with zero variance (constant features)
zero_var <- nearZeroVar(train_features)
if (length(zero_var) > 0) {
  train_features_filtered <- train_features[, -zero_var]
  test_features_filtered <- test_features[, -zero_var]
} else {
  train_features_filtered <- train_features
  test_features_filtered <- test_features
}

# Apply preprocessing to scale the features (centering and scaling)
preproc <- preProcess(train_features_filtered, method = c("center", "scale"))
train_scaled <- predict(preproc, train_features_filtered)
test_scaled <- predict(preproc, test_features_filtered)

# Perform PCA for dimensionality reduction (keep 70% of variance)
pca_model <- preProcess(train_scaled, method = "pca", thresh = 0.70)
train_pca <- predict(pca_model, train_scaled)
test_pca <- predict(pca_model, test_scaled)

# Tune the logistic regression model using cross-validation
lr_grid <- expand.grid(alpha = c(0, 0.5, 1), lambda = c(0.1, 1, 10)) # Regularization parameters
logistic_model <- train(train_pca, train_labels,
                        method = "glmnet",
                        trControl = ctrl,
                        metric = "AUC",
                        tuneGrid = lr_grid)

logistic_predictions <- predict(logistic_model, test_pca)
logistic_probs <- predict(logistic_model, test_pca, type = "prob")
logistic_auc <- multiclass.roc(test_labels, logistic_probs)$auc
results$LogisticRegressionPCA <- list(model = logistic_model, predictions = logistic_predictions, auc = logistic_auc, probs = logistic_probs) # save the probabilities


### K-Nearest Neighbors (KNN) ###
set.seed(42)
knn_model <- train(train_features, train_labels, method = "knn", trControl = ctrl, metric = "AUC")
knn_predictions <- predict(knn_model, test_features)
knn_probs <- predict(knn_model, test_features, type = "prob")
knn_auc <- multiclass.roc(test_labels, knn_probs)$auc
results$KNN <- list(model = knn_model, predictions = knn_predictions, auc = knn_auc, probs = knn_probs) # save the probabilities


### XGBoost with class weights ###
set.seed(42)
xgb_model <- train(train_features, train_labels,
                   method = "xgbTree",
                   trControl = ctrl,
                   metric = "AUC",
                   weights = class_weights[train_labels])
xgb_predictions <- predict(xgb_model, test_features, iteration_range = c(0, 100))
xgb_probs <- predict(xgb_model, test_features, type = "prob", iteration_range = c(0, 100))
xgb_auc <- multiclass.roc(test_labels, xgb_probs)$auc
results$XGBoost <- list(model = xgb_model, predictions = xgb_predictions, auc = xgb_auc, probs = xgb_probs) # save the probabilities


### Model Results Summary and Comparison ###

# Print the AUC results for each model
cat("AUC Results:\n")
for (model_name in names(results)) {
  cat(paste(model_name, ":", results[[model_name]]$auc, "\n"))
}

# Create a table to summarize AUC results for all models
auc_table <- data.frame(Model = names(results), AUC = sapply(results, function(x) x$auc))
print(auc_table)

# Generate confusion matrices for each model
for (model_name in names(results)) {
  cat(paste("\nConfusion Matrix for", model_name, ":\n"))
  print(confusionMatrix(results[[model_name]]$predictions, test_labels))
}

# Generate confusion matrices and additional metrics for each model
for (model_name in names(results)) {
  cat(paste("\nConfusion Matrix and Metrics for", model_name, ":\n"))
  cm <- confusionMatrix(results[[model_name]]$predictions, test_labels)
  print(cm)
  print(cm$byClass) # Print per-class metrics
}

# Plot AUC values for each model
auc_table <- data.frame(Model = names(results), AUC = sapply(results, function(x) x$auc))
auc_plot <- ggplot(auc_table, aes(x = Model, y = AUC, fill = Model)) +
  geom_bar(stat = "identity", alpha = 0.7) +
  labs( #title = "AUC Comparison of Models", 
    x = "Model", y = "AUC") +
  scale_fill_manual(values = c("#440154FF", "#21908CFF", "#FDE725FF", "#3B528BFF")) +
  theme_minimal()

# Save the AUC plot as PNG
ggsave("/results/auc_comparison.png", plot = auc_plot, width = 8, height = 6, dpi = 300)

# Plot confusion matrices for each model
plot_confusion_matrix <- function(cm, model_name) {
  cm_table <- as.data.frame(cm$table)
  cm_plot <- ggplot(cm_table, aes(x = Reference, y = Prediction, fill = Freq)) +
    geom_tile() +
    geom_text(aes(label = Freq), vjust = 1) +
    scale_fill_gradient(low = "white", high = "steelblue") +
    labs(#title = paste("Confusion Matrix -", model_name), 
         x = "Reference", y = "Prediction") +
    theme_minimal()
  # Save confusion matrix plot as PNG
  ggsave(paste0("/results/confusion_matrix_", model_name, ".png"), plot = cm_plot, width = 8, height = 6, dpi = 300)
}

for (model_name in names(results)) {
  cm <- confusionMatrix(results[[model_name]]$predictions, test_labels)
  print(plot_confusion_matrix(cm, model_name))
}


### Feature Importance with XGBoost ###

# Get feature importance from the XGBoost model
importance <- varImp(xgb_model)
importance_df <- as.data.frame(importance$importance)
importance_df$Feature <- rownames(importance_df)

# Select features with non-zero importance
selected_features <- importance_df[importance_df$Overall > 0, ]
print(selected_features)

# Save feature importance results to a CSV file
write.csv(selected_features, "/results/importance_df_rhabditidae.csv", row.names = FALSE)

# Plot the top 20 important features
top_20_importance <- importance_df %>%
  arrange(desc(Overall)) %>%
  head(20)
importance_plot <- ggplot(top_20_importance, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(#title = "Top Important Features (XGBoost)",
       x = "Feature",
       y = "Importance") +
  theme_minimal()

# Save the importance plot as PNG
ggsave("/results/top_20_features_importance.png", plot = importance_plot, width = 8, height = 6, dpi = 300)

# Cross-validation with varying numbers of features
auc_values <- c()
num_features <- c(1:20)

for (n in num_features) {
  top_n_features <- selected_features$Feature[1:n]
  train_subset <- train_features[, top_n_features]
  test_subset <- test_features[, top_n_features]
  
  xgb_model_subset <- train(train_subset, train_labels,
                            method = "xgbTree",
                            trControl = ctrl,
                            metric = "AUC",
                            weights = class_weights[train_labels])
  
  xgb_probs_subset <- predict(xgb_model_subset, test_subset, type = "prob", iteration_range = c(0, 100))
  auc_values <- c(auc_values, multiclass.roc(test_labels, xgb_probs_subset)$auc)
}

# Plot AUC vs. Number of Features
auc_vs_features_plot <- ggplot(data.frame(Num_Features = num_features, AUC = auc_values), aes(x = Num_Features, y = AUC)) +
  geom_line() +
  geom_point() +
  labs(x = "Number of Features", y = "AUC") +
  theme_minimal()

# Save the plot as PNG
ggsave("/results/auc_vs_num_features.png", plot = auc_vs_features_plot, width = 8, height = 6, dpi = 300)

# Save model results to a file
saveRDS(results, file = "/results/benchmark_model_results.rds")
