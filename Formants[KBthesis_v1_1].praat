############################################################################
# This script goes through sound and TextGrid files in a directory,        #
# opens each pair of Sound and TextGrid, takes F1, F2 and F3 measurements, #
# as well as their bandwidths.                                             #
#                                                                          #
# Two options of measurements are possible: time normalized and time       #
# non-normalized. For time normalized, the number of time points is        #
# defined in the form.  For time non-normalized, measurements are taken    #
# for the duration of the intervals, and every how many miliseconds is     #
# defined in the form.                                                     #
#                                                                          #
# The script checks for a tier with exclusion criteria and a tier with     #
# comments, which are extracted and printed in the output. Additionally,   #
# the output includes a token counter, the label of the file, the label    #
# of the interval, the time point where measurements are taken and formant #
# settings information (maximum formant and number of formants).           #
#                                                                          #
# This script was adapted from a script originally written by              #
# Nancy J. Caplow. Modified by Silvina Bongiovanni (scbongio@indiana.edu). #
#                                                                          #                                           #
#                                                                          #
# Project-specific Modification for K. Blake Thesis                        #
# By Phillip Weirich                                                       #
# Date: 3 October 2016                                                     #
#                                                                          #
# Version Notes:                                                           #
#                                                                          #
# Version 1.0                                                              #
# 3 October 2016                                                           #
# Modified from Silvina's original compilation to include labels and       #
# and tier extraction information specific to K. Blake's thesis.           #
#                                                                          #
# Version 1.1                                                              #
# 21 October 2016                                                          #
# K. Berkson corrected typographical error that resulted in F1             #
# measurements being pasted for all formants.                              # 
#                                                                          #
#                                                                          #
############################################################################


form Extracting formant measurements
	comment Directory of sound files
	text sound_directory 
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory 
	sentence TextGrid_file_extension .TextGrid
	comment Which tier of the TextGrid object would you like to analyse?
	integer Tier_analysis 4
	comment Which tier of the TextGrid object contains the speaker info?
	integer Tier_exclusion 2
	comment Which tier of the TextGrid object contains the word label?
	integer Tier_comment 3
	comment Where do you want to save the results?
	text textfile formants.txt
	optionmenu gender 2
		option male
		option female
	optionmenu measurement_type: 1
		option time normalized
		option time nonnormalized
	comment For time normalized measurements, how many equally-distant time points?
	integer Time_points 10
	comment For time non-normalized measurements, every how many ms?
	integer Milliseconds 5
endform

# Set the measurement parameters:
if gender = 1
# for adult male
     maxform = 5000
     numberform = 5
     pfloor = 30
     pceiling = 200
else
# for adult female
     maxform = 5500
     numberform = 5
     pfloor = 100
     pceiling = 500
endif

# Record these parameters so they can be printed later:

parameters$ = "'maxform:0''tab$''numberform:0''tab$''pfloor:0'
     ...'tab$''pceiling:0''newline$'"

# Initiate the output file 
resultline$ = "token_number'tab$'fileName'tab$'target'tab$'begin_target'tab$'end_target'tab$'dur'tab$'time'tab$'time_point'tab$'F1'tab$'F2'tab$'F3'tab$'bandwidth_f1'tab$'bandwidth_f2'tab$'bandwidth_f3'tab$'max_formants'tab$'number_formants'tab$'speaker'tab$'word'newline$'"
fileappend "'textfile$'" 'resultline$'

#Go through files in a directory and count them 
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Open each file, one at a time
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'sound_directory$''fileName$'
	soundname$ = selected$ ("Sound", 1)

	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

	#Select sound and calculate the duration
	select Sound 'soundname$'
	To Formant (burg)... 0 'numberform' 'maxform' 0.025 50
	duration_of_file=Get total duration

	#Select the textgrid and let the fun begin 
	select TextGrid 'soundname$'
	numberOfIntervals = Get number of intervals... tier_analysis

		#Loop through every interval in the tier from where you will extract measurements (tier_analysis)
		for interval from 1 to numberOfIntervals
			label$ = Get label of interval... tier_analysis interval
				
				#But will only focus on the intervals that have a label that starts with a "*" symbol
				if label$ <> ""

					begin_target = Get starting point... tier_analysis interval
					end_target = Get end point... tier_analysis interval
					duration = end_target - begin_target
					intervalcenter = (begin_target + end_target) / 2
					pointsPerInterval = round ((duration/milliseconds)*1000) 

					# get the exclusion interval number at the interval center:
					interval_exclusion = Get interval at time... tier_exclusion intervalcenter
					# get the label of the exclusion interval:
					exclusion_label$ = Get label of interval... tier_exclusion interval_exclusion

					# get the comment interval number at the interval center:
					interval_comment = Get interval at time... tier_comment intervalcenter
					# get the label of the exclusion interval:
					comment$ = Get label of interval... tier_comment interval_comment

					if measurement_type = 1
						for j to time_points
							call GetFormantsNorm
							call PrintResults
						endfor
					elif measurement_type = 2
						for i to pointsPerInterval
							call GetFormantsNonNorm
							call PrintResults
						endfor
					endif

					# Remove the TextGrid object from the object list
					select TextGrid 'soundname$'
				endif
		endfor

	# Remove the sound object from the object list
	select Sound 'soundname$'
	select Strings list
	# and go on with the next sound file!
endfor

Remove

procedure GetFormantsNorm
	int = duration/time_points
	time = begin_target+int*j
	time_point = j

	select Formant 'soundname$'

    f1 = Get value at time... 1 time Hertz Linear
    bandf1 = Get bandwidth at time... 1 time Hertz Linear

    f2 = Get value at time... 2 time Hertz Linear
    bandf2 = Get bandwidth at time... 2 time Hertz Linear

    f3 = Get value at time... 3 time Hertz Linear
    bandf3 = Get bandwidth at time... 3 time Hertz Linear

endproc

procedure GetFormantsNonNorm
	time = begin_target+milliseconds*i 
	time_point = pointsPerInterval - (pointsPerInterval - i)

	select Formant 'soundname$'

    f1 = Get value at time... 1 time Hertz Linear
    bandf1 = Get bandwidth at time... 1 time Hertz Linear

    f2 = Get value at time... 2 time Hertz Linear
    bandf2 = Get bandwidth at time... 2 time Hertz Linear

    f3 = Get value at time... 3 time Hertz Linear
    bandf3 = Get bandwidth at time... 3 time Hertz Linear

endproc

procedure PrintResults
	time_output = (time*1000)
	time_output$ = fixed$ (time_output, 3)
					
	f1$ = fixed$ (f1, 3)
	f2$ = fixed$ (f2, 3)
	f3$ = fixed$ (f3, 3)

	bandf1$ = fixed$ (bandf1, 3)
	bandf2$ = fixed$ (bandf2, 3)
	bandf3$ = fixed$ (bandf3, 3)

	duration_output = duration * 1000
	duration$ = fixed$ (duration_output, 3)

	begin = begin_target*1000
	begin$ = fixed$ (begin_target, 3)

	end = end_target*1000
	end$ = fixed$ (end_target, 3)

	#Here, I am defining the token number. As is, this is the number of the file. So it will only work as long as each token is
	#in a separate file 
	ifile$ = fixed$ (ifile, 0)

	time_point$ = fixed$ (time_point, 0)

	maxform$ = fixed$ (maxform, 0)
	numberform$ = fixed$ (numberform, 0)


	#Here we print the results
	resultline$ = "'ifile$''tab$''soundname$''tab$''label$''tab$''begin$''tab$''end$''tab$''duration$''tab$''time_output$''tab$''time_point$''tab$''f1$''tab$''f2$''tab$''f3$''tab$''bandf1$''tab$''bandf2$''tab$''bandf3$''tab$''maxform$''tab$''numberform''tab$''exclusion_label$''tab$''comment$''newline$'"
	fileappend "'textfile$'" 'resultline$'
endproc

