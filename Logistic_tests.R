train_comp <- readRDS("train_imputed_single.csv")
test_comp <- readRDS("test_imputed_single.csv")

train_comp <- complete(train_imp, action = "long")
test_comp <- complete(test_imp, action = "long")

outcome <- "VC"
all_vars <- setdiff(names(train_imp$data), c("SUBJECT_ID", "VC"))

bt_term <- function(x) paste0("I((", x, " + 0.0001)*log(", x, " + 0.0001))")
bt_terms <- sapply(all_vars, bt_term)

formula_string <- paste(outcome, "~",
                        paste(all_vars, collapse = " + "), "+",
                        paste(bt_terms, collapse = " + "))

bt_fit <- with(train_imp, glm(as.formula(formula_string), family = binomial))
bt_pooled <- pool(bt_fit)

bt_results <- summary(bt_pooled)
bt_only <- bt_results[grep("^I\\(", bt_results$term), ]

print(bt_only)

log_test <- with(train_imp, {
  all_vars <- setdiff(names(train_imp$data), c("SUBJECT_ID", "VC"))
  formula_obj <- as.formula(paste("VC ~", paste(all_vars, collapse = " + ")))
  glm(formula_obj, family = binomial(link = "logit"))
})

pooled_log_test <- pool(fit)
pooled_log_results <- data.frame(summary(pooled_log_test)$term, summary(pooled_log_test)$p.value)
colnames(pooled_log_results) <- c('Term','P-Value')
pooled_log_results[order(pooled_log_results$`P-Value`),]