##===================================================================================##

# Coursera Getting and Cleaning Data Course Project
# Nicholas Hoernle
# 2015/11/18

# Driver file: run_analysis.R

# Data can be found at: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# Script does the following:
# Part 1: Merge the training and the test sets to create one data set.
# Part 2: Extract only the measurements on the mean and standard deviation for each measurement. 
# Part 3: Uses descriptive activity names to name the activities in the data set
# Part 4: Appropriately labels the data set with descriptive variable names. 
# Part 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##===================================================================================##
# NOTE: This path needs to be set to the working directory of this project
AbsolutePathNameToDirectory <- "F:/Development/R/GettingAndCleaningData/Getting-and-Cleaning-Data-Course-Project";
##===================================================================================##

# Set the working directory
setwd( AbsolutePathNameToDirectory );

# Remove everything else from workspace
rm(list=ls())

##imports
library( data.table );


##===================================================================================##
# Part 0: Load the data into memory

if ( !file.exists("UCI HAR Dataset")) {
    print("Downloading dataset")
    download.file( url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                   destfile = "temp.zip"
    )
    unzip( "temp.zip" )
    file.remove("temp.zip")
}

# Helper function to read all subfiles within a directors into memory named by the 
# name of the subfile
readInputData   <- function( inputDirectory ) {
    listOfFiles <- list.files( inputDirectory, recursive=TRUE )
    index       <- 0;
    output      <- list();
    for ( f in listOfFiles ){
        extention = basename(inputDirectory);
        # use the important part of the file name to call the data something sensible
        fileName <- gsub( 
            paste("_",extention, ".txt",sep="")
            ,"", basename( f ) 
        )
        # get the data and store under the correct label in a list of data.tables
        output[[fileName]] = fread( 
            paste( inputDirectory , f , sep = "/" ) 
        )
    }
    output
}

# Open the UCI HAR Dataset get the directory names:
# Read the features.txt and activity_labels.txt list
features <- fread(file.path("UCI HAR Dataset", "features.txt"))
activityLabels <- fread(file.path("UCI HAR Dataset", "activity_labels.txt"))

# store the test and train statsets in a variable in memory
test    <- readInputData('./UCI HAR Dataset/test')
train   <- readInputData('./UCI HAR Dataset/train')


##===================================================================================##
# Part 1: Merge the training and the test sets to create one data set.

setnames( test$X , features$V2 )
setnames( train$X, features$V2 )

data   <-  rbindlist( list( cbind( train$X , "activity" = train$y, "subject" = train$subject ) , 
                              cbind( test$X, "activity" = test$y, "subject" = test$subject) 
                        ) )



##===================================================================================##
# Part 2: Extract only the measurements on the mean and standard deviation for each measurement. 

# Find all references to mean and std and keep those columns
columnsToKeep <- (
                    grepl("mean", colnames( data ) ) |
                    grepl("std", colnames( data ) ) |
                    grepl("activity", colnames( data ) ) | # also keep the output column
                    grepl("subject", colnames( data ) ) # also keep the subject label column
                )


part2   <- copy( data[ , columnsToKeep , with = FALSE] )


##===================================================================================##
# Part 3: Uses descriptive activity names to name the activities in the data set
part2$activity.V1 <- factor(part2$activity.V1, 
                     levels = c(1,2,3,4,5,6),
                     labels = c( "Walking", "WalkingUpstairs" , 
                                 "WalkingDownstairs", "Sitting", 
                                 "Standing", "Laying" ) )

##===================================================================================##
# Part 4: Appropriately label the data set with descriptive variable names.
invisible( lapply( colnames( part2 ) , 
     function(x){
         new <- gsub( pattern =  "\\()", replacement =  "", x = x ) 
         new <- gsub( pattern =  "^(f)", replacement = "FrequencyDomain-", x = new ) 
         new <- gsub( pattern =  "^(t)", replacement = "TimeDomain-", x = new )
         new <- gsub( pattern =  "mean", replacement = "Mean", x = new )
         new <- gsub( pattern =  "std", replacement = "StandardDeviation", x = new )
         new <- gsub( pattern =  "Acc", replacement = "Acceleration", x = new )
         new <- gsub( pattern =  "Mag", replacement = "Magnitude", x = new )
         setnames( part2 , old = x , new = new )
     }
))

#colnames(part2)[colnames(part2) == "activity.V1"] <- "Activity"
#colnames(part2)[colnames(part2) == "subject.V1"] <- "Subject"
setnames( part2 , old = "activity.V1" , new = "Activity" )
setnames( part2 , old = "subject.V1"  , new = "Subject" )

##===================================================================================##
# Part 5: From the data set in step 4, creates a second, independent tidy data set with 
# the average of each variable for each activity and each subject.

part5 <- aggregate(part2[ , !( colnames(part2) %in% c('Activity','Subject') ), with = FALSE ],
                   by=list(Subject = part2$Subject,
                           Activity=part2$Activity)
                   ,mean);

# Save part5 to disk 
write.table(part5, "./courseProjectOutput.txt", col.names =TRUE, row.names = FALSE )

