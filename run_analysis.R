X_train_fileContent<-readLines('train/X_train.txt')
y_train_fileContent<-readLines('train/y_train.txt')
X_test_fileContent<-readLines('test/X_test.txt')
y_test_fileContent<-readLines('test/y_test.txt')

X_train_fileContent<-gsub('  ',' ',X_train_fileContent)
y_train_fileContent<-gsub('  ',' ',y_train_fileContent)
X_test_fileContent<-gsub('  ',' ',X_test_fileContent)
y_test_fileContent<-gsub('  ',' ',y_test_fileContent)

X_train<-read.csv(textConnection(X_train_fileContent),header = FALSE,sep = ' ')
y_train<-read.csv(textConnection(y_train_fileContent),header = FALSE,sep = ' ')
X_test<-read.csv(textConnection(X_test_fileContent),header = FALSE,sep = ' ')
y_test<-read.csv(textConnection(y_test_fileContent),header = FALSE,sep = ' ')

#Merges the training and the test sets to create one data set.
X<-rbind(X_train,X_test)
y<-rbind(y_train,y_test)

#remove NA columns
X <-X[,colSums(is.na(X))<nrow(X)]

#Appropriately labels the data set with descriptive variable names.
header_column<-as.character(read.csv('features.txt',sep = ' ')[,2])
names(X)<-header_column
names(y)<-c('activity')

#Extracts only the measurements on the mean and standard deviation for each measurement.
header_column_mean_std_indices<-grep('mean|std',header_column)
X_mean_std<-X[,header_column_mean_std_indices]
X<-X_mean_std

#Append subject columns
subjects_test<-read.csv('test/subject_test.txt',sep = ' ',header = FALSE)
subjects_train<-read.csv('train/subject_train.txt',sep = ' ',header = FALSE)
subjects<-rbind(subjects_train,subjects_test)
X$subjects<-subjects


#Add activity column to the X dataset
X$activity<-y[,1]

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
X$subjects<-X$subjects[,'V1']

activity_subjects_split<-split(X,list(X$activity,X$subjects))
activity_subjects_split_means<-lapply(activity_subjects_split,colMeans)
final <- as.data.frame(do.call("rbind", activity_subjects_split_means))

#Uses descriptive activity names to name the activities in the data set
library(plyr)
activity_label_translation<-read.csv('activity_labels.txt',sep=' ',header = FALSE)
final[,'activity']<-plyr::mapvalues(final[,'activity'],activity_label_translation[,1],as.character(activity_label_translation[,2]))

write.table(final, file = 'tidy.txt' ,row.name = FALSE)

