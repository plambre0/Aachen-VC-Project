local_files <- list.files(pattern = "\\.txt$", full.names = TRUE)
ascensions <- sub(".*(pht[0-9]+).*", "\\1", basename(local_files))
unique_asc <- unique(ascensions)

for (asc in unique_asc) {
  group_files <- local_files[grep(asc, local_files)]
  parts <- list()
  
  for (lf in group_files) {
    lines <- readLines(lf)
    last_mark <- max(grep("^#", lines))
    clean <- lines[(last_mark + 1):length(lines)]
    clean <- trimws(clean, which = "both")
    clean <- clean[nzchar(clean)]
    tmp <- tempfile()
    writeLines(clean, tmp)
    part <- read.delim(tmp, sep = "\t", stringsAsFactors = FALSE)
    parts[[lf]] <- part
  }
  
  merged <- do.call(rbind, parts)
  assign(asc, merged, envir = .GlobalEnv)
  write.csv(merged, file = paste0(asc, ".csv"), row.names = FALSE)
}
