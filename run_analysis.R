## Download the file
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file (url, "UCI HAR DATASET")
## unzip file , extract to new directory "UCI HAR DATASET"
unzip("UCI HAR DATASET", exdir = "UCI HAR DATASET")
## set working directory
setwd("/Users/constantinoslirigos/Dropbox/COURSERA/R Working Directory/UCI HAR DATASET")

## load required packages 
library(dplyr)
library(plyr)
library(reshape2)

## read the 3 test files and cbind them to one named "test"
## 1st column is subjects, 2nd is activity and then all 561 variables
X_test <- read.table("./test/X_test.txt")
subject_test <- read.table("./test/subject_test.txt")
y_test <- read.table("./test/y_test.txt")
test <- cbind(subject_test, y_test, X_test)

## read the 3 train files and cbind them to one named "train"
## 1st column is subjects, 2nd is activity and then all 561 variables
X_train <- read.table("./train/X_train.txt")
subject_train <- read.table("./train/subject_train.txt")
y_train <- read.table("./train/y_train.txt")
train <- cbind(subject_train, y_train, X_train)

## read the activity labels
Activity <- read.table("activity_labels.txt")

## join the "test" and "train" files with rbind and create a new file "data" with all the data
data <- rbind(test, train)
## convert the first 2 collumns (subjects, activity) into factors
data[,1] <- as.factor(data[,1])
data[,2] <- as.factor(data[,2])

## subset the features, choosing only these that are "mean" or "std"
## read the file "features.txt"
features <- read.table("features.txt", stringsAsFactors = FALSE)
## subset for "Mean", "mean", "Std", "std"
features1 <- features[grep("[M,m]ean|[S,s]td", features$V2), ]
## convert the 1st collumn to character
features1$V1 <- as.character(features1$V1)
## Add the letter "V" in fron of every number
## now we have a file "feature1" with the 2nd collumnn having all variables (with full name) that are "mean" or "std"
## and 1st collumn the corresponding number (with letter V in front)
features1$V1 <- sub("^", "V", features1$V1)

## rename the first 2 collumns of file "data" as "Subjects", "Activity"
names(data)[1] <- "Subjects"
names(data)[2] <- "Activity"

## create the new file data1 which:
## has the first 2 collumns "Subjects" and "Activity"
## has as the rest of the collumns all collumns that have the same name as the first collumn 
## of vector "feature1$V1"
data1 <- cbind(data[,1:2], select(data, one_of(features1$V1)))

## rename collumns 3 to 88 of "data1". 
## Give them the full names of the variable, as per collumn 2 of "feature1"
names(data1)[3:88] <- features1$V2

## rename the factor "Activity" from levels 1:6 to proper names taken from file "activity_labels.txt"
data1$Activity <- factor(data1$Activity, levels = c(1:6), labels = Activity$V2)

## make a tall table, keeping variables "Subjects", "Activity" and calculating the means
## and then make a wide table again, with functions melt and dcast
## the new wide table is "tidy_data"
tidy_data <- dcast(melt(data1), Subjects + Activity ~ variable, mean)
## write the new table to "tidy_data.txt"
write.table(tidy_data, file = "tidy_data.txt", row.names = FALSE, quote = FALSE)
