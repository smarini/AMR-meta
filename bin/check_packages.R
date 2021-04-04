check_packages <- c("Matrix", "stringr", "glmnet")
not_present <- check_packages[!(check_packages %in% installed.packages()[,"Package"])]
if(length(not_present)){
  message(paste("The following R package is not present, please intstall it:", not_present, "\n"))
  message(paste("MetAMR will terminate.\n"))
  quit(status = 1)
}