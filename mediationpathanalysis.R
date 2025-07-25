library(brms)
library(bnlearn)
library(mice)
library(dplyr)
library(umap)
library(igraph)
library(bayesplot)

train <- readRDS("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/train_mice_object.rds")
train_comp <- complete(train, action = "long")
train_comp$Transferrin.Blood.Chemistry <- NULL
train_comp$Hematocrit..Calculated.Blood.Blood.Gas <- NULL
kidneys <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/kidney_faliure_pres.csv",row.names = 1)
colnames(kidneys) <- c("SUBJECT_ID", "Kidney_Failure")

train_kidneys <- dplyr::left_join(x=train_comp,y=kidneys,join_by(SUBJECT_ID),relationship = "many-to-many")

sig_vars <- data.frame(VC = train_kidneys$VC,
                       KF = train_kidneys$Kidney_Failure,
                       Anion_Gap = as.numeric(train_kidneys$Anion.Gap.Blood.Chemistry),
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
sig_vars$VC <- as.factor(sig_vars$VC)
sig_vars$KF <- as.factor(sig_vars$KF)
sig_vars$MA <- as.factor(sig_vars$Anion_Gap>12)

fit_kidney <- brm(
  KF ~ MA,
  family = bernoulli(),
  data = sig_vars,
  chains = 4, cores = 4, iter = 2000, warmup = 1000
)

fit_fibrinogen <- brm(
  Fibrinogen_Blood ~ MA + KF,
  data = sig_vars,
  chains = 4, cores = 4, iter = 2000, warmup = 1000
)

fit_calcification <- brm(
  VC ~ MA + KF + Fibrinogen_Blood,
  family = bernoulli(),
  data = sig_vars,
  chains = 4, cores = 4, iter = 2000, warmup = 1000
)

post_kidney <- as_draws_df(fit_kidney)
post_fibrinogen <- as_draws_df(fit_fibrinogen)
post_calc <- as_draws_df(fit_calcification)

a1 <- post_kidney$b_MATRUE
a2 <- post_fibrinogen$b_KF1
b  <- post_calc$b_Fibrinogen_Blood

indirect_effect <- a1 * a2 * b

mean(indirect_effect)
quantile(indirect_effect, probs = c(0.025, 0.975))
mcmc_areas(data.frame(indirect_effect = indirect_effect), pars = "indirect_effect")

