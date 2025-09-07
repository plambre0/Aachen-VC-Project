library(dplyr)
library(tidyverse)
library(naniar)
library(mice)
library(lavaan)
library(lavaanPlot)

#Study Accession phs000007
#Offspring Cohort

#Use in directory with phenotype files from dbgap

#Required Files: 
#pht003099, pht003099, pht000034, pht016162, pht000397, pht000680, pht000041
#pht002565, pht002894, pht000084, pht006013, pht009761

#pht000147: CAC score, Date
pht000147 <- read.csv("pht000147.csv")
pht000147 <- cbind.data.frame(pht000147$dbGaP_Subject_ID, 
                              pht000147$EBCT27, 
                              pht000147$EBCT02)
colnames(pht000147) <- c("dbGaP_Subject_ID", 
                         "CAC", 
                         "CT_Date")

#pht003099: Age, Sex, Exam Dates
pht003099 <- read.csv("pht003099.csv")
pht003099 <- cbind.data.frame(pht003099$dbGaP_Subject_ID, 
                              pht003099$age5, 
                              pht003099$date5,
                              pht003099$sex)
colnames(pht003099) <- c("dbGaP_Subject_ID", 
                         "Age",
                         "Date_5",
                         "Sex")

#pht000034: Height, Weight, Antiplatelets, Insulin, Cardiovascular Meds
pht000034 <- read.csv("pht000034.csv")
pht000034 <- cbind.data.frame(pht000034$dbGaP_Subject_ID, 
                              pht000034$E025, 
                              pht000034$E024)
colnames(pht000034) <- c("dbGaP_Subject_ID", 
                         "Height", 
                         "Weight")

#pht016162: Race
pht016162 <- read.csv("pht016162.csv")
pht016162 <- cbind.data.frame(pht016162$dbGaP_Subject_ID, 
                              pht016162$race_sum)
colnames(pht016162) <- c("dbGaP_Subject_ID", 
                         "Race")

#pht000397: Hypertensives
pht000397 <- read.csv("pht000397.csv")
pht000397 <- cbind.data.frame(pht000397$dbGaP_Subject_ID, 
                              pht000397$HTNMED2)
colnames(pht000397) <- c("dbGaP_Subject_ID", 
                         "Uses_Hypertensives")

#pht000680: Calcium Supplements
pht000680 <- read.csv("pht000680.csv")
pht000680 <- cbind.data.frame(pht000680$dbGaP_Subject_ID, 
                              pht000680$CA)
colnames(pht000680) <- c("dbGaP_Subject_ID", 
                         "Uses_Calcium_Supplements")

#pht000041: Diabetes Status, Fasting Glucose
pht000041 <- read.csv("pht000041.csv")
pht000041 <- cbind.data.frame(pht000041$dbGaP_Subject_ID, 
                              pht000041$CURR_DIAB5)
colnames(pht000041) <- c("dbGaP_Subject_ID", 
                         "Has_Diabetes")

#pht002565: CKD Status, CVD Status
pht002565 <- read.csv("pht002565.csv")
pht002565 <- cbind.data.frame(pht002565$dbGaP_Subject_ID, 
                              pht002565$CKD_case,
                              pht002565$CVD_case)
colnames(pht002565) <- c("dbGaP_Subject_ID", 
                         "Has_CKD", 
                         "Has_CVD")

#pht002894: Lactate
pht002894 <- read.csv("pht002894.csv")
pht002894 <- cbind.data.frame(pht002894$dbGaP_Subject_ID, 
                              pht002894$cmh_lactate)
colnames(pht002894) <- c("dbGaP_Subject_ID", 
                         "Blood_Lactate")

#pht000084: Fibrinogen
pht000084 <- read.csv("pht000084.csv")
pht000084 <- cbind.data.frame(pht000084$dbGaP_Subject_ID, 
                              pht000084$FIBRINOG)
colnames(pht000084) <- c("dbGaP_Subject_ID", 
                         "Citrated_Plasma_Fibrinogen")

#pht006013: Alkaline Phosphatase, Parathyroid Hormone
pht006013 <- read.csv("pht006013.csv")
pht006013 <- cbind.data.frame(pht006013$dbGaP_Subject_ID, 
                              pht006013$X_2795_23, 
                              pht006013$X_3726_62)
colnames(pht006013) <- c("dbGaP_Subject_ID", 
                         "Citrated_Plasma_Alkaline_Phosphatase", 
                         "Citrated_Plasma_Parathyroid_Hormone")

#pht009761: Blood Cortisol, and Creatinine
pht001039 <- read.csv("pht001039.csv")
pht001039 <- cbind.data.frame(pht001039$dbGaP_Subject_ID,
                              pht001039$screconc,
                              pht001039$scorconc)
colnames(pht001039) <- c("dbGaP_Subject_ID", 
                         "Blood_Cortisol",
                         "Blood_Creatinine")

Framingham_Offspring <- pht003099 %>% 
  dplyr::left_join(pht000147)  %>% 
  dplyr::left_join(pht000034)  %>%
  dplyr::left_join(pht016162)  %>%
  dplyr::left_join(pht000397)  %>%
  dplyr::left_join(pht000680)  %>%
  dplyr::left_join(pht000041)  %>%
  dplyr::left_join(pht002565)  %>%
  dplyr::left_join(pht002894)  %>%
  dplyr::left_join(pht000084)  %>%
  dplyr::left_join(pht006013)  %>%
  dplyr::left_join(pht001039)

summary(Framingham_Offspring)
write.csv(Framingham_Offspring, "Framingham_Offspring.csv")

Framingham_Offspring_Trimmed <- Framingham_Offspring
Framingham_Offspring_Trimmed$dbGaP_Subject_ID <- NULL
Framingham_Offspring_Trimmed <- Framingham_Offspring_Trimmed[
  rowSums(is.na(Framingham_Offspring_Trimmed))/ncol(Framingham_Offspring_Trimmed) <= .5,
]

Framingham_Offspring_Trimmed$Sex <-
  as.factor(Framingham_Offspring_Trimmed$Sex)
Framingham_Offspring_Trimmed$Race <-
  as.factor(Framingham_Offspring_Trimmed$Race)
Framingham_Offspring_Trimmed$Uses_Hypertensives <-
  as.factor(Framingham_Offspring_Trimmed$Uses_Hypertensives)
Framingham_Offspring_Trimmed$Uses_Calcium_Supplements <-
  as.factor(Framingham_Offspring_Trimmed$Uses_Calcium_Supplements)
Framingham_Offspring_Trimmed$Has_Diabetes <-
  as.factor(Framingham_Offspring_Trimmed$Has_Diabetes)
Framingham_Offspring_Trimmed$Has_CKD <-
  as.factor(Framingham_Offspring_Trimmed$Has_CKD)
Framingham_Offspring_Trimmed$Has_CVD <-
  as.factor(Framingham_Offspring_Trimmed$Has_CVD)

mice::quickpred(Framingham_Offspring_Trimmed)

Framingham_Offspring_Trimmed_mice <- 
  mice::mice(Framingham_Offspring_Trimmed, m = 70, maxit = 100, seed = 2025)

mice_convergence <- convergence(Framingham_Offspring_Trimmed_mice)
mice_convergence[mice_convergence$.it==1,]$psrf
mice_convergence[mice_convergence$.it==30,]$psrf
mice_convergence[mice_convergence$.it==30,]$psrf - mice_convergence[mice_convergence$.it==1,]$psrf

plot(Framingham_Offspring_Trimmed_mice)
plot(mice_convergence$.it, mice_convergence$psrf)

# Impute the data
Framingham_Offspring_Trimmed_comp <- complete(Framingham_Offspring_Trimmed_mice, action = "long", include = TRUE)

# Calculate BMI, Time_Gap, and recode Sex
Framingham_Offspring_Trimmed_comp$BMI <- ((Framingham_Offspring_Trimmed_comp$Weight) / (Framingham_Offspring_Trimmed_comp$Height^2)) * 703
Framingham_Offspring_Trimmed_comp$Time_Gap <- Framingham_Offspring_Trimmed_comp$CT_Date - Framingham_Offspring_Trimmed_comp$Date_5
Framingham_Offspring_Trimmed_comp$Sex <- ifelse(Framingham_Offspring_Trimmed_comp$Sex == 1, "Male", "Female")
Framingham_Offspring_Trimmed_comp$Sex <- as.factor(Framingham_Offspring_Trimmed_comp$Sex)

# Recode Race using `dplyr` and `case_when`
Framingham_Offspring_Trimmed_comp <- Framingham_Offspring_Trimmed_comp %>%
  mutate(
    Race = factor(case_when(
      Race == 2 ~ "Asian",
      Race == 3 ~ "Black",
      Race == 5 ~ "White",
      Race == 6 ~ "Multiracial or more than one race reported",
      Race == 8 ~ "Prefer not to answer",
      Race == 10 ~ "American Indian or Alaskan Native/Native Hawaiian or Pacific Islander/Other",
      Race == 88 ~ "Defaulted race (White)",
    ), levels = c("Asian", "Black", "White", "Multiracial or more than one race reported", "Prefer not to answer", "American Indian or Alaskan Native/Native Hawaiian or Pacific Islander/Other", "Defaulted race (White)"))
  )

Framingham_Offspring_Trimmed_Missingness <- Framingham_Offspring_Trimmed %>%
  mutate(missing_pattern = apply(
    is.na(.),
    1,
    function(x) paste0(as.integer(x), collapse = "")
  ))

missingness_table <- table(Framingham_Offspring_Trimmed_Missingness$missing_pattern)
sig_missingness_patterns <- names(missingness_table[missingness_table >= nrow(Framingham_Offspring_Trimmed) * .05])
Framingham_Offspring_Trimmed_Missingness$missing_pattern[!(Framingham_Offspring_Trimmed_Missingness$missing_pattern %in% sig_missingness_patterns)] <- "Other"

Framingham_Offspring_Trimmed_comp$missing_pattern <- rep(Framingham_Offspring_Trimmed_Missingness$missing_pattern, times = (length(unique(Framingham_Offspring_Trimmed_comp$.imp))))

Framingham_Offspring_Trimmed_comp_scaled <- Framingham_Offspring_Trimmed_comp %>%
  group_by(.imp) %>%
  mutate(across(
    .cols = setdiff(names(.), c(".imp", ".id", "missing_pattern"))[sapply(.[setdiff(names(.), c(".imp", ".id", "missing_pattern"))], is.numeric)],
    .fns = ~ as.numeric(scale(.))
  )) %>%
  ungroup()

Framingham_Offspring_Trimmed_mice_proc <- mice::as.mids(Framingham_Offspring_Trimmed_comp_scaled)

model <- '
  # Mediators
  Has_CKD         ~ a1*Age
  Blood_Lactate   ~ a2*Has_CKD
  Has_Diabetes    ~ a3*Age
  Has_CVD         ~ a4*Has_CKD + a5*Age

  # Outcome
  CAC ~ b1*Has_CKD + b2*Has_CVD + b3*Blood_Lactate + b4*Has_Diabetes + c1*Age + c2*Time_Gap

  # Covariates
  CAC ~ Sex + Uses_Hypertensives + Uses_Calcium_Supplements

  # Indirect effects
  ind_Age_to_CAC_via_CKD        := a1*b1
  ind_Age_to_CAC_via_CKD_CVD    := a1*a4*b2
  ind_Age_to_CAC_via_CKD_Lactate  := a1*a2*b3
  ind_Age_to_CAC_via_Diabetes   := a3*b4

  # Total effects
  total_Age := c1 + ind_Age_to_CAC_via_CKD + ind_Age_to_CAC_via_CKD_CVD + ind_Age_to_CAC_via_CKD_Lactate + ind_Age_to_CAC_via_Diabetes
'

imp_temp <- Framingham_Offspring_Trimmed_mice_proc$data

imp_temp$Has_CKD <- as.numeric(as.character(imp_temp$Has_CKD))
imp_temp$Has_Diabetes <- as.numeric(as.character(imp_temp$Has_Diabetes))
imp_temp$Has_CVD <- as.numeric(as.character(imp_temp$Has_CVD))

imp_temp$Sex <- ifelse(imp_temp$Sex == "Male", 1, 0)

imp_temp$Uses_Hypertensives <- as.numeric(as.character(imp_temp$Uses_Hypertensives))
imp_temp$Uses_Calcium_Supplements <- as.numeric(as.character(imp_temp$Uses_Calcium_Supplements))

Framingham_Offspring_Trimmed_mice_proc$data <- imp_temp

library(lavaan.mi)
fit_sem <- lavaan.mi::sem.mi(model, data = Framingham_Offspring_Trimmed_mice_proc, missing = "fiml")
summary(fit_sem, standardized = TRUE)
fit_pmm <- lavaan.mi::sem.mi(model, data = Framingham_Offspring_Trimmed_mice_proc, missing = "fiml", group = "missing_pattern")
summary(fit_mi, standardized = TRUE)

pooled_estimates_sem <- parameterestimates(fit_sem, standardized = TRUE)
pooled_estimates_pmm <- parameterestimates(fit_pmm, standardized = TRUE)

lavaanPlot(model = fit_sem, 
           coefs = TRUE,
           stand = TRUE,
           node_options = list(shape = "box", fontname = "Helvetica"),
           edge_options = list(color = "black"))
lavaanPlot(model = fit_pmm, 
           coefs = TRUE,
           stand = TRUE,
           node_options = list(shape = "box", fontname = "Helvetica"),
           edge_options = list(color = "black"))

for (i in 1:70) {
  df_i <- complete(Framingham_Offspring_Trimmed_mice_proc, i)
  fits[[i]] <- lavaan(model, data = df_i, estimator = "ML")
}
Framingham_Offspring_Trimmed_comp_scaled2 <- Framingham_Offspring_Trimmed_comp_scaled

Framingham_Offspring_Trimmed_comp_scaled2$Has_CKD <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Has_CKD)
Framingham_Offspring_Trimmed_comp_scaled2$Sex <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Sex)
Framingham_Offspring_Trimmed_comp_scaled2$Uses_Hypertensives <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Uses_Hypertensives)
Framingham_Offspring_Trimmed_comp_scaled2$Uses_Calcium_Supplements <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Uses_Calcium_Supplements)
Framingham_Offspring_Trimmed_comp_scaled2$Has_Diabetes <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Has_Diabetes)
Framingham_Offspring_Trimmed_comp_scaled2$Has_CVD <- 
  as.numeric(Framingham_Offspring_Trimmed_comp_scaled2$Has_CVD)

Framingham_Offspring_Trimmed_comp_scaled2$AgexTime_Gap <- 
  Framingham_Offspring_Trimmed_comp_scaled2$Age *
  Framingham_Offspring_Trimmed_comp_scaled2$Time_Gap

fit <- lavaan::sem(
  model,
  data = Framingham_Offspring_Trimmed_comp_scaled2,
  estimator = "ML",
  se = "bootstrap",
  bootstrap = 100
)
summary(fit, standardized = TRUE, rsquare = TRUE)

lavaanPlot(model = fit, 
           coefs = TRUE,
           stand = TRUE,
           node_options = list(shape = "box", fontname = "Helvetica"),
           edge_options = list(color = "black"))

# library(brms)
# 
# mediation_model <- brm_multiple(
#   bf(Has_CKD ~ Age, family = bernoulli()) +          # CKD mediator
#     bf(Blood_Lactate ~ Has_CKD, family = gaussian()) + # Lactate mediator (continuous)
#     bf(Has_Diabetes ~ Age, family = bernoulli()) +    # Diabetes mediator
#     bf(Has_CVD ~ Has_CKD + Age, family = bernoulli()) + # CVD mediator
#     bf(CAC ~ Has_CKD + Has_CVD + Blood_Lactate + Has_Diabetes +
#          Age + Time_Gap + Sex + Uses_Hypertensives + Uses_Calcium_Supplements,
#        family = gaussian()) +                          # Outcome
#     set_rescor(FALSE),                                 # residuals independent
#   data = Framingham_Offspring_Trimmed_mice_proc,
#   chains = 4,
#   cores = 4,
#   iter = 1000,
#   seed = 2025
# )
# 
# Framingham_Offspring_Trimmed_mice_proc2 <- mice::as.mids(Framingham_Offspring_Trimmed_comp_scaled)
# 
# mediation_model <- brm_multiple(
#   bf(Has_CKD ~ Age + (1|missing_pattern), family = bernoulli()) +          # CKD mediator
#     bf(Blood_Lactate ~ Has_CKD + (1|missing_pattern), family = gaussian()) + # Lactate mediator
#     bf(Has_Diabetes ~ Age + (1|missing_pattern), family = bernoulli()) +    # Diabetes mediator
#     bf(Has_CVD ~ Has_CKD + Age + (1|missing_pattern), family = bernoulli()) + # CVD mediator
#     bf(CAC ~ Has_CKD + Has_CVD + Blood_Lactate + Has_Diabetes +
#          Age + Time_Gap + Sex + Uses_Hypertensives + Uses_Calcium_Supplements + (1|missing_pattern),
#        family = gaussian()) +                          # Outcome
#     set_rescor(FALSE),                                 # residuals independent
#   data = Framingham_Offspring_Trimmed_mice_proc2,
#   chains = 4,
#   cores = 4,
#   iter = 1000,
#   seed = 2025
# )
# 
# summary(mediation_model)
