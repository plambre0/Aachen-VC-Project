# Aachen-VC-Project

Methodology

  The dataset used was the MIMIC-III database. The description of the database is as follows: "MIMIC-III is a dataset comprising health-related data associated with over 40,000 patients who stayed in critical care units of the Beth Israel Deaconess Medical Center between 2001 and 2012". It is important to consider that any anlysis must be taken into consideration with the fact that health outcomes are particularly correlated with location, in which the location is known for the population skewing younger and being home to a racially diverse population, which makes simulataniously makes data from the location generalizable but with the caveat that the population skews younger, which may have an impact on the number of people with vascular calcification or metabolic acidosis and the reason as to why they have developed these conditions.
  Due to the nature of this dataset, most people that were in the ICU likely only had measurements taken that were standard or related to a symptom that the patient was exhibiting, which implies that the measurements taken are more likely to be abnormal than in the general population when they are not ill. Since most people did not have all measurements, iterative Singular Value Decomposition was used for data imputation (Yuan Luo, Evaluating the state of the art in missing data imputation for clinical data). This method is reguarded to have a higher level of accuracy, although it is significant that many patients may not have had much overlap in measurements, which theoretically may lead to significant innacuracies.
  To classify patients in the dataset as having metabolic acidosis, the anion gap was calculated as: (Na+ + K+) – (Cl- + HCO3-), and those who had anion gaps above 12 were considered to have metabolic acidosis (Pandey DG, Sharma S. Biochemistry, Anion Gap.). Unfortunately, the dataset does not have direct measures for vascular calcification, but it includes patient notes which contain information as to whether people have vascular calcification. These notes were parsed for mentions of 'vascular calcification' and were encoded with boolean values. It is notable that notes with words like only 'calcification' when investigated included patients that had calcification in non-vascular systems, which is why the presence of both adjacent were required.
  A Chi-Square Test of Independence was ran on the contingency data for MA-VC and the probability that the data would be seen if the two states were independent was %01.473, which means that they are not likely. Patients with metabolic acidosis were less likely to have vascular calcification and vice versa.
  Binomial tests were ran on measurements related to metabolic acidosis and only anion gap, base excess, bicarbonate, lactate, and pH were individually statistically significant.
  When UMAP was used for dimensionality reduction for the evaluation of clustering, which could be used to intuitively measure how strongly the presence of MA may decide whether or not there is VC. There appear to be very small far apart clusters for those with VC, which implies that acidity may interact with other processes or chemicals in the body to regulate calcification.
  Random Forest Classification was used to calculate feature importance for the prediction of Vascular Calcification on a coerced dataset with patients as rows, and columns as measurements and/or the presence of VC/MA (VC was not included in the Random Forest). Theoretically, the highest importance features should somehow be related to or interact with vascular calcification.

The top 10 Highest Scoring measurements were in order of most to least important:
1: Vancomycin
2: Lactate
3: pO2
4: pCO2
5: Temperature
6: Free Calcium
7: Urea Nitrogen
8: Parathyroid Hormone
9: Glucose
10: pH

Interestingly, this seems to agree with the notion that metabolic acidosis being related to vascular calcification. Most of these measurements are for things that have been previously observed to interact with calcification in general.
