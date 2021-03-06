### Load packages ###################################################

  library(HMDHFDplus)
  library(tidyverse)
  library(readxl)
  library(httr)
  
  #us <- "username"
  #pw <- "password"


### Load data #######################################################

  GerPop <- readHMDweb(CNTRY="DEUTNP","Exposures_1x1",us,pw)
  USAPop <- readHMDweb(CNTRY="USA","Exposures_1x1",us,pw)


### Restrict data ###################################################

  # Filter data
  GerPop <- GerPop %>% filter(Year==2017) %>% select(Year,Age,Total)
  USAPop <- USAPop %>% filter(Year==2018) %>% select(Year,Age,Total)
  
  # To reproduce Levin et al.; should probably be scaled to match 
  # US population size, but not necessary for IFRs
  # USAPop$Total <- 100


### Aggregate/open ended category ###################################

  open1 <- 85 # To reproduce Levin et al. set open1 > 80
  maxage <- 110 # To reproduce Levin et al set maxage to 80
  if(maxage<open1) open2 <- maxage else open2 <- open1
  
  GerPop <- GerPop %>% filter(Age<=maxage)
  USAPop <- USAPop %>% filter(Age<=maxage)
  
  GerPop <- GerPop %>% mutate(Age=ifelse(Age>=open2,open2,Age))
  USAPop <- USAPop %>% mutate(Age=ifelse(Age>=open2,open2,Age))
  
  GerPop <- aggregate(Total~Year+Age,data=GerPop,sum)
  USAPop <- aggregate(Total~Year+Age,data=USAPop,sum)


### Load IFRs #######################################################

  # Load
  source("Data/scaled_IFR_COIs_c.R")

  # German data
  GerPop$IFR <- scaled_IFR_COIs_c["Germany",paste(0:open1),"mode"]
  GerPop$PIl <- scaled_IFR_COIs_c["Germany",paste(0:open1),"low95"]
  GerPop$PIu <- scaled_IFR_COIs_c["Germany",paste(0:open1),"up95"]
  
  # US data
  USAPop$IFR <- scaled_IFR_COIs_c["US",paste(0:open1),"mode"]
  USAPop$PIl <- scaled_IFR_COIs_c["US",paste(0:open1),"low95"]
  USAPop$PIu <- scaled_IFR_COIs_c["US",paste(0:open1),"up95"]
  
  
### Scenarios #######################################################

  # Set scenarios
  nopen <- length(65:open2)
  scenario1 <- c(rep(0.23,50),rep(0.16,15),rep(0.14,nopen))
  scenario2 <- c(rep(0.20,50),rep(0.20,15),rep(0.20,nopen))
  scenario3 <- c(rep(0.26,50),rep(0.10,15),rep(0.06,nopen))
  
  # Apply to Germany
  GerPop$scenario1 <- scenario1
  GerPop$scenario2 <- scenario2
  GerPop$scenario3 <- scenario3
  
  # Apply to US
  USAPop$scenario1 <- scenario1
  USAPop$scenario2 <- scenario2
  USAPop$scenario3 <- scenario3


### Calculate Germany ###############################################

  # Cases
  GerPop <- GerPop %>% mutate(Cases1=Total*scenario1) 
  GerPop <- GerPop %>% mutate(Cases2=Total*scenario2) 
  GerPop <- GerPop %>% mutate(Cases3=Total*scenario3) 
  
  # Deaths
  GerPop <- GerPop %>% mutate(Deaths1=Cases1*IFR)
  GerPop <- GerPop %>% mutate(Deaths2=Cases2*IFR)
  GerPop <- GerPop %>% mutate(Deaths3=Cases3*IFR)
  
  # Results
  sum(GerPop$Deaths1)/sum(GerPop$Cases1)
  sum(GerPop$Deaths2)/sum(GerPop$Cases2)
  sum(GerPop$Deaths3)/sum(GerPop$Cases3)


### Calculate USA ###################################################

  # Cases
  USAPop <- USAPop %>% mutate(Cases1=Total*scenario1) 
  USAPop <- USAPop %>% mutate(Cases2=Total*scenario2) 
  USAPop <- USAPop %>% mutate(Cases3=Total*scenario3) 
  
  # Deaths
  USAPop <- USAPop %>% mutate(Deaths1=Cases1*IFR)
  USAPop <- USAPop %>% mutate(Deaths2=Cases2*IFR)
  USAPop <- USAPop %>% mutate(Deaths3=Cases3*IFR)
  
  # Results
  sum(USAPop$Deaths1)/sum(USAPop$Cases1)
  sum(USAPop$Deaths2)/sum(USAPop$Cases2)
  sum(USAPop$Deaths3)/sum(USAPop$Cases3)


### Prediction intervals ############################################

  # Deaths low/up Germany
  GerPop <- GerPop %>% mutate(Deaths1low=Cases1*PIl)
  GerPop <- GerPop %>% mutate(Deaths2low=Cases2*PIl)
  GerPop <- GerPop %>% mutate(Deaths3low=Cases3*PIl)
  
  GerPop <- GerPop %>% mutate(Deaths1up=Cases1*PIu)
  GerPop <- GerPop %>% mutate(Deaths2up=Cases2*PIu)
  GerPop <- GerPop %>% mutate(Deaths3up=Cases3*PIu)
  
  # Results low/up Germany
  sum(GerPop$Deaths1low)/sum(GerPop$Cases1)
  sum(GerPop$Deaths2low)/sum(GerPop$Cases2)
  sum(GerPop$Deaths3low)/sum(GerPop$Cases3)
  
  sum(GerPop$Deaths1up)/sum(GerPop$Cases1)
  sum(GerPop$Deaths2up)/sum(GerPop$Cases2)
  sum(GerPop$Deaths3up)/sum(GerPop$Cases3)
  
  # Deaths low/up US
  USAPop <- USAPop %>% mutate(Deaths1low=Cases1*PIl)
  USAPop <- USAPop %>% mutate(Deaths2low=Cases2*PIl)
  USAPop <- USAPop %>% mutate(Deaths3low=Cases3*PIl)
  
  USAPop <- USAPop %>% mutate(Deaths1up=Cases1*PIu)
  USAPop <- USAPop %>% mutate(Deaths2up=Cases2*PIu)
  USAPop <- USAPop %>% mutate(Deaths3up=Cases3*PIu)
  
  # Results low/up US
  sum(USAPop$Deaths1low)/sum(USAPop$Cases1)
  sum(USAPop$Deaths2low)/sum(USAPop$Cases2)
  sum(USAPop$Deaths3low)/sum(USAPop$Cases3)
  
  sum(USAPop$Deaths1up)/sum(USAPop$Cases1)
  sum(USAPop$Deaths2up)/sum(USAPop$Cases2)
  sum(USAPop$Deaths3up)/sum(USAPop$Cases3)