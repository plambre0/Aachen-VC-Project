library(dplyr)
library(vcd)

diagnoses <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/DIAGNOSES_ICD.csv")
kidney_failure_true <- as.matrix(cbind(unique(diagnoses[diagnoses$ICD9_CODE==585,]$SUBJECT_ID),TRUE))
kidney_failure_false <- as.matrix(cbind(unique(diagnoses[diagnoses$ICD9_CODE!=585,]$SUBJECT_ID),FALSE))
kidney_failure <- rbind(kidney_failure_true,kidney_failure_false)
colnames(kidney_failure) <- c('SUBJECT_ID','Kidney_Faliure')

MIMIC_III <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/Datasets/MIMIC3_Cohort_raw.csv")

MIMIC_III_KF <- data.frame(left_join(x=data.frame(kidney_failure),y=data.frame(MIMIC_III),join_by('SUBJECT_ID')))

MA_KF_VC <- as.data.frame(matrix(nrow = 46755))
MA_KF_VC$MA <- as.factor(MIMIC_III_KF$Anion.Gap.Blood.Chemistry>12)
MA_KF_VC$KF <- as.factor(ifelse(MIMIC_III_KF$Kidney_Faliure==1,TRUE,FALSE))
MA_KF_VC$VC <- as.factor(MIMIC_III_KF$VC)
MA_KF_VC$V1 <- NA

chisq.test(table(MA_KF_VC$VC, MA_KF_VC$KF))

png(filename="VC_KF_Mosaic", res = 400)
art_VC_KF <- xtabs(~ VC + KF, data = MA_KF_VC)
vcd::mosaic(art_VC_KF, gp = shading_max, 
            split_vertical = TRUE, 
            main="VC by KF in Unimputed Data")
dev.off()
png(filename="MA_KF_Mosaic", res = 400)
art_MA_KF <- xtabs(~ MA + KF, data = MA_KF_VC)
vcd::mosaic(art_VC_MA, gp = shading_max, 
            split_vertical = TRUE, 
            main="MA by KF in Unimputed Data")
dev.off()
png(filename="MA_VC_Mosaic", res = 400)
art_MA_VC <- xtabs(~ MA + VC, data = MA_KF_VC)
vcd::mosaic(art_MA_VC, gp = shading_max, 
            split_vertical = TRUE, 
            main="MA by VC in Unimputed Data")
dev.off()

write.csv(data.frame(MIMIC_III_KF$SUBJECT_ID,MIMIC_III_KF$Kidney_Faliure), 'kidney_faliure_pres.csv')