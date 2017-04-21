## Coursera Data Science Assignment: Getting and Cleaning Data Course Project
## Submitted by Coral Peck 21 April 2017

## Objective : create one R script called run_analysis.R that does the following:
##	1) Merges the training and the test sets to create one data set.
##	2) Extracts only the measurements on the mean and standard deviation for each measurement.
##	3) Uses descriptive activity names to name the activities in the data set
##	4) Appropriately labels the data set with descriptive variable names.
##	5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## load required libraries
library(sqldf)
library(dplyr)

## Download and unzip raw data files
## Change directory in R to the folder for Coursera work first
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, dest="HPdata.zip")
unzip ("HPdata.zip")


## I have executed objectives 1 to 4 in the following 5 steps:
## 1to4_1) Identify which are mean and std dev columns from features.txt file, store into statsnamesfiltered
## meanfreq was excluded as the statistics measures required were just mean and std dev.

statsnames <- read.table ("./UCI HAR Dataset/features.txt", header = FALSE,stringsAsFactors=FALSE)
statsnamescol <- grep("-mean\\(\\)|-std\\(\\)", statsnames$V2) 
statsnamesfiltered <- statsnames[statsnamescol,2]


## 1to4_2) Generate Statistics sub table with only columns containing mean and std dev from step 1.1 above for both test and train
## Also named the columns descriptively with names in statsnamesfiltered

statsdatatest <- read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)
statsdatatestfiltered <- statsdatatest[,statsnamescol]
names(statsdatatestfiltered)<-statsnamesfiltered 

statsdatatrain <- read.table("./UCI HAR Dataset/train/X_train.txt", header=FALSE)
statsdatatrainfiltered <- statsdatatrain[,statsnamescol]
names(statsdatatrainfiltered)<-statsnamesfiltered 

## 1to4_3) Generate Subject sub table for test and train, named column header descriptively as "Subject".

subjectdatatest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)
names(subjectdatatest) <- "Subject"

subjectdatatrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header=FALSE)
names(subjectdatatrain) <- "Subject"

## 1to4_4) Generate Activity sub table for test and train. Named column header descriptively as "ActivityCode","ActivityDesc".
activitylabel <- read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE, stringsAsFactors=FALSE)

activitydatatest <- read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE)
activitydatatestfinal<- sqldf("SELECT * from activitydatatest JOIN activitylabel USING(V1)")
names(activitydatatestfinal) <- c("ActivityCode","ActivityDesc")

activitydatatrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header=FALSE)
activitydatatrainfinal<- sqldf("SELECT * from activitydatatrain JOIN activitylabel USING(V1)")
names(activitydatatrainfinal) <- c("ActivityCode","ActivityDesc")

## 1to4_5) Generate Combined table (Subject, Activity, Statistics) for test and train respectively
combinedtestdata<-cbind(subjectdatatest,activitydatatestfinal,statsdatatestfiltered)
combinedtraindata<-cbind(subjectdatatrain,activitydatatrainfinal,statsdatatrainfiltered)


## 2) Merge the combined table into 1
combineddata <- rbind(combinedtestdata, combinedtraindata)
combineddata <- combineddata[,colnames(combineddata)!='ActivityCode']

## 3) Summarise combined data
combineddata_summary <- combineddata %>%
group_by(Subject,ActivityDesc) %>%
summarise_all(mean)

## 4) Export combineddata_summary 
write.table(combineddata_summary, file = "tidydata.txt")

