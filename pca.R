library(umap)
library(mice)
library(dplyr)
library(ica)
library(ggplot2)
library(GGally)

train <- readRDS("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/train_mice_object.rds")
train_comp <- complete(train, action = "long")
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

all_prcomp <- prcomp(scale(train_kidneys %>% select(-c(VC,Kidney_Failure))))
sig_vars_prcomp <- prcomp(scale(sig_vars))
pca_plot_all_VC <- plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 3.380021%", ylab = "PC2 2.747311%", main = "PCA of all measurements by VC", col=VC)
pca_plot_sig_VC <- plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 13.14454%", ylab = "PC2 11.03893%", main = "PCA of subset of significant measurements by VC", col=VC)
pca_plot_all_KF <- plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 3.380021%", ylab = "PC2 2.747311%", main = "PCA of all measurements by KF", col=train_kidneys$Kidney_Failure)
pca_plot_sig_KF <- plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 13.14454%", ylab = "PC2 11.03893%", main = "PCA of subset of significant measurements by KF", col=train_kidneys$Kidney_Failure)
pca_plot_all_MA <- plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 3.380021%", ylab = "PC2 2.747311%", main = "PCA of all measurements by MA", col=as.factor(train_kidneys$Anion.Gap.Blood.Chemistry>12))
pca_plot_sig_MA <- plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 13.14454%", ylab = "PC2 11.03893%", main = "PCA of subset of significant measurements by MA", col=as.factor(train_kidneys$Anion.Gap.Blood.Chemistry>12))

png(filename="pca_all_VC.png", res = 400)
plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 (3.380021%)", ylab = "PC2 (2.747311%)", main = "PCA of all measurements by VC", col=VC)
legend("topright", legend = c("VC", "No VC"), col = c("red", "black"), pch = 1)
dev.off()
png(filename="pca_sig_VC.png", res = 400)
plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 (13.14454%)", ylab = "(PC2 11.03893%)", main = "PCA of subset of significant measurements by VC", col=VC)
legend("topright", legend = c("VC", "No VC"), col = c("red", "black"), pch = 1)
dev.off()
png(filename="pca_all_KF.png", res = 400)
plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 (3.380021%)", ylab = "PC2 (2.747311%)", main = "PCA of all measurements by KF", col=train_kidneys$Kidney_Failure)
legend("topright", legend = c("KF", "No KF"), col = c("red", "black"), pch = 1)
dev.off()
png(filename="pca_sig_KF.png", res = 400)
plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 (13.14454%)", ylab = "PC2 (11.03893%)", main = "PCA of subset of significant measurements by KF", col=train_kidneys$Kidney_Failure)
legend("topright", legend = c("KF", "No KF"), col = c("red", "black"), pch = 1)
dev.off()
png(filename="pca_all_MA.png", res = 400)
plot(all_prcomp$x[,1], all_prcomp$x[,2], xlab = "PC1 (3.380021%)", ylab = "PC2 (2.747311%)", main = "PCA of all measurements by MA", col=as.factor(train_kidneys$Anion.Gap.Blood.Chemistry>12))
legend("topright", legend = c("MA", "No MA"), col = c("red", "black"), pch = 1)
dev.off()
png(filename="pca_sig_KF.png", res = 400)
plot(sig_vars_prcomp$x[,1],sig_vars_prcomp$x[,2], xlab = "PC1 (13.14454%)", ylab = "PC2 (11.03893%)", main = "PCA of subset of significant measurements by MA", col=as.factor(train_kidneys$Anion.Gap.Blood.Chemistry>12))
legend("topright", legend = c("MA", "No MA"), col = c("red", "black"), pch = 1)
dev.off()

