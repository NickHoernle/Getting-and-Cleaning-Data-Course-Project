<h1>Getting and Cleaning Data Course Project</h1>

This project contains the submission for the "Coursera Getting and Cleaning Data Course Project". 

<b>Note:</b> to allow this script to function, the "AbsolutePathNameToDirectory" variable needs to be set to the same directors as "run_analysis.R" is found. This variable can be found at line 20 of the code.

<b>The driver script 'run_analysis.R' executes the following steps:</b>
<ol>
    <li>Checks to find a "./data" folder in the directory and if it does not exist it creates one. It also downloads and unzips the smartphone into this directory.</li> 
	<li>Loads all sub-files within this directory into memory.</li>
	<li>Merges the training and the test sets to create one data set.</li>
	<li>Extracts only the measurements on the mean and standard deviation for each measurement.</li>
	<li>Uses descriptive activity names to name the activities in the data set.</li>
	<li>Appropriately labels the data set with descriptive variable names.</li>
	<li>From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.</li>
</ol>