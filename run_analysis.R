# Get the data

# Download the file and put the file in the data folder

if (!file.exists("./UCI HAR Dataset")){dir.create("./UCI HAR Dataset")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./UCI HAR Dataset/Dataset.zip", method = "libcurl")

# Unzip the file

unzip(zipfile = "./UCI HAR Dataset/Dataset.zip", exdir = "./UCI HAR Dataset")

# Unzipped files are in the folderUCI HAR Dataset. Get the list of the files

path_Dataset <- file.path("./UCI HAR Dataset" , "UCI HAR Dataset")
files <- list.files(path_Dataset, recursive = TRUE)
files

# Read data from the files into the variables

FeaturesTest <- read.table("./test/X_test.txt", header = FALSE)
FeaturesTrain <- read.table("./train/X_train.txt", header = FALSE)
ActivityTest <- read.table("./test/y_test.txt", header = FALSE)
ActivityTrain <- read.table("./train/y_train.txt", header = FALSE)
SubjectTest    <-read.table("./test/subject_test.txt", header=FALSE)
SubjectTrain    <-read.table("./train/subject_train.txt", header=FALSE)

# Merges the training and the test sets to create one data set

subject <- rbind(SubjectTest, SubjectTrain)
activity <- rbind(ActivityTest, ActivityTrain)
features <- rbind(FeaturesTest, FeaturesTrain)
names(subject)<-c("subjectID")
featuresNames <- read.table(file.path(path_Dataset, "features.txt"),head=FALSE)
names(features)<-featuresNames$V2
names(activity)<-c("activityID")
combineData<- cbind(subject, activity)
FinalData <- cbind(features, combineData)

#Extracts only the measurements on the mean and standard deviation for each measurement

subfeaturesNames<-featuresNames$V2 [grep("mean\\(\\) | std\\(\\)", featuresNames$V2)]
selectedNames<-c(as.character(subfeaturesNames), "subjectID", "activityID" )
Data<-subset(FinalData,select=selectedNames)

# Uses descriptive activity names to name the activities in the data set

activity.labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.labels <- as.character(activity.labels[,2])
Data$activityID <- activity.labels[Data$activityID]
names(FinalData) <- gsub("^t", "time", names(FinalData))
names(FinalData) <- gsub("^f", "frequency", names(FinalData))
names(FinalData) <- gsub("Acc", "Accelerometer", names(FinalData))
names(FinalData) <- gsub("Gyro", "Gyroscope", names(FinalData))
names(FinalData)<-gsub("Mag", "Magnitude", names(FinalData))
names(FinalData)<-gsub("BodyBody", "Body", names(FinalData))

# Apply descriptive variable names to test labels

ActivityTest <- mutate(ActivityTest, activity = gsub("1","Walking",V1))[2]
ActivityTest <- mutate(ActivityTest, activity = gsub("2","Walking_Upstairs",activity))
ActivityTest <- mutate(ActivityTest, activity = gsub("3","Walking_Downstairs",activity))
ActivityTest <- mutate(ActivityTest, activity = gsub("4","Sitting",activity))
ActivityTest <- mutate(ActivityTest, activity = gsub("5","Standing",activity))
ActivityTest <- mutate(ActivityTest, activity = gsub("6","Laying",activity))

# Apply descriptive variable names to train labels

ActivityTrain <- mutate(ActivityTrain, activity = gsub("1","Walking",V1))[2]
ActivityTrain <- mutate(ActivityTrain, activity = gsub("2","Walking_Upstairs",activity))
ActivityTrain <- mutate(ActivityTrain, activity = gsub("3","Walking_Downstairs",activity))
ActivityTrain <- mutate(ActivityTrain, activity = gsub("4","Sitting",activity))
ActivityTrain <- mutate(ActivityTrain, activity = gsub("5","Standing",activity))
ActivityTrain <- mutate(ActivityTrain, activity = gsub("6","Laying",activity))


# Creates a second,independent tidy data set and ouput it

library(plyr);
Data2<-aggregate(. ~subjectID + activityID, FinalData, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
Data2
