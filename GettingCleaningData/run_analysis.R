####============================================================================
#### Coursera   : Data Scientist Track
#### Course:      Getting Cleaning Data
#### Week:        4
#### Assignment : CourseProject
####
#### Name: Tony Leson
#### Date: 2/14/2017
#### File: run_analysis.R
####
#### Description:
####   This file will read, clean, and analyze data from UCI HAR Datasheet.
####   
#### Functions:
####   run_analysis() :
####       Reads, cleans, and analyzes the data by doing the following steps.
####       (1) Merges the training and the test sets to create one data set.
####       (2) Extracts only the measurements on the mean and standard 
####           deviation for each measurement.
####       (3) Uses descriptive activity names to name the activities in the data set
####       (4) Appropriately labels the data set with descriptive variable names.
####       (5) From the data set in step 4, creates a second, independent tidy data 
####           set with the average of each variable for each activity and each subject.
####        
####   download_uci_data() :
####       Downloads and unzips the data into working directory.
####       This is done so the work is repeatable.
####============================================================================

##-----------------------------------------------------
## Include some libraries used by functions.
library(dplyr)
library(tidyr)


##------------------------------------------------------
## - run_analysis()
##    - Output : returns a tidy data table from the activity data
##      from UCI's data set. grouped by subject and activity with 
##      the resultant mean for each variable/feature for (mean|std)
##      measurements.
##     
##    Note1: Assumes the data from Coursera dropbox
##            downloaded and unziped into working directory.
##     
##    Note2: The steps performed in this function are
##           described in file description in header.
##------------------------------------------------------
run_analysis <- function() {
  
  #---------------------------------------------
  # Step 0: Specify some variables to simply code.
  #---------------------------------------------
  
  # some important files used for the training and 
  train_xfile  <- "UCI HAR Dataset/train/X_train.txt"
  train_rlabel <- "UCI HAR Dataset/train/subject_train.txt"
  train_yfile  <- "UCI HAR Dataset/train/y_train.txt"

  test_xfile   <- "UCI HAR Dataset/test/X_test.txt"
  test_rlabel  <- "UCI HAR Dataset/test/subject_test.txt"
  test_yfile   <- "UCI HAR Dataset/test/y_test.txt"
  

  # files with labels for all columns (name of each feature)
  xlabel_file  <- "UCI HAR Dataset/features.txt"
  
  # Output labels.
  ylabel_file  <- "UCI HAR Dataset/activity_labels.txt"
  
  # Note: for the purpose of this assignment, we do not read all rawdata 
  #        in Inertial_Signals

  
  #---------------------------------------------
  # Step 0_B: Begin by reading in data from files and merge.
  #---------------------------------------------

  # feature labels for both data sets.
  xlabels     <- read.table(xlabel_file, stringsAsFactors = FALSE)
  
  # output (activity) label keys.
  ylabels     <- read.table(ylabel_file, stringsAsFactors = FALSE)
  
  # read training data for developing machine learning algorithm.
  train_xdata <- read.table(train_xfile, stringsAsFactors = FALSE)
  train_ydata <- read.table(train_yfile, stringsAsFactors = FALSE)
  train_row   <- read.table(train_rlabel,stringsAsFactors = FALSE)
  
  # read test data to test machine learning algorithm.
  test_xdata  <- read.table(test_xfile,  stringsAsFactors = FALSE)
  test_ydata  <- read.table(test_yfile,  stringsAsFactors = FALSE)
  test_row    <- read.table(test_rlabel, stringsAsFactors = FALSE)

  
  #---------------------------------------------
  # Step 1:  Merge Data sets.
  #---------------------------------------------
  
  # Merging training data variables
  train_df <- data.frame(train_row, train_xdata, train_ydata)
  
  # Merging test data variables
  test_df  <- data.frame(test_row,  test_xdata,  test_ydata)
  
  # Merge test and training activity data.
  alldata_df <- rbind.data.frame(train_df,test_df)
  

  #---------------------------------------------
  # Step 2:  Label the variables sets (4)
  #---------------------------------------------
  
  # Name of each variable.  
  # *_row is the subject of the data sample row.
  # *_ydata is the activty recorded.
  cnames <- rbind("subject", xlabels[2], "activity")
  
  # Apply the variable names to each variable.
  colnames(alldata_df) <- cnames[[1]]  # make cnames dimensionless vector.
  
  #---------------------------------------------
  # Step 3: extract "mean" and "standart_deviations" (2)
  #---------------------------------------------
  
  # Create mean and standard deviation regex to grep colnames.
  extract_regex <- "mean|std"  
  
  # grep the colnames.
  extract_indexs <- grep(extract_regex,colnames(alldata_df))
  
  # add in the Subject and activity lines too.
  extract_indexs <- c(1, extract_indexs, length(cnames[[1]]))
  
  # Extract data 
  #  Note: (can't use "filter" due to non-unique names from xlabels)
  activity_cleandf <- alldata_df[, extract_indexs]
  
  #---------------------------------------------
  # Step 4: Use meaningful names for Activities
  #--------------------------------------------- 
  
  # adds the activity name to the data based on the activity code from ylabels.
  #
  #  1 WALKING
  #  2 WALKING_UPSTAIRS
  #  3 WALKING_DOWNSTAIRS
  #  4 SITTING
  #  5 STANDING
  #  6 LAYING
  
  activity_cleandf <- mutate(activity_cleandf,activity_name = ylabels[activity,2])
  
  #---------------------------------------------
  # Step 5: Create Tidy Data with average per variable
  #          grouped by subject and activity.
  #---------------------------------------------
  
  #using the dplyr package functions. to get mean for each.
  activity_tidydf <- activity_cleandf %>%
                     group_by(subject,activity_name) %>%
                     summarise_each(funs(mean(., na.rm=TRUE)))
  
  #write table to output.
  Output_file <-  "activitydata_tidy.txt"
  write.table(activity_tidydf, Output_file, row.names=FALSE)
  
  return(activity_tidydf)
}


##------------------------------------------------------
## - download_uci_data()
##    - downloads and unzips files used as data for program.
##------------------------------------------------------
download_uci_data <- function () {
  
  filename = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  destfile = "./UCI_HAR_Dataset.zip"
  
  if(file.exists(destfile)) {
    stop(print("Output File Exists, delete first!"))
  }
    
  download.file(filename,destfile)
  unzip(destfile)
  
  
}