# Code Book

Data processing is in the form of script not function.
All directories are relative to working directory.
Source data files names are hardcoded.

## Variables
Following variables are used

### Variable  *sourceURL*
Variable Value      : "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Variable Description: url with location of source dataset

### *localFile*
Variable Value      : "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Variable Description: name of local file where source dataset is downloaded

### *baseDir*
Variable Value      : "./UCI HAR Dataset"
Variable Description: Data are downloaded and unpacked in this directory

### *testDir*
Variable Value      : paste(baseDir,"/","test",sep="")
Variable Description: subdirectory where source *test* data files are located

### *trainDir*
Variable Value      : paste(baseDir,"/","train",sep="")
Variable Description: subdirectory where source *training* data files are located

### *tidyFile*
Variable Value      : "./tidy.csv"
Variable Description: Output file with independent tidy dataset where features are averaged by activity and subject

### *featuresMappingFile*
Variable Value      : "./features_mapping.csv"
Variable Description: Output file 

### *activityLabels*
Variable Value      : Content of source file activity_labels.txt
Variable Description: 2 columns: activityID , activityLabel
Created	by			: activityLabels <- read.csv(paste(baseDir,"/","activity_labels.txt",sep=""),header=FALSE,sep=" ")
					  colnames(activityLabels)<-c("activityID","activityLabel")

### *features*
Variable Value      : Content of source file 'features.txt'
Variable Description: List of all features - (561 column names for 'train/X_train.txt' and 'test/X_test.txt')
Created	by			: features <- read.csv(paste(baseDir,"features.txt",sep="/"),header=FALSE,sep=" ")
					: colnames(features)<-c("colID","colName")

### *features2*
Variable Value      : renamed features (561 column names for 'train/X_train.txt' and 'test/X_test.txt')
Variable Description: characters '(' and ')' removed, characters ',' and '-' replaced with '.'
Created	by			: see Transformations

### *features_mapping*
Variable Value      : One to one mapping between renamed feature name from features2  and original feature name from features
Variable Description: 2 columns - featureName from features2  origFeatureName from features
                    : stored as output file 'features_mapping.csv'
Created	by			: see Transformations

### *features_columns*
Variable Value      : subset of features2 - used to select interesting features for output objects
Variable Description: contains only features with 'mean' or 'std' in the name
Created	by			: see Transformations

### *sub_test*
Variable Value      : Content of source file 'test/subject_test.txt' One column subjectID
Variable Description: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
Created	by			: sub_test <- read.csv(paste(testDir,"subject_test.txt",sep="/"),header=FALSE,sep=" ")
					  colnames(sub_test) <- c("subjectID")

### *y_test*
Variable Value      : Content of source file 'test/y_test.txt': Test labels.
Variable Description: one column activityID coresponding to column with the same name in activityLabels
Created	by			: y_test <- read.csv(paste(testDir,"y_test.txt",sep="/"),header=FALSE,sep=" ")
					  colnames(y_test) <- c("activityID")


### *X_test*
Variable Value      : Content of source file 'test/X_test.txt': Test set.
Variable Description: 561 column with features
Created	by			: X_test <- read.table(paste(testDir,"X_test.txt",sep="/"),col.names=features2$colName)

### *test*
Variable Value      : merged test data
Variable Description: contains sub_test$subjectID , y_test$activityID, activilyLabels$activityLabel and subset of interesting features from X_test selected by features_columns
Created	by			: see Transformations

### *sub_train*
Variable Value      : Content of source file 'train/subject_train.txt' One column subjectID
Variable Description:  Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
Created	by			: sub_train <- read.csv(paste(trainDir,"subject_train.txt",sep="/"),header=FALSE,sep=" ",col.names=c("subjectID"))

### *y_train*
Variable Value      : Content of source file 'train/y_train.txt': Test labels.
Variable Description: one column activityID coresponding to column with the same name in activityLabels
Created	by			: y_train <- read.csv(paste(trainDir,"y_train.txt",sep="/"),header=FALSE,sep=" ",col.name=c("activityID"))

### *X_train*
Variable Value      : Content of source file 'train/X_train.txt': Test set.
Variable Description: 561 column with features
Created	by			: X_train <- read.table(paste(trainDir,"X_train.txt",sep="/"),col.names=features2$colName)

### *train*
Variable Value      : merged train data
Variable Description: contains sub_train$subjectID , y_train$activityID, activilyLabels$activityLabel and subset of interesting features from X_test selected by features_columns
Created	by			: see Transformations

### *data*
Variable Value      : test and train data
Variable Description: contains subjectID , activityID, activityLabel and subset of interesting features selected by features_columns
                    : This is "tidy" dataset
Created	by			: see Transformations

### *data2*
Variable Value      : data converted to table  using tbl_df()
Variable Description: contains subjectID , activityID, activityLabel and subset of interesting features selected by features_columns
Created	by			: see Transformations


### *sum_data*
Variable Value      : independent tidy data set with the average of each variable for each activity and each subject.
Variable Description: contains subjectID , activityID, activityLabel and subset of interesting features selected by features_columns
Created	by			: see Transformations

## Transformations

### features2
Original feature names contain characters '(',')','-','.'  which are removed in features2
gsub() function from library *stringr* is used to in order to remove characters '(' and ')' and to replace '-' and ',' with '.'
	features2$colName<-gsub('[(]','',features2$colName)
	features2$colName<-gsub('[)]','',features2$colName)
	features2$colName<-gsub('[,]','.',features2$colName)
	features2$colName<-gsub('[-]','.',features2$colName)

### features_columns
from all features2 names only names which contain 'mean' or 'std' in feature name are selected.
Function grep() from library *stringr* is used
features_columns<- grep("mean|std",features2$colName,ignore.case=TRUE,value=TRUE)

### test
This object is created by binding columns of sub_test and y_test in first step
	test <- cbind( sub_test , y_test )
resulting object contains 2 columns: subjectID, activityID 
After this operation activityLabel column is merged by 'activityID' using equivalend of sql 'left outer join'
	test <- merge(test,activityLabels, by="activityID",all.x=TRUE)
resulting object contains 3 columns: subjectID, activityID, activityLabel
As last step "interesting" measurements from X_test are added using column bind. Where "interesting" feature contains 'mean' or 'std' in feature name.
	test <- cbind(test, X_test[ , c(features_columns)])

### train
Operations are the same as for 'test' object
This object is created by binding columns of sub_train and y_train in first step
	train <- cbind(  sub_train, y_train )
resulting object contains 2 columns: subjectID, activityID 
After this operation activityLabel column is merged by 'activityID' using equivalend of sql 'left outer join'
	train <- merge(train,activityLabels, by="activityID",all.x=TRUE)
resulting object contains 3 columns: subjectID, activityID, activityLabel
As last step "interesting" measurements from X_test are added using column bind. Where "interesting" feature contains 'mean' or 'std' in feature name.
	train <- cbind(train, X_train[ , c(features_columns)])
	
### data
Rows from object train are appended after rows from object test
data <- rbind(test,train)
This is merged "tidy" dataset.

### sum_data
From tidy dataset *data* independent dataset with values averaged by activity and subject is created.
Functions from library dplyr are used.
As first step  object data is converted into table *data2*
	data2 <- tbl_df(data)
In next step data are grouped by subjectID,activityID,activityLabel
	sum_data <-  data2 %>% \
				group_by(activityID,subjectID,activityLabel) %>% \
				summarise_each(funs(mean))			 
Info:  activityID and activityLabel are related one to one.
       grouping using both as key columns gives the same result as grouping by activityID only.
       activityLabel is added to the grouping key because key columns are always excluded from aggregation functions used in summarise_each()	   


##  Output objects
### features_mapping dataset and file 'features_mapping.csv'
This object contains mapping from "tidy" feature names to features names from the source ('features.txt')
Two columns are present:
	* featureName - "tidy" feature name
	* origFeatureName - original feature name from 'features.txt'
	
### Tidy dataset *data*
This dataset contains merged test and train source data and only "interesting columns" with features containing 'mean' or 'std' in the feature name
See http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones for more information.

### Tidy dataset *sum_data* and file 'tidy.csv'
This dataset contains average of each variable for each activity and each subject from *data* aggregated by subjectID,activityID,activityLabel
Feature names are the same as in *data*
This dataset is written to the file 'tidy.csv' using 

                    
					




					

					  
