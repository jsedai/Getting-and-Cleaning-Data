##########################################################################################################
# The following script performs the following tasks
# on the UCI HAR Dataset downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement.
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names.
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##########################################################################################################

#Download and unzip data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", dest="dataset.zip", mode="wb");
unzip ("./dataset.zip");


# Read and import training and test data from files
activityLabel = read.table('UCI HAR Dataset/activity_labels.txt',header=FALSE); 
colnames(activityLabel)  = c('activityId','activityLabel');
features     = read.table('UCI HAR Dataset/features.txt',header=FALSE); 
subjectTrain = read.table('UCI HAR Dataset/train/subject_train.txt',header=FALSE); 
colnames(subjectTrain)  = "subjectId";
xTrain       = read.table('UCI HAR Dataset/train/x_train.txt',header=FALSE); 
colnames(xTrain)        = features[,2]; 
yTrain       = read.table('UCI HAR Dataset/train/y_train.txt',header=FALSE); 
colnames(yTrain)        = "activityId";
subjectTest = read.table('UCI HAR Dataset/test/subject_test.txt',header=FALSE);
colnames(subjectTest) = "subjectId";
xTest       = read.table('UCI HAR Dataset/test/x_test.txt',header=FALSE); 
colnames(xTest)       = features[,2]; 
yTest       = read.table('UCI HAR Dataset/test/y_test.txt',header=FALSE); 
colnames(yTest)       = "activityId";
allData = rbind(cbind(yTrain,subjectTrain,xTrain),cbind(yTest,subjectTest,xTest));
colNames  = colnames(allData); 
# Combine training and test data
allData = merge(allData[(grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames))==TRUE],activityLabel,by='activityId',all.x=TRUE);

colNames  = colnames(allData); 
for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
};
colnames(allData) = colNames;

#prepare tidy data

tidyData    = merge(aggregate(allData[,names(allData) != 'activityLabel'][,names(allData[,names(allData) != 'activityLabel']) != c('activityId','subjectId')],by=list(activityId=allData[,names(allData) != 'activityLabel']$activityId,subjectId = allData[,names(allData) != 'activityLabel']$subjectId),mean)
                    ,activityLabel,by='activityId',all.x=TRUE);

# Export the tidyData set 
write.table(tidyData, './tidyData.txt',row.names=FALSE,sep=',');
