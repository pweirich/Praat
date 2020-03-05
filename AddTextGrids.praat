# This script opens all .wav files in a directory
# and adds a textgrid for each file
clearinfo

form Open all files in directory
  sentence Directory 
endform

Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings
for ifile to numberOfFiles

	# Open all .wav files

	filename$ = Get string... ifile
	if right$ (filename$, 4) == ".wav"
		Read from file... 'directory$''filename$'
		soundName$ = filename$ - ".wav"

		# Create and save textgrid for each file
	
		To TextGrid: "Task", ""
		Save as text file: directory$ + soundName$ + ".TextGrid"

		# Clean up Objects window

		selectObject: "Sound " + soundName$, "TextGrid " + soundName$
		Remove
		
	endif

	select Strings list
endfor
select Strings list
Remove

writeInfoLine: "The TextGrids have been created and saved to the directory."