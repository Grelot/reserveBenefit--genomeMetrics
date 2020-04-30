## provide a map or three maps (one for each species)-->selection of individuals


###############################################################################
# library

library(tidyverse)
library(dplyr)
library(countrycode)



###############################################################################
## data

## load table S7
samp <- read.csv("coords/sample.csv", sep=";", header=T)


###############################################################################
## draw map