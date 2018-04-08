##be sure to set working directory 

library(dplyr)
library(readr)

# Base data
activities <- read.delim("activity_labels.txt", header = FALSE, sep = "", col.names = c("ActivityId", "ActivityName"))
features <- read.delim("features.txt", header = FALSE, sep = "", col.names = c("FeatureId", "FeatureName"), stringsAsFactors = FALSE)

# Load training set
train.subjects <- read.delim("train/subject_train.txt", header = FALSE, sep = "", col.names = c("SubjectId"))
train.activities <- read.delim("train/y_train.txt", header = FALSE, sep = "", col.names = c("ActivityId"))
train.set <- read.delim("train/X_train.txt", header = FALSE, sep = "", col.names = features$FeatureName)
train.data <- tbl_df(cbind(train.subjects, train.activities, train.set))

# Load test set
test.subjects <- read.delim("test/subject_test.txt", header = FALSE, sep = "", col.names = c("SubjectId"))
test.activities <- read.delim("test/y_test.txt", header = FALSE, sep = "", col.names = c("ActivityId"))
test.set <- read.delim("test/X_test.txt", header = FALSE, sep = "", col.names = features$FeatureName)
test.data <- tbl_df(cbind(test.subjects, test.activities, test.set))

# Unify data sets and improve column names
all <- rbind(train.data, test.data)
all <- all %>% inner_join(activities)
all <- all %>% select(SubjectId, ActivityName, contains("mean.."), contains("std.."))
all <- all %>% setNames(gsub("^f", "FrequencyDomain", names(.)))
all <- all %>% setNames(gsub("^t", "TimeDomain", names(.)))
all <- all %>% setNames(gsub("Acc", "Accelerometer", names(.)))
all <- all %>% setNames(gsub("Gyro", "Gyroscope", names(.)))
all <- all %>% setNames(gsub("Mag", "Magnitude", names(.)))
all <- all %>% setNames(gsub("mean\\.\\.", "Mean", names(.)))
all <- all %>% setNames(gsub("std\\.\\.", "Std", names(.)))
all <- all %>% setNames(gsub("\\.", "", names(.)))
all <- all %>% select(-starts_with("angle"))

# Create a second, summarized data set with the mean value for each variable, grouped by subject and feature
datasummary <- all %>% group_by(SubjectId, ActivityName)
datasummary <- datasummary %>% summarize_all(funs(mean))
write.table(summary, file = "summary-avgVar-dataset.txt", row.name = FALSE)
print(summary)

##write a codebook
