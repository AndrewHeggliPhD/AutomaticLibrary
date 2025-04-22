#####         Script to update the library daily	   #####
###   "#" is used before text so R does not interpret it as  ###
###   code. To use text as code just remove "#" before the   ###
###   text                                                   ###
###   Author: Andrew Heggli, PhD.                            ###
################################################################

##  Determine where Rscipt is stored
#Rscript_path <- file.path('C:','Users',Sys.getenv('USERNAME'),
#                       'Documents','GitHub')

##  Code to run the Rscript automatically and regularly
#This code makes a scheduled task in Windows, so if the script is going
#to be run on a different PC then this part of the code needs to be run again, 
#and the task must be removed from the original PC. 
#This code is also Windows specific so if the script will be run on a Mac or Linux 
#then new code must be written specifically for those systems.
#install.packages("taskscheduleR")
#library(taskscheduleR)

#taskscheduler_create(taskname = "UpdateLibrary", rscript = file.path(Rscript_path, 'Library.R'), 
#                     schedule = "WEEKLY", starttime = "09:49",days = "MON")
#taskscheduler_delete(taskname = "LibraryUpdate")

##  Removes all objects in R
rm(list = ls())
##  Prevents scientific (exponential) notation   
options(scipen=999)
##  Load packages
packages <- c('Rtools','tidyverse','dplyr','dbplyr','tidyr','RCurl','readr','ssh','devtools')

for(pp in packages){require(pp,character.only = TRUE,quietly = FALSE)}

##  Load in package to enable sftp transferring
install.packages("devtools")
devtools::install_github("stenevang/sftp")
library("sftp")

##  Load in package to enable use of zip files
install.packages("zip")
library(zip)

##  Determine working path
Data_path <- file.path('C:','Users',Sys.getenv('USERNAME'),
                       '','','')

##  SSH login information
sftp_host <- "host"
sftp_user <- "username"
sftp_pass <- 'password'

##  Create a SSH-connection
sftp_con <- sftp::sftp_connect(server = sftp_host, username = sftp_user, password = sftp_pass, folder = "folder/placement/")

##  List files in external server
files <- sftp::sftp_list(sftp_con, type = "f") 
#listfiles <- sftp::sftp_listfiles(ssh_conn)
#listdirectories <- sftp::sftp_listdirs(ssh_conn)

##  Disconnect from server
#ssh_disconnect(ssh_conn)

##  Create list of file names in the external server 
ZipN <- sort(files$name)

##  Import name for files that are already in the library
OvAll <- scan(file.path(Data_path, 'Mappe', 'OverfortAllerede.txt'), what = character(), encoding = "UTF-8")

##  Which files are not yet transferred? 
ZipN <- ZipN[!is.element(ZipN,OvAll)]

##  For-loop to download zip files that are not yet transferred
for (ii in 1:length(ZipN)){
  
  ##  Make temporary temporary save file
  temp <- tempfile()
  
  #Download zip file:
  sftp::sftp_download(
    file = ZipN[ii],
    tofolder = temp,
    sftp_connection = sftp_con,
    verbose = TRUE,
    curl_options = list()
  )
  
  ##  Create data frame with all files in zip file
  MidltFil <- zip_list(paste(file.path(temp),list.files(file.path(temp)),sep = "\\"))
  
  ##  Retrieve all serial numbers in zip file
  Lopenr <- unique(stringr::str_sub(MidltFil$filename,1,7))
  
  ##  Make character string for all serial numbers in zip file that include .txt files
  LopenrTrue <- stringr::str_sub(MidltFil$filename[grep(".txt",MidltFil$filename)],1,7)
  
  ##  Show which serial numbers lack .txt files
  LopenrLack <- print(Lopenr[which(!is.element(Lopenr,LopenrTrue))])
  
  ##  Create data frame for serial numbers that lack .txt files
  LackDF <- as.data.frame(matrix(NA, nrow = length(LopenrLack), ncol = 4))
  
  ##  Give names to columns for the data frame with serial numbers that lack .txt files
  colnames(LackDF) <- c("Skrottnummer","Lopenummer","Slaktedato","Slakterinummer")
  
  ##  Combine serial numbers in data frame with serial numbers that lack .txt files
  LackDF[,2] <- LopenrLack
  
  ##  Create data frame for all individuals 
  BiblioDF <- as.data.frame(matrix(NA, nrow = length(LopenrTrue), ncol = 4))
  
  ##  Name the columns in the data frame that will contain all individuals
  colnames(BiblioDF) <- c("Skrottnummer","Lopenummer","Slaktedato","Slakterinummer")
  
  ##  Transfer serial numbers for individuals that have .txt files in the data frame
  BiblioDF[,2] <- LopenrTrue
  
  ##  Determine save path for zip file
  ZipLoc <- paste(file.path(temp),list.files(file.path(temp)),sep = "\\")
  
  ##  Create function to extract data
  hentdata <- function(x){
    read.delim2(unz(ZipLoc,
                    paste(x,"\\",x,"_info.txt", sep='')
    )
    )
  }
  
  ##  Transfer carcass numbers to the data frame
  BiblioDF[,1] <- gsub(".*X", '',names(sapply(LopenrTrue, hentdata))) %>%
    substr(5,10)
  
  ##  Transfer slaughter date to the data frame
  BiblioDF[,3] <- gsub(".*X", '',names(sapply(LopenrTrue, hentdata))) %>%
    substr(19,22)
  
  ##  Transfer slaughterhouse number in the data frame
  BiblioDF[,4] <- gsub(".*X", '',names(sapply(LopenrTrue, hentdata))) %>%
    substr(2,4)
  
  ##  Combine data frame for individuals that lack .txt files and individuals that have .txt files
  CombiDF <- rbind(BiblioDF,LackDF)
  
  ##  Test if library file already exists
  if (file.exists(file.path(Data_path,'Bibliotek','Bibliotek.csv'))){
    
    #Import data frame with individuals that are already in library
    PreDF <- read.csv2(file = file.path(Data_path,'Bibliotek','Bibliotek.csv'))
    
    #Combine previous and current data frame
    CombiDF <- rbind(PreDF,CombiDF)
  }
  
  ##  Export library as .csv file
  write.csv2(CombiDF, file = file.path(Data_path,'Bibliotek','Bibliotek.csv'), row.names = FALSE)
  
  ##  Create list of filenames in external server 
  OpBib <- sort(files$name)
  
  ##  Export .txt file with list of files that are already in the library
  write.table(OpBib, file = file.path(Data_path,'Bibliotek','OverfortAllerede.txt'), row.names = FALSE, col.names = FALSE)
  
  ##  Remove objects to clear memory for the PC
  rm(MidltFil, CombiDF, PreDF)
  
  ##  Clear memory
  gc()
  
  ##  Delete temporary file placement and files within
  unlink(tempdir(), recursive = T)
}
