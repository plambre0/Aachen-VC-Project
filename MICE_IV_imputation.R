#the csv is at https://drive.google.com/file/d/1fLxnohsFktvDxmyEtBbP3G-Q8wzhMNyq/view?usp=drive_link

library(naniar)
library(dplyr)
library(softImpute)
library(psych)
library(MASS)
library(caret)
library(mice)
library(caTools)

set.seed(1922)

MIMIC_IV_Cohort_inc <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC_IV_Cohort_inc.csv")
MIMIC_IV_Cohort_inc_filt <- MIMIC_IV_Cohort_inc[, colSums(!is.na(MIMIC_IV_Cohort_inc)) >= dim(MIMIC_IV_Cohort_inc)[1]*.2]
MIMIC_IV_Cohort_inc_filt

vis_miss(dplyr::slice_sample(MIMIC_IV_Cohort_inc_filt,n=1000))

MIMIC_IV_Cohort_inc_filt_num <- MIMIC_IV_Cohort_inc_filt
MIMIC_IV_Cohort_inc_filt_num$X <- NULL
MIMIC_IV_Cohort_inc_filt_num$subject_id <- NULL
MIMIC_IV_Cohort_inc_filt_num$VC <- as.numeric(MIMIC_IV_Cohort_inc_filt_num$VC)
MIMIC_IV_Cohort_inc_filt_num$MA <- as.numeric(MIMIC_IV_Cohort_inc_filt_num$MA)
MIMIC_IV_Cohort_inc_filt_num$KF <- as.numeric(MIMIC_IV_Cohort_inc_filt_num$KF)
MIMIC_IV_Cohort_inc_filt_num$gender <- ifelse(MIMIC_IV_Cohort_inc_filt_num$gender=='M',1,0)

split_bool <- sample.split(Y = MIMIC_IV_Cohort_inc_filt_num$VC, SplitRatio = 0.8)
train_data <- subset(MIMIC_IV_Cohort_inc_filt_num, split_bool == TRUE)
test_data <- subset(MIMIC_IV_Cohort_inc_filt_num, split_bool == FALSE)

MIMIC_IV_Cohort_mice_train <- mice::mice(train_data,m=100)
MIMIC_IV_Cohort_mice_test <- mice::mice(test_data,m=100)
saveRDS(MIMIC_IV_Cohort_mice_train, 'MIMIC_IV_Cohort_mice_train.rds')
saveRDS(MIMIC_IV_Cohort_mice_test, 'MIMIC_IV_Cohort_mice_test.rds')

#Code for test SVD Imputation No Train/Test split
#MIMIC_IV_Cohort_imp_filt <- softImpute::softImpute(as.matrix(MIMIC_IV_Cohort_inc_filt_num), maxit = 100)
#MIMIC_IV_SVD_100 <- complete(MIMIC_IV_Cohort_inc_filt_num,MIMIC_IV_Cohort_imp_filt)
#MIMIC_IV_SVD_100$gender <- round(MIMIC_IV_SVD_100$gender)
#MIMIC_IV_SVD_100$KF <- round(MIMIC_IV_SVD_100$KF)
#MIMIC_IV_SVD_100$VC <- round(MIMIC_IV_SVD_100$VC)
#MIMIC_IV_SVD_100$MA <- round(MIMIC_IV_SVD_100$MA)
#MIMIC_IV_SVD_100$MA[MIMIC_IV_SVD_100$MA<0] <- 0
#MIMIC_IV_SVD_100$MA[MIMIC_IV_SVD_100$MA>1] <- 1

#write.csv(MIMIC_IV_SVD_100,'MIMIC_IV_SVD_100.csv')
