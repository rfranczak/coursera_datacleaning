##
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
##
## Here are the data for the project:
##
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## 
## You should create one R script called run_analysis.R that does the following. 
##
## 1    Merges the training and the test sets to create one data set.
## 2    Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3    Uses descriptive activity names to name the activities in the data set
## 4    Appropriately labels the data set with descriptive variable names. 
##
## 5    From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##
## 

library(stringr)
library(dplyr)


sourceURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localFile <- "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## data are downloaded and unpacked in directory:  ./UCI HAR Dataset/
baseDir <- "./UCI HAR Dataset"
testDir <- paste(baseDir,"/","test",sep="")
trainDir <- paste(baseDir,"/","train",sep="")
tidyFile <- "./tidy.csv"
featuresMappingFile <- "./features_mapping.csv"

## download dataset
download.file(sourceURL, dest=localFile, mode="wb")
unzip(localFile,exdir=".")

##
##  read activity labels
activityLabels <- read.csv(paste(baseDir,"/","activity_labels.txt",sep=""),header=FALSE,sep=" ")
colnames(activityLabels)<-c("activityID","activityLabel")

## read column names
##  from features.txt
features <- read.csv(paste(baseDir,"features.txt",sep="/"),header=FALSE,sep=" ")
colnames(features)<-c("colID","colName")

##  reaname column names in features  remove ',' '('  ')'  and replace '-' by '.'

features2<-features
features2$colName<-gsub('[(]','',features2$colName)
features2$colName<-gsub('[)]','',features2$colName)
features2$colName<-gsub('[,]','.',features2$colName)
features2$colName<-gsub('[-]','.',features2$colName)
# in features2 there is 561 column names 

# write mapping from our column names to original column names
features_mapping <- data.frame(featureName=features2$colName,origFeatureName=features$colName)
write.csv(features_mapping, featuresMappingFile, row.names=FALSE, quotes=FALSE)

## select mean or std columns
features_columns<- grep("mean|std",features2$colName,ignore.case=TRUE,value=TRUE)

##
## read test data files
##
#  subject data (only id in this file)
sub_test <- read.csv(paste(testDir,"subject_test.txt",sep="/"),header=FALSE,sep=" ")
colnames(sub_test) <- c("subjectID")

# activity id for each row
y_test <- read.csv(paste(testDir,"y_test.txt",sep="/"),header=FALSE,sep=" ")
colnames(y_test) <- c("activityID")

# test data file
X_test <- read.table(paste(testDir,"X_test.txt",sep="/"),col.names=features2$colName)

## merge subject data with activity labels
# one to one , I want subjectID at the beginning
test <- cbind( sub_test , y_test )

# as database "left outer join" with 6 activity labels by activityID
test <- merge(test,activityLabels, by="activityID",all.x=TRUE)

# add measurements for all std|mean columns 
test <- cbind(test, X_test[ , c(features_columns)])

##
## read train data files
##
#  subject data (only id in this file)
sub_train <- read.csv(paste(trainDir,"subject_train.txt",sep="/"),header=FALSE,sep=" ",col.names=c("subjectID"))

# activity id for each row
y_train <- read.csv(paste(trainDir,"y_train.txt",sep="/"),header=FALSE,sep=" ",col.name=c("activityID"))

# train data file
X_train <- read.table(paste(trainDir,"X_train.txt",sep="/"),col.names=features2$colName)

## merge subject data with activity labels
# one to one , I want subjectID at the beginning
train <- cbind(  sub_train, y_train )

# as database "left outer join" with 6 activity labels by activityID
train <- merge(train,activityLabels, by="activityID",all.x=TRUE)

# add measurements for all std|mean columns 
train <- cbind(train, X_train[ , c(features_columns)])

## merge test and train
##
# just append train data after all rows of test data 
data <- rbind(test,train)

##  create tidy dataset  with the average of each variable for each activity and each subject.
##
# convert to the table
data2 <- tbl_df(data)

## 
## grouping data by activityLabel (it is one-to-one with activityID and key columns are excluded from "funs()"
##
sum_data <-  data2 %>% \
			 group_by(activityID,subjectID,activityLabel) %>% \
			 summarise_each(funs(mean))			 

## write independent tidy dataset with summarized data
write.table(sum_data,file=tidyFile, col.names = FALSE)