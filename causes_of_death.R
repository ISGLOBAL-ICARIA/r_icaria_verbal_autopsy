library(ruODK)
library(CrossVA)
library(openVA)

source("credentials.R")

# Extract data from the ODK Central server where the 2016 WHO Verbal Autopsy 
# Form 1.5.3 is setup
kTimeZone <- "Africa/Freetown"
ruODK::ru_setup(
  svc     = kServiceURL, 
  un      = kUsername, 
  pw      = kPassword,
  tz      = kTimeZone,
  verbose = T
)

va.data <- ruODK::odata_submission_get()

# Ideally, we should only use approved records
va.data <- va.data[which(va.data$system_review_state == "approved"), ]