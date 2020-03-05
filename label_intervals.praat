# Title: Label, divide, and save parts of sociolinguistic interview
# Compiled by: Phillip Weirich
# Date: 6 June 2019
#
# Note: This script incorporates code from a number of other scripts
#       I've used before plus a lot of the script label_from_text_file
#		by Mietta Lennes.
#
# Usage: All of the sound files and textgrids should be in the same
#			directory as this script. The file with the labels should 
#			end with a blank line. Why? I don't know, but if there isn't
#			a blank line the final interval doesn't get labeled.
#
#####################################################################
#####################################################################




# Define some variables and change as appropriate

sound_file_extension$ = ".wav"    ; Change these if the extensions are different
textGrid_file_extension$ = ".TextGrid" ; 
label_list$ = "labels.txt"
tier = 1 ; which tier has the intervals?
starting_interval = 1 ; which interval to start on
overwrite = 1 ; Change if you want to overwrite existing labels in the interval (besides 'xxx')

#Go through files in a directory and count them 
Create Strings as file list: "list", "*'sound_file_extension$'"
numberOfFiles = Get number of strings

# Open each file, one at a time
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'fileName$'
	soundname$ = selected$ ("Sound", 1)

	# Open a TextGrid by the same name:
	gridlabel$ = "'soundname$''textGrid_file_extension$'"
	if fileReadable (gridlabel$)
		Read from file... 'gridlabel$'

	# Check that the TextGrid has enough segments
		if fileReadable (label_list$)
		numberOfIntervals = Get number of intervals... tier
			if starting_interval > numberOfIntervals
			exit There are not that many intervals in the IntervalTier!
			endif
		leftoverlength = 0
		
		# Read the text file and put it to the string label$
		label$ < 'label_list$'
		if label$ = ""
			exit The text file is empty.
		endif

		filelength = length (label$)
		leftover$ = label$
		
		# Loop through intervals from the selected interval on:
		for interval from starting_interval to numberOfIntervals
		oldlabel$ = Get label of interval... tier interval
		
		if oldlabel$ <> "xxx"
		
		# Here we read a line from the text file and put it to newlabel$:
			firstnewline = index (leftover$, newline$)
			newlabel$ = left$ (leftover$, (firstnewline - 1))
			leftoverlength = length (leftover$)
			leftover$ = right$ (leftover$, (leftoverlength - firstnewline))

		# Then we check if the interval label is empty. If it is or if we decided to overwrite, 
		# we add the new label we collected from the text file:
    		if overwrite = 1
		      	Set interval text... tier interval 'newlabel$'
			elsif oldlabel$ = ""
		      Set interval text... tier interval 'newlabel$'
			else 
					exit Stopped labeling, will not overwrite old labels!
   			endif
		endif

		endfor
	else 
		exit The label text file 'label_list$' does not exist where it should!
	endif

# Save the labeled textgrid
		selectObject: "TextGrid 'soundname$'"
		Save as text file: gridlabel$

		# remove the sound and TextGrid
		selectObject: "Sound 'soundname$'"
		plusObject: "TextGrid 'soundname$'"
		Remove

# End the for loop that opens each individual pairs of Sound and TextGrid
endfor	

echo 'numberOfFiles' files have finished processing