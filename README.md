# GettingAndCleaningData
This respository contains the program run_Analysis.R as a solution for the course programming assignment for Getting and Cleaning Data. The assignment is described as follows:

# Assignment Instructions

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
Review criterialess 
The submitted data set is tidy.
The Github repo contains the required scripts.
GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
The README that explains the analysis files is clear and understandable.
The work submitted for this project is the work of the student who submitted it.
Getting and Cleaning Data Course Projectless 
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

 - Merges the training and the test sets to create one data set.
 - Extracts only the measurements on the mean and standard deviation for each measurement.
 - Uses descriptive activity names to name the activities in the data set
 - Appropriately labels the data set with descriptive variable names.
 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each    subject.

# Solution submission

## Download the data and unzip
Since data preparation needs to be transparent from the original unchanged data to the final tidy dataset, the download and extraction from the original source is part of the analysis R-script:

```R
#Download data files
download.file(destfile="./source.zip", "https://d396qusza40orc.cloudfront.net/
getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip") #Download data files in zip
unzip("./source.zip", exdir="./source") #Unzip download zip file to access data files
```
## Read and label raw data files
Read raw data files and combine the training data and the test data to separate datasets with labeling and same structure:

```R
#Read features descriptions for column labeling
features<-read.table("./UCI HAR Dataset/features.txt", header=FALSE)

#Read training data files and assign column names
xtrain<-read.fwf("./UCI HAR Dataset/train/X_train.txt", widths=rep(16,561)) #Read x-train data
colnames(xtrain)<-features$V2 #Name columns based on features.txt
ytrain<-read.table("./UCI HAR Dataset/train/y_train.txt", header=FALSE) #Read y-train data
colnames(ytrain)<-c("Activity")
subj_train<-read.table("./UCI HAR Dataset/train/subject_train.txt", header=FALSE)
colnames(subj_train)<-c("Subject")

#Read test data files and assign column names
xtest<-read.fwf("./UCI HAR Dataset/test/X_test.txt", widths=rep(16,561)) #Read x-test data
colnames(xtest)<-features$V2 #Name columns based on features.txt
ytest<-read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE) #Read y-test data
colnames(ytest)<-c("Activity")
subj_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)
colnames(subj_test)<-c("Subject")
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(activity_labels)<-c("Activity_Key", "Activity_Label")

#Merge train and test files
train<-cbind(ytrain,subj_train,xtrain) #combine y-train with x-train
test<-cbind(ytest,subj_test,xtest) #combine y-test with x-test
```
## Append train and test data and label
Append train and test data since they have the same structure and reduce to mean and standard deviation features:

```R
#Append train and test files and label, since the have the same structure
traintest<-rbind(train,test) #Append datasets since structurally the same
tt_nodup<-traintest[,!duplicated(colnames(traintest))] #Deduplicate columns
tt_nodup_label<-merge(tt_nodup,activity_labels,by.x="Activity", by.y="Activity_Key", all=TRUE)
```
## Reduce data to mean and standard deviation and aggregate
Reduce width of data set to only subject and activity info as well as mean and standard deviation features and aggregate by subject and activity, using the mean function:

```R
#Select only Mean and Std Deviation variables and labels for subject and activity
tt_final<-select(tt_nodup_label, grep("Mean|Std|Subject|Activity_Label", names(tt_nodup_label), 
ignore.case=TRUE)) #Only extract mean or std values
tt_final_agg<-aggregate(tt_final, list(tt_final$Subject, tt_final$Activity_Label), 
FUN = "mean") #Aggregate by Subject and Activity with mean function
tt_final_agg_clean<- select(rename(tt_final_agg, Subject_No=Group.1, Activity=Group.2), 
-c(Subject, Activity_Label)) #Rename and reduce columns
```

## Write aggregated table for submission
Write csv file as final submission:

```R
#Write results to CSV file
write.table(tt_final_agg_clean, file="./test_train_aggregated.csv", row.name=FALSE)
```
