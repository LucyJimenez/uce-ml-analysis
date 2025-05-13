# Install packages needed
install.packages("glmnet")
install.packages("MLmetrics")

# Load necessary libraries
library(caret)  # For model training and validation
library(dplyr)  # For data manipulation
library(xgboost)  # For gradient boosting model
library(pROC)  # For ROC curve analysis
library(ggplot2)  # For visualization
library(MLmetrics)

### PANAGROLAIMIDAE ###
### Data Loading and Preprocessing ###

# Load the dataset from a CSV file
df <- read.csv("/data/presence_absence_matrix_with_genera_panagrolaimidae.csv",
               header = TRUE, sep = ",")

# Remove the identifier column 'UCE_Count' if it exists
if ("UCE_Count" %in% colnames(df)) {
  df <- df %>% select(-UCE_Count)
}

# Convert 'Genera' to a factor and filter out genera with only one occurrence
df <- df %>%
  group_by(Genera) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  mutate(Genera = as.factor(Genera)) %>%
  na.omit()

# Display the count of genera in the dataset
table(df$Genera)

### Data Splitting ###

# Perform stratified split: 65% for training and 35% for testing
set.seed(42)

# Count samples per class and sort in ascending order
class_counts <- table(df$Genera)
sorted_classes <- names(sort(class_counts))

# Initialize empty data frames for training and testing
train_data <- data.frame()
test_data <- data.frame()

# Stratified data splitting to ensure at least one sample per class
for (cls in sorted_classes) {
  class_df <- df[df$Genera == cls, ]
  n_samples <- nrow(class_df)
  
  if (n_samples == 1) {
    train_data <- rbind(train_data, class_df)  # Assign single sample to training
  } else if (n_samples == 2) {
    train_data <- rbind(train_data, class_df[1, ])  # One in training
    test_data <- rbind(test_data, class_df[2, ]) # One in testing
  } else {
    trainIndex <- createDataPartition(class_df$Genera, p = 0.65, list = FALSE)
    temp_train <- class_df[trainIndex, ]
    temp_test <- class_df[-trainIndex, ]
    
    if (nrow(temp_test) == 0) {
      train_data <- rbind(train_data, class_df[-1, ])
      test_data <- rbind(test_data, class_df[1, ])
    } else {
      train_data <- rbind(train_data, temp_train)
      test_data <- rbind(test_data, temp_test)
    }
  }
}


### Validate Data Splitting ###

print("Clases en train_data:")
print(table(train_data$Genera))

print("Clases en test_data:")
print(table(test_data$Genera))


### Extract Features and Labels for Training ###

train_features <- train_data %>% select(-Genera)
train_labels <- train_data$Genera
test_features <- test_data %>% select(-Genera)
test_labels <- test_data$Genera


### Train and Evaluate XGBoost Model ###

# Compute class weights to handle class imbalance
class_counts <- table(train_labels)
class_weights <- length(train_labels) / (length(class_counts) * class_counts)

# Define evaluation metrics for cross-validation
ctrl <- trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = multiClassSummary)

# Train XGBoost model with class weights
set.seed(42)
xgb_model <- train(train_features, train_labels,
                   method = "xgbTree",
                   trControl = ctrl,
                   metric = "AUC",
                   weights = class_weights[train_labels])

# Make predictions
xgb_predictions <- predict(xgb_model, test_features)
xgb_probs <- predict(xgb_model, test_features, type = "prob")

# Compute AUC for the model
xgb_auc <- multiclass.roc(test_labels, xgb_probs)$auc
print(as.numeric(xgb_auc), digits = 22)

# Save results
results <- list()
results$XGBoost <- list(model = xgb_model, predictions = xgb_predictions, auc = xgb_auc, probs = xgb_probs) # save the probabilities

# Confusion matrix visualization
cm_xgb <- confusionMatrix(xgb_predictions, test_labels)
print(cm_xgb)
print(cm_xgb$byClass) # Print per-class metrics

cm_table_xgb <- as.data.frame(cm_xgb$table)
conf_matrix_xgb_plot <- ggplot(cm_table_xgb, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), vjust = 1) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(#title = "Confusion Matrix - XGBoost", 
       x = "Reference", y = "Prediction") +
  theme_minimal()

# Save confusion matrix plot as PNG
ggsave("/results/confusion_matrix_xgb.png", plot = conf_matrix_xgb_plot, width = 6, height = 5, dpi = 300)


### Feature Importance Analysis ###

# Extract feature importance
importance <- varImp(xgb_model)
importance_df <- as.data.frame(importance$importance)
importance_df$Feature <- rownames(importance_df)

# Select features with non-zero importance
selected_features <- importance_df[importance_df$Overall > 0, ]
print(selected_features)
print(paste("Total selected features:", nrow(selected_features)))

# Plot top 20 most important features
top_20_importance <- importance_df %>% arrange(desc(Overall)) %>% head(20)

top_features_plot <- ggplot(top_20_importance, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(#title = "Top Important Features (XGBoost)",
    x = "Feature",
    y = "Importance") +
  theme_minimal()

# Save the importance plot as PNG
ggsave("/results/top_20_feature_importance.png", plot = top_features_plot, width = 6, height = 5, dpi = 300)


### Retrain XGBoost Using Selected Features

# Select only the chosen features in the training and test sets
train_features_selected <- train_features[, selected_features$Feature]
test_features_selected <- test_features[, selected_features$Feature]

# Train a new XGBoost model using the selected features
set.seed(42)
xgb_model_selected <- train(train_features_selected, train_labels,
                            method = "xgbTree",
                            trControl = ctrl,
                            metric = "AUC",
                            weights = class_weights[train_labels])

# Make predictions with the new model
xgb_predictions_selected <- predict(xgb_model_selected, test_features_selected)
xgb_probs_selected <- predict(xgb_model_selected, test_features_selected, type = "prob")

# Compute AUC for the new model
xgb_auc_selected <- multiclass.roc(test_labels, xgb_probs_selected)$auc

# Store the results of the new model
results$XGBoost_Selected <- list(model = xgb_model_selected, 
                                 predictions = xgb_predictions_selected, 
                                 auc = xgb_auc_selected, 
                                 probs = xgb_probs_selected)

# Print the AUC of the new model
print(paste("AUC of the new XGBoost model with selected features:", xgb_auc_selected))

# Generate and print the confusion matrix for the new model
cm_xgb_selected <- confusionMatrix(xgb_predictions_selected, test_labels)
print(cm_xgb_selected)
print(cm_xgb_selected$byClass) # Print per-class metrics
cm_table_xgb_selected <- as.data.frame(cm_xgb_selected$table)

# Visualize the confusion matrix
xgb_selected_cm_plot <- ggplot(cm_table_xgb_selected, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), vjust = 1) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(#title = "Confusion Matrix - XGBoost (Selected Features)", 
       x = "Reference", y = "Prediction") +
  theme_minimal()

# Save the plot as PNG
ggsave("/results/xgboost_confusion_matrix_selected_features.png", plot = xgb_selected_cm_plot, width = 6, height = 5, dpi = 300)
