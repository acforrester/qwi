# quick program to download the quarterly workforce indicators from 
# the census bureau ftp site and unzip them into a directory

rm(list = ls())

pkgs = c("tidyverse","haven","dplyr")
for (pkg in pkgs){
  if (!require(pkg, character.only = T)){
    install.packages(pkg)
    library(pkg)
  }
}

# qwi version to get. can also specify 'latest_release'
version <- "R2019Q1"

# some directories
main <- file.path("CHANGE DIRECTORY")
code <- file.path(main,"code")
raw  <- file.path(main,"raw")
dta  <- file.path(main,"dta")
zip  <- file.path(main,"zip")

# read in the state postal codes
states <- read_csv( paste0( code ,"/" , "states.csv") ) %>% 
            transmute( usps=tolower(usps))

# lists of endpoints
geolist <- c( "gs" )
ownlist <- c( "op" )
grplist <- c( "rh" )
indlist <- c( "ns" , "n3" )

# values we want to loop over
grid <- expand.grid(state=states$usps , geo = geolist , own = ownlist , grp = grplist , ind = indlist)

# function to get the qwi's from the uscb ftp site
getqwi <- function(st,geo,own,grp,ind){
  
  file <- paste0("qwi_" , st , "_" , grp , "_f_" , geo , "_" , ind , "_" , own , "_u" , ".csv.gz" )

  if(!file.exists( paste0( zip , "/" , "qwi_" , st , "_" , grp , "_f_" , geo , "_" , ind , "_" , own , "_u" , ".csv" ) )) {
  
    url <- paste0( "https://lehd.ces.census.gov/data/qwi/" ,version , "/" , st , "/" , file )
    
    download.file(url = url , destfile = paste0( zip , "/" , file ) )  
    
    gunzip( file = paste0( zip , "/" , file ) )
    
  }

}

# apply the function over grid of endpoints
mapply( getqwi, grid[[1]] , grid[[2]] , grid[[3]] , grid[[4]] , grid[[5]] )

