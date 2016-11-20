#Download data files
download.file(destfile="./source.zip", "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip") #Download data files in zip
unzip("./source.zip", exdir="./source") #Unzip download zip file to access data files

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
colnames(ytest)<-c("Activity") #Name activity column semantically
subj_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE) #Read subject data
colnames(subj_test)<-c("Subject") #Name subject column semantically
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt") #Read activity labels
colnames(activity_labels)<-c("Activity_Key", "Activity_Label") #Name activity columns for labelling semantically

#Merge train and test files
train<-cbind(ytrain,subj_train,xtrain) #combine y-train with x-train
test<-cbind(ytest,subj_test,xtest) #combine y-test with x-test

#Append train and test files and label, since the have the same structure
traintest<-rbind(train,test) #Append datasets since structurally the same
tt_nodup<-traintest[,!duplicated(colnames(traintest))] #Deduplicate columns
tt_nodup_label<-merge(tt_nodup,activity_labels,by.x="Activity", by.y="Activity_Key", all=TRUE) #Join activity labels based on activity keys

#Select only Mean and Std Deviation variables and labels for subject and activity
tt_final<-select(tt_nodup_label, grep("Mean|Std|Subject|Activity_Label", names(tt_nodup_label), ignore.case=TRUE)) #Only extract mean or std values
tt_final_agg<-aggregate(tt_final, list(tt_final$Subject, tt_final$Activity_Label), FUN = "mean") #Aggregate by Subject and Activity with mean function
tt_final_agg_clean<- select(rename(tt_final_agg, Subject_No=Group.1, Activity=Group.2), -c(Subject, Activity_Label)) #Rename and reduce columns

#Write results to CSV file
write.table(tt_final_agg_clean, file="./test_train_aggregated.csv", row.name=FALSE)
