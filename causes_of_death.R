library(ruODK)
library(CrossVA)
library(openVA)

source("credentials.R")

# Parameters
kTimeZone <- "Africa/Freetown"
kHIVMortality <- "l"     # h (high), l (low), or v (very low)
kMalariaMortality <- "h" # h (high), l (low), or v (very low)

# Extract data from the ODK Central server where the 2016 WHO Verbal Autopsy 
# Form 1.5.3 is setup
ruODK::ru_setup(
  svc          = kServiceURL, 
  un           = kUsername, 
  pw           = kPassword,
  tz           = kTimeZone,
  verbose      = T,
  odkc_version = 1.2
)

# As the OData export method has an opened bug 
# (https://github.com/ropensci/ruODK/issues/100) which results on dropping empty
# columns that need to be present anyway for CrossVA, we have to export the data
# using the RESTful API. We download the data in a zip file and unpack it. Then
# read the data into the csv file
zip <- ruODK::submission_export()
file <- unzip(zip)
va.data <- read.csv(file, stringsAsFactors = F)

# Ideally, we should only use approved records
va.data <- va.data[which(va.data$ReviewState == "approved"), ]

# Convert VAs using the odk2openVA() function for version 1.5.1+. We will be 
# able to use either InterVA5 or insilico(data.type = "WHO2016") to assign CoD
openva_input_v151 <- odk2openVA(va.data)

# Assign CoD with model = InterVA5 through codeVA
run <- codeVA(
  data      = openva_input_v151,
  data.type = "WHO2016",
  model     = "InterVA",
  version   = "5.0",
  HIV       = kHIVMortality,
  Malaria   = kMalariaMortality,
  write     = T,
  directory = getwd()
)