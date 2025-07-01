library(tidyr)
library(dplyr)

set.seed(2827)

D_LABITEMS <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/D_LABITEMS.csv")
NOTEEVENTS <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/NOTEEVENTS.csv")
LABEVENTS <- read.csv("~/Bioinformatics Research/Khomtchouk Lab/Aachen University/MA_VC_Study/LABEVENTS.csv")

LABEVENTS$CHARTTIME <- as.POSIXct(LABEVENTS$CHARTTIME)

ITEMID_groups <- LABEVENTS %>%
  group_by(SUBJECT_ID, ITEMID) %>%
  arrange(CHARTTIME) %>%
  filter(row_number() == 1) %>%
  ungroup()

Cohort <- ITEMID_groups %>%
  select(SUBJECT_ID, ITEMID, VALUENUM) %>%
  pivot_wider(names_from = ITEMID, values_from = VALUENUM)

Cohort <- Cohort %>% arrange(Cohort$SUBJECT_ID)

code_name_map <- setNames(as.list(paste(D_LABITEMS$LABEL,D_LABITEMS$FLUID,D_LABITEMS$CATEGORY)), D_LABITEMS$ITEMID)

Measurements <- Cohort[2:727]
names(Measurements) <- unlist(code_name_map[names(Measurements)])
Measurements$SUBJECT_ID <- Cohort$SUBJECT_ID

calc_terms <- c('vascular calcification',
                'arterial calcification',
                'artery calcification',
                'aortic calcification',
                'calcified aorta',
                'calcified artery',
                'calcified vasculature')

NOTEEVENTS$VC <- grepl(paste(calc_terms, collapse = "|"), NOTEEVENTS$TEXT, ignore.case=TRUE)

vasc_group <- NOTEEVENTS %>%
  group_by(SUBJECT_ID) %>%
  summarise(any_flag = any(VC))

all_measurements <- left_join(Measurements, vasc_group, by = "SUBJECT_ID")
colnames(all_measurements)[colnames(all_measurements) == 'any_flag'] <- 'VC'

write.csv(all_measurements,"MIMIC3_Cohort_raw.csv")