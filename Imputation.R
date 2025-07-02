library(dplyr)
library(naniar)
library(ggplot2)
library(mice)
library(caret)

set.seed(2827)

MIMIC3_Cohort_raw <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC3_Cohort_raw.csv")
MIMIC3_Cohort_raw$X <- NA

miss_var_summary(MIMIC3_Cohort_raw)
MIMIC3_Cohort_filt <- MIMIC3_Cohort_raw[, colSums(!is.na(MIMIC3_Cohort_raw)) >= dim(MIMIC3_Cohort_raw)[1]*.2]
miss_var_summary(MIMIC3_Cohort_filt)
summary(MIMIC3_Cohort_filt)

vis_miss(MIMIC3_Cohort_filt %>% slice_sample(n=1000)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

part_index <- createDataPartition(MIMIC3_Cohort_filt$VC, p = 0.75)
train <- MIMIC3_Cohort_filt[part_index, ]
test <- MIMIC3_Cohort_filt[-part_index, ]

train_imp <- mice(train, method = 'pmm', m = 100, maxit = 10)
test_imp <- mice(test, method = 'pmm', m = 100, maxit = 10)

train_comp_mean <- complete(train_imp, action = "long")
test_comp_mean <- complete(train_imp, action = "long")

train_comp_long <- complete(train_imp, action = "long", include = TRUE)
test_comp_long <- complete(train_imp, action = "long", include = TRUE)
