# Set up library paths first
new_lib_path <- "/N/slate/nelbadia/Ger-WI-Collabs/R_libs"
.libPaths(c(new_lib_path, .libPaths()))

# Load libraries (simplified - don't need lib parameter with .libPaths set)
library(here)
library(dplyr)
library(tidyr)

# Set working directory to project root
setwd(dirname(here()))
if (!file.exists("MAVC_R.Rproj")) {
  setwd("/N/slate/nelbadia/Ger-WI-Collabs/Germany/MAVC_R")
}

set.seed(2827)

D_LABITEMS <- read.csv(here("data", "mimic3", "D_LABITEMS.csv"))
NOTEEVENTS <- read.csv(here("data", "mimic3", "NOTEEVENTS.csv"))
LABEVENTS <- read.csv(here("data", "mimic3", "LABEVENTS.csv"))

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

write.csv(all_measurements, here("results", "MIMIC3_Cohort_raw.csv"))
