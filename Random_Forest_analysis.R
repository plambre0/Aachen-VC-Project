library(mice)
library(randomForest)

train_imp <- readRDS("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/test_mice_object.rds")
test_imp <- readRDS("C:/Users/Paolo/Downloads/Paolo_MIMIC_results/test_mice_object.rds")

trees <- lapply(1:train_imp$m, function(i) {
  train <- complete(train_imp, i)
  
  predictors <- setdiff(
    names(train),
    c("VC", "Transferrin.Blood.Chemistry", "Hemoglobin.Blood.Blood.Gas", "SUBJECT_ID")
  )
  
  formula <- as.formula(paste("as.factor(VC) ~", paste(predictors, collapse = "+")))
  rf_vc <- randomForest(formula, data = train, importance = TRUE)
  print(i)
  importances <- as.data.frame(rf_vc$importance[,4])
  importances$Feature <- rownames(importances)
  rownames(importances) <- NULL
  
  list(model = rf_vc,importance = importances)
})

average_importances <- matrix(0, nrow=100,ncol=1)
for (i in 1:100) {
  average_importances <- average_importances + trees[[i]]$importance[1]
}
average_importances <- average_importances/100
average_importances[,2] <- trees[[1]]$importance[2]
colnames(average_importances)[1] <- 'Average Mean Decrease Gini'
average_importances_sorted <- average_importances[order(average_importances$`Average Mean Decrease Gini`,decreasing=TRUE),]

write.csv(average_importances_sorted, 'average_importances_rf_imputed.csv')

saveRDS(trees, file="imputed_rf_trees_imp.RData")

