####################################################################
####################################################################
#
# TITLE: Avizia_intensity_draft.praat
#
# BY:    Phillip Weirich
# DATE:  February 28, 2016
# FOR:   Praat version 6.0.14
#
# DEVELOPMENT STAGE: Early
#
#
#  INPUT:  - A single sound file
#          - A corresponding TextGrid with an interval tier on tier 2:
#
#
#  USAGE:
#
#  This script takes intensity measurements in intervals that are
#  labeled on tier 2.
#
#  Measurements and labels are sent to a text file, which can be
#  opened in Excel, R, SPSS, etc.
#
####################################################################
####################################################################


# 0) once textgrid and file are selected
# 	0.1) file name has already been stored as fileName$

####################################################################

####################################################################

# Add a header to a new, clean file

writeFileLine: "intensityData.txt", "FileName", tab$, "Label", tab$, "minIntensity", tab$, "maxIntensity", tab$, "meanIntensity"

####################################################################

# identifying the names/locations of relevant Objects:

pause Select Sound to analyze
sound$ = selected$ ("Sound")

pause Select TextGrid to analyze
textgrid = selected ("TextGrid")

####################################################################

# Extracting intensity measurements by identifying intervals in the
# textgrid that are not blank and taking intensity measurements
# in that interval. Measurements are output to a .txt in the directory
# the script is saved.  The file can be opened up in Excel.

numIntervals = Get number of intervals: 2
for labeledInterval to numIntervals
	# Once this module is incorporated into the directory selection
	# module, the object selection won't have to be done manually
	selectObject: 1
	label$ = Get label of interval: 2, labeledInterval
	if (label$ != "")
		intStart = Get starting point: 2, labeledInterval
		intEnd = Get end point: 2, labeledInterval
		# As above, objects will be seleceted automatically in the
		# final version of this script
		selectObject: 2
		extractedSound = Extract part: intStart, intEnd, "rectangular", 1, "no"
		intensity = To Intensity: 100, 0, "yes"
		minIntensity = Get minimum: 0, 0, "Parabolic"
		maxIntensity = Get maximum: 0, 0, "Parabolic"
		meanIntensity = Get mean: 0, 0, "energy"


		appendFileLine: "intensityData.txt", sound$, tab$, label$, tab$, minIntensity, tab$, maxIntensity, tab$, meanIntensity

		removeObject: extractedSound, intensity
	endif
endfor

writeInfoLine: "Congratulations! Your data has been collected! Go check the source directory."
