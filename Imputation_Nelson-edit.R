# Set up library paths first
new_lib_path <- "/N/slate/nelbadia/Ger-WI-Collabs/R_libs"
.libPaths(c(new_lib_path, .libPaths()))

# Load libraries (simplified - don't need lib parameter with .libPaths set)
#library(here)
library(dplyr)
library(naniar)
library(ggplot2)
library(mice)
library(caret)

set.seed(2827)

# Use absolute paths instead of here()
base_path <- "/N/slate/nelbadia/Ger-WI-Collabs/Germany/MAVC_R"

# Load data
MIMIC3_Cohort_raw <- read.csv(file.path(base_path, "results", "MIMIC3_Cohort_raw.csv"))
MIMIC3_Cohort_raw$X <- NA

# Initial missing data summary
print("Initial missing data summary:")
miss_var_summary(MIMIC3_Cohort_raw)

# Filter columns with at least 20% complete data
MIMIC3_Cohort_filt <- MIMIC3_Cohort_raw[, colSums(!is.na(MIMIC3_Cohort_raw)) >= dim(MIMIC3_Cohort_raw)[1]*.2]

# Missing data summary after filtering
print("Missing data summary after filtering:")
miss_var_summary(MIMIC3_Cohort_filt)
summary(MIMIC3_Cohort_filt)

# Create and save missing data visualization
print("Creating missing data visualization...")
missing_plot <- vis_miss(MIMIC3_Cohort_filt %>% slice_sample(n=1000)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

# Save the plot
ggsave(file.path(base_path, "results", "missing_data_pattern.png"), missing_plot, width = 12, height = 8)

# Create stratified train/test split
print("Creating train/test split...")
part_index <- createDataPartition(MIMIC3_Cohort_filt$VC, p = 0.75, list = FALSE)
train <- MIMIC3_Cohort_filt[part_index, ]
test <- MIMIC3_Cohort_filt[-part_index, ]

print(paste("Training set dimensions:", nrow(train), "x", ncol(train)))
print(paste("Test set dimensions:", nrow(test), "x", ncol(test)))

# Multiple imputation using MICE
print("Starting multiple imputation for training set...")
train_imp <- mice(train, method = 'pmm', m = 100, maxit = 10, printFlag = FALSE)

print("Starting multiple imputation for test set...")
test_imp <- mice(test, method = 'pmm', m = 100, maxit = 10, printFlag = FALSE)

# Complete the imputed datasets
print("Extracting completed datasets...")
train_comp_mean <- complete(train_imp, action = "long")
test_comp_mean <- complete(test_imp, action = "long")
train_comp_long <- complete(train_imp, action = "long", include = TRUE)
test_comp_long <- complete(test_imp, action = "long", include = TRUE)

# Save the MICE objects (contains all imputation info)
print("Saving MICE objects...")
saveRDS(train_imp, file.path(base_path, "results", "train_mice_object.rds"))
saveRDS(test_imp, file.path(base_path, "results", "test_mice_object.rds"))

# Save the completed datasets as CSV
print("Saving imputed datasets...")
write.csv(train_comp_mean, file.path(base_path, "results", "train_imputed_without_incomplete.csv"), row.names = FALSE)
write.csv(test_comp_mean, file.path(base_path, "results", "test_imputed_without_incomplete.csv"), row.names = FALSE)
write.csv(train_comp_long, file.path(base_path, "results", "train_imputed_with_incomplete.csv"), row.names = FALSE)
write.csv(test_comp_long, file.path(base_path, "results", "test_imputed_with_incomplete.csv"), row.names = FALSE)

# Save the filtered dataset (before imputation) for reference
write.csv(MIMIC3_Cohort_filt, file.path(base_path, "results", "MIMIC3_Cohort_filtered.csv"), row.names = FALSE)

# Save single imputation versions (first imputation only) for quick analysis
train_single <- complete(train_imp, 1)
test_single <- complete(test_imp, 1)
write.csv(train_single, file.path(base_path, "results", "train_imputed_single.csv"), row.names = FALSE)
write.csv(test_single, file.path(base_path, "results", "test_imputed_single.csv"), row.names = FALSE)

print("Imputation completed and all files saved successfully!")
print(paste("Number of imputations:", train_imp$m))
print(paste("Number of iterations:", train_imp$iteration))
print("Files saved in results directory:")
print("- MICE objects: train_mice_object.rds, test_mice_object.rds")
print("- Imputed datasets: train/test_imputed_*.csv")
print("- Visualization: missing_data_pattern.png")
