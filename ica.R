library(fastICA)
library(mice)
library(e1071)
library(psych)
library(dplyr)
library(MASS)
library(caret)

test_comp <- read.csv("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/test_imputed_without_incomplete.csv")
train_comp <- read.csv("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/train_imputed_without_incomplete.csv")
train_comp$Transferrin.Blood.Chemistry <- NULL
train_comp$Hematocrit..Calculated.Blood.Blood.Gas <- NULL
kidneys <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/kidney_faliure_pres.csv",row.names = 1)
colnames(kidneys) <- c("SUBJECT_ID", "Kidney_Failure")

train_kidneys <- dplyr::left_join(x=train_comp,y=kidneys,join_by(SUBJECT_ID),relationship = "many-to-many")

VC <- as.factor(train_kidneys$VC)
KF <- as.factor(train_kidneys$Kidney_Failure)
KF <- ifelse(KF==1,TRUE,FALSE)
MA <- as.factor(train_kidneys$Anion.Gap.Blood.Chemistry>12)

sig_vars <- data.frame(Anion_Gap = as.numeric(train_kidneys$Anion.Gap.Blood.Chemistry),
                       Sodium_Urine = as.numeric(train_kidneys$Sodium..Urine.Urine.Chemistry),
                       Bilirubin_Blood = as.numeric(train_kidneys$Bilirubin..Total.Blood.Chemistry),
                       Phosphate_Blood = as.numeric(train_kidneys$Phosphate.Blood.Chemistry),
                       Creatine_Kinase_Blood = as.numeric(train_kidneys$Creatine.Kinase..CK..Blood.Chemistry),
                       Alkaline_Phosphatase_Blood = as.numeric(train_kidneys$Alkaline.Phosphatase.Blood.Chemistry),
                       Temperature_Blood = as.numeric(train_kidneys$Temperature.Blood.Blood.Gas),
                       Fibrinogen_Blood = as.numeric(train_kidneys$Fibrinogen..Functional.Blood.Hematology),
                       Urea_Nitrogen_Blood = as.numeric(train_kidneys$Urea.Nitrogen.Blood.Chemistry),
                       Hemoglobin_Blood = as.numeric(train_kidneys$Hemoglobin.Blood.Hematology),
                       Neutrophils_Blood = as.numeric(train_kidneys$Neutrophils.Blood.Hematology),
                       Red_Blood_Cells = as.numeric(train_kidneys$Red.Blood.Cells.Blood.Hematology),
                       Lymphocytes_Blood = as.numeric(train_kidneys$Lymphocytes.Blood.Hematology),
                       RDW = as.numeric(train_kidneys$RDW.Blood.Hematology))

sig_vars_prcomp <- prcomp(scale(sig_vars))

sig_ica <- fastICA::fastICA(sig_vars, n.comp = 14)
sig_ics <- as.data.frame(sig_ica$S)
colnames(sig_ics) <- paste0("IC", 1:14)
sig_prcomp_ica <- fastICA::fastICA(sig_vars_prcomp$x[,1:6], n.comp = 6)
sig_prcomp_ics <- as.data.frame(sig_ica$S)
colnames(sig_prcomp_ics) <- paste0("IC", 1:6)

group <- VC==TRUE
colors <- ifelse(group, "red", "black")
group_KF <- KF==TRUE
colors_KF <- ifelse(group_KF, "red", "black")
group_MA <- MA==TRUE
colors_MA <- ifelse(group_MA, "red", "black")

ica_logistic <- glm(VC ~ as.matrix(sig_ics),family = binomial(link = 'logit'))
summary(ica_logistic)
ica_prcomp_logistic <- glm(VC ~ as.matrix(sig_prcomp_ics),family = binomial(link = 'logit'))
summary(ica_prcomp_logistic)

kurtosis_values_prcomp <- apply(sig_prcomp_ics, 2, function(x) kurtosis(x, type = 2))
kurtosis_values <- apply(sig_ics, 2, function(x) kurtosis(x, type = 2))

plot(sig_ics$IC13[1:34860], sig_ics$IC7[1:34860], xlab = 'IC13 (z value = 46.66)', ylab = 'IC7 (z value = 33.41)', main='Non Reducd ICA: IC7 by IC13 by VC', col = colors[1:34860])
plot(sig_ics$IC8[1:34860], sig_ics$IC6[1:34860], xlab = 'IC8 (z value = -254.77)', ylab = 'IC6 (z value = -210.76)', main='Non Reducd ICA: IC6 by IC8 by VC', col = colors[1:34860])
plot(sig_ics$IC13[1:34860], sig_ics$IC8[1:34860], xlab = 'IC13 (z value = 46.66)', ylab = 'IC8 (z value = -254.77)', main='Non Reduced ICA: IC8 by IC13 by VC', col = colors[1:34860])

plot(sig_prcomp_ics$IC1[1:34860], sig_prcomp_ics$IC2[1:34860], xlab = 'IC1 (z value = 82.03)', ylab = 'IC2 (z value = 85.80)', main='PCA Reduced ICA: IC1 by IC2 by VC', col = colors[1:34860])
plot(sig_prcomp_ics$IC6[1:34860], sig_prcomp_ics$IC4[1:34860], xlab = 'IC6 (z value = 178.31)', ylab = 'IC4 (z value = -251.08)', main='PCA Reduced ICA: IC4 by IC6 by VC', col = colors[1:34860])
plot(sig_prcomp_ics$IC4[1:34860], sig_prcomp_ics$IC3[1:34860], xlab = 'IC4 (z value = -251.08)', ylab = 'IC3 (z value = -241.08)', main='PCA Reduced ICA: IC3 by IC4 by VC', col = colors[1:34860])

all_fa <- psych::fa(train_kidneys %>% select(-c('.id','.imp','Kidney_Failure','VC','SUBJECT_ID')), nfactors = 85, rotate = "varimax")
factor_scores <- factor.scores(train_kidneys %>% select(-c('.id','.imp','Kidney_Failure','VC','SUBJECT_ID')), all_fa)$scores
all_factors <- all_fa$scores
all_factors
fa_logistic <- glm(VC ~ as.matrix(all_factors),family = binomial(link = 'logit'))
sort(abs(summary(fa_logistic)$coefficients[,'z value']))
plot(all_factors[1:1000,2], all_factors[1:1000,65], xlab = 'MR2', ylab = 'MR65', main='FA: MR2 by MR65 by VC', col = colors[1:1000])
most_sig_factors <- all_factors[,c('MR2','MR65','MR63','MR1','MR7','MR48','MR30')]
most_sig_factors_lda <- MASS::lda(VC ~ most_sig_factors)

test_filt <- (test_comp %>% dplyr::select(-c('.id','.imp')))
vc_test <- test_filt$VC
test_filt <- dplyr::left_join(x=test_filt,y=kidneys,join_by(SUBJECT_ID),relationship = "many-to-many")
test_filt$Kidney_Failure <- NULL
test_filt$SUBJECT_ID <- NULL
test_filt$VC <- NULL

predictions <- predict(all_factors_lda, newdata = as.data.frame(most_sig_factors))
predicted_classes <- predictions$class
confusion_matrix <- confusionMatrix(predicted_classes, VC)
print(confusion_matrix)
accuracy <- confusion_matrix$overall['Accuracy']

