# Data cleaning for Coursera's getdata-014 course

This project contains code and documentation for data cleaning script in R.

## Data Source
The data linked to represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Project content

This project contains following files:
* **run_analysis.R** - script which download and process dataset producing 3 objects:
	* data - dataset with merged test & train data (only features with 'mean' or 'std' in feature name
	* sum_data - summarized data with average of each feature from object data aggregated for each activity&subject
	* features_mapping - mapping for features names from names used in 2 objects above to original features names from source data set
* **CodeBook.md** - describes the variables, the data, and transformations
* **tidy.csv** - independent tidy data set with the average of each variable for each activity and each subject.
* **features_mapping.csv** - features_mapping writtent to csv file with header  (this helps to find full description of feture in original Codebook)

# libraries used
This project is using library *stringr* from cleaning features names
and library *dplyr* for data aggregation