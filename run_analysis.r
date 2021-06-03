testSubjectPath <- "./UCI_HAR_Dataset/test/subject_test.txt"
testXPath <- "./UCI_HAR_Dataset/test/X_test.txt"
testYPath <- "./UCI_HAR_Dataset/test/Y_test.txt"
trainSubjectPath <- "./UCI_HAR_Dataset/train/subject_train.txt"
trainXPath <- "./UCI_HAR_Dataset/train/X_train.txt"
trainYPath <- "./UCI_HAR_Dataset/train/Y_train.txt"
featuresNamesPath <- "./UCI_HAR_Dataset/features.txt"

featuresNamesData <- read.table(featuresNamesPath)
featuresNames <- featuresNamesData[[2]]

testSubjectDataFrame <- read.table(testSubjectPath, col.names=c("subject"))
testXDataFrame <- read.table(testXPath, col.names=featuresNames)
testYDataFrame <- read.table(testYPath, col.names=c("y"))

trainSubjectDataFrame <- read.table(trainSubjectPath, col.names=c("subject"))
trainXDataFrame <- read.table(trainXPath, col.names=featuresNames)
trainYDataFrame <- read.table(trainYPath, col.names=c("y"))

fullSubjectDataFrame <- rbind(testSubjectDataFrame, trainSubjectDataFrame)
fullXDataFrame <- rbind(testXDataFrame, trainXDataFrame)
fullYDataFrame <- rbind(testYDataFrame, trainYDataFrame)

mergedDataFrame <- cbind(fullSubjectDataFrame, fullYDataFrame, fullXDataFrame)

filteredXDataFrame <- cbind(
  fullXDataFrame[, Reduce(`&`, list(grepl("mean", names(fullXDataFrame)), !grepl("meanFreq", names(fullXDataFrame))))],
  fullXDataFrame[, grepl("std", names(fullXDataFrame))]
)

activityLabelsPath <- "./UCI_HAR_Dataset/activity_labels.txt"
activityLabels <- read.table(activityLabelsPath, col.names=c("activity_id", "activity_description"))

namedYDataFrame <- data.frame(activity=activityLabels$activity_description[match(fullYDataFrame$y, activityLabels$activity_id)])

library(dplyr)

mergedDataFrame <- cbind(fullSubjectDataFrame, namedYDataFrame, filteredXDataFrame)

tidyDataset <- data.frame(mergedDataFrame %>% group_by(subject, activity) %>% summarise_all(funs(mean)))

write.table(tidyDataset, "tidy_dataset.txt", row.names=FALSE)
