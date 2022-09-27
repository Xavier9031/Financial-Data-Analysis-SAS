## Load the package
library(readxl)
library(tidyverse)
library(tidyr)
library(ggplot2)
library("formattable")
library(dplyr)
library(lubridate)
library(ggpubr)
Sys.setlocale("LC_TIME", "English")

## Read the data set
data = read_excel("P03_33.xlsx ", sheet ='Data')