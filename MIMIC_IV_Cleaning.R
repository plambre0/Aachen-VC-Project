library(data.table)
library(dplyr)
library(tidyr)

MIMIC_IV_lab_events_crop <- data.frame(fread("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC4_labevents.csv", select = c("subject_id","itemid","value",'charttime')))
MIMICIV_labitems <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC4_d_labitems.csv")
MIMIC_IV_demo <- data.frame(fread("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC4_patients.csv", select = c('subject_id','gender','anchor_age')))
MIMIC_Diagnoses <- data.frame(fread("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC4_diagnoses_icd.csv", select = c('subject_id','icd_code')))
MIMIC_IV_d_Diagnoses <- data.frame(fread("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC4_d_icd_diagnoses.csv"))
MIMIC_IV <- dplyr::left_join(MIMIC_IV_lab_events_crop, MIMIC_IV_demo, join_by(subject_id))

MIMIC_IV_lab_events_crop$charttime <- as.POSIXct(MIMIC_IV_lab_events_crop$charttime)

MIMIC_IV_lab_events_groups <- MIMIC_IV_lab_events_crop %>%
  group_by(subject_id, itemid) %>%
  arrange(charttime) %>%
  filter(row_number() == 1) %>%
  ungroup()

MIMIC_IV_lab_events_first <- MIMIC_IV_lab_events_groups %>%
  select(subject_id, itemid, value) %>%
  pivot_wider(names_from = itemid, values_from = value)

code_name_map <- setNames(as.list(paste(MIMICIV_labitems$label,MIMICIV_labitems$fluid,MIMICIV_labitems$category)), MIMICIV_labitems$itemid)

MIMIC_IV_Cohort <- as.data.frame(sapply(MIMIC_IV_lab_events_first,as.numeric))[,2:977]
names(MIMIC_IV_Cohort) <- code_name_map[names(MIMIC_IV_Cohort)]
MIMIC_IV_Cohort <- cbind(subject_id=MIMIC_IV_lab_events_first$subject_id,MIMIC_IV_Cohort)
MIMIC_IV_Cohort
MIMIC_IV_Cohort <- MIMIC_IV_Cohort[,c(unique(names(MIMIC_IV_Cohort)))]

MIMIC_IV_Cohort2 <- dplyr::left_join(MIMIC_IV_demo,MIMIC_IV_Cohort,join_by(subject_id))

MIMIC_Diagnoses$icd_code

calc_codes <- c('4400','4401','44020','44021','44022','44023','44024','44029','44029')
calc_cohort <- MIMIC_Diagnoses[MIMIC_Diagnoses$icd_code %in% calc_codes,]
calc_cohort$VC <- TRUE
kf_codes <- c('N18','N181','N182','N183','N1830','N1831','N1832','N184','N185','N186','N189','N19')
kf_cohort <- MIMIC_Diagnoses[MIMIC_Diagnoses$icd_code %in% kf_codes,]
kf_cohort$KF <- TRUE 

calc_cohort <- calc_cohort %>% group_by(subject_id) %>% slice(which.max(VC))
kf_cohort <- kf_cohort %>% group_by(subject_id) %>% slice(which.max(KF))

MIMIC_IV_Cohort3 <- dplyr::left_join(MIMIC_IV_Cohort2,kf_cohort,join_by(subject_id))
MIMIC_IV_Cohort3 <- dplyr::left_join(MIMIC_IV_Cohort3,calc_cohort,join_by(subject_id))
MIMIC_IV_Cohort3$VC[is.na(MIMIC_IV_Cohort3$VC)] <- FALSE
MIMIC_IV_Cohort3$KF[is.na(MIMIC_IV_Cohort3$KF)] <- FALSE

MIMIC_IV_Cohort3$MA <- MIMIC_IV_Cohort3$`Anion Gap Blood Chemistry`>12

write.csv(MIMIC_IV_Cohort3, 'MIMIC_IV_Cohort_inc.csv')