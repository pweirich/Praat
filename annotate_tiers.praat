# Note: This script almost works right.  It doesn't produce the block number the right way
#           because there isn't a line to handle the numbers on the end.  I am sleepy, though,
#           so I will go to bed and think about this later.  Also, the tiers aren't labeled the
#           same way in the actual script as I described them below in the header, so I should fix that



#This script walks through a text grid made from a set of concatenated (recoverable) sound files
# and divides up information contained in the original file name into different tiers.
# this information can be used later to easily create descriptive names for the individual
# sentence sound files.
#
# The script uses the second tier as the basis for assigning new tier labels.
# There should be six tiers in the text grid labeled as follows:
#
# 1) sentence
# 2) Gender
# 3) SubjID
# 4) StimNum
# 5) Block
# 6) TrialNum
#
# Author: Phillip Weirich (phillipweirich@yahoo.com)
#
############################################################################
############################################################################

# get number of intervals in tier 2 and only assign labels to actual speech, not silence

allIntervals = Get number of intervals: 2
for intervalNumber from 1 to allIntervals
    text$ = Get label of interval: 2, intervalNumber
        if text$ = "xxx"
            continue = 0
        else
            continue = 1
        endif
        if continue = 1

# pulls info from the sentence tier so it can be put into the relevant tiers

            intervalStart = Get starting point: 2, intervalNumber
            soundInterval = Get interval at time: 1, intervalStart
            soundLabel$ = Get label of interval: 1, soundInterval

# This part is for Gender

            Set interval text: 3, intervalNumber, soundLabel$
            Replace interval text: 3, intervalNumber, intervalNumber, "(Harv)", "", "Regular Expressions"
            Replace interval text: 3, intervalNumber, intervalNumber, "([0-9]{14}$)", "", "Regular Expressions"

# This part is for subject ID

            Set interval text: 4, intervalNumber, soundLabel$
            Replace interval text: 4, intervalNumber, intervalNumber, "(Harv[FM])", "", "Regular Expressions"
            Replace interval text: 4, intervalNumber, intervalNumber, "([0-9]{10}$)", "", "Regular Expressions"

# This one leaves the stimulus number

            Set interval text: 5, intervalNumber, soundLabel$
            Replace interval text: 5, intervalNumber, intervalNumber, "(Harv[FM][0-9]{4})", "", "Regular Expressions"
            Replace interval text: 5, intervalNumber, intervalNumber, "([0-9]{6}$)", "", "Regular Expressions"

# This one leaves the block number

            Set interval text: 6, intervalNumber, soundLabel$
            Replace interval text: 6, intervalNumber, intervalNumber, "(Harv[FM][0-9]{8})", "", "Regular Expressions"
            Replace interval text: 6, intervalNumber, intervalNumber, "([0-9]{4}$)", "", "Regular Expressions"

# This one leaves the trial number

            Set interval text: 7, intervalNumber, soundLabel$
            Replace interval text: 7, intervalNumber, intervalNumber, "(Harv[FM][0-9]{10})", "", "Regular Expressions"

        endif
endfor
