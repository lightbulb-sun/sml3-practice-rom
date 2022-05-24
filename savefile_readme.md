The first four bytes are the savefile header and always start with 0x19643957 (A000 - A003).
When player enters the pipe, bytes in A004-A017 are copied to A804-A817.

CartridgeRAM has an Offset of A000 (e.g., Savefile Data is being loaded into A800 - A000 = 0x0800)

## Wario Status ##
A804 - Current Course ID
A805 - Current Player Money
A806 - Current Player Money
A807 - Current Player Money
A808 - Hearts
A809 - Lives
A80A - Wario Status (00: small, 01: normal, 02: bull, 03: jet, 04: dragon)

## World Status ##
### Each Bit indicates if level has been completed (Max Levels = 7) ###
### Last Bit indicates if World has been completed (flag shows on map) ###
A80B - Rice Beach
A80C - Mt. Teapot
A80D - Number of Levels completed
A80E - Treasures Collected (1 Bit per Treasure, 1 Bit unused since 15 treasures)
A80F - Treasures Collected (1 Bit per Treasure, 1 Bit unused since 15 treasures)
A810 - Stove Canyon
A811 - SS Tea Cup
A812 - Parsley Woods
A813 - Sherbet Land
A814 - Syrup Castle
A815 - Checkpoint activated (00: inactive, 01: active)
A816 - Course ID from A815 (to assign the checkpoint to the Course ID)
A817 - Game Completed


### World / Level Information (0 = Not Cleared, 1 = Cleared) - 1 Byte per World ###
* Level State is being set when starting to leave the Coin Counter Screen (1st frame)
* Most Significant Bit: First Bit (very left)
* Least Significant Bit: Last Bit (very right)

#######################
A80B - Rice Beach

Most Significant Bit: -
2nd Significant Bit: Course 06
3rd Significant Bit: Course 05 (Boss Course)
4th Significant Bit: Course 04
5th Significant Bit: Course 03 (Wet)
6th Significant Bit: Course 03 (Dry)
7th Significant Bit: Course 02
Least Significant Bit: Course 01

#######################
A80C - Mt. Teapot

Most Significant Bit: Course 13 (Boss Course)
2nd Significant Bit: Course 12 (enables Boss Stage)
3rd Significant Bit: Course 11
4th Significant Bit: Course 09
5th Significant Bit: Course 10
6th Significant Bit: Course 08 (to Sherbet Land)
7th Significant Bit: Course 08 (Regular)
Least Significant Bit: Course 07

#######################
A810 - Stove Canyon

Most Significant Bit: -
2nd Significant Bit: Course 25 (Boss Course)
3rd Significant Bit: Course 24
4th Significant Bit: Course 23 (Secret)
5th Significant Bit: Course 23 (Regular)
6th Significant Bit: Course 22
7th Significant Bit: Course 21
Least Significant Bit: Course 20

#######################
A811 - SS Tea Cup

Most Significant Bit: -
2nd Significant Bit: -
3rd Significant Bit: -
4th Significant Bit: Course 30 (Boss Course)
5th Significant Bit: Course 29
6th Significant Bit: Course 28
7th Significant Bit: Course 27
Least Significant Bit: Course 26

#######################
A812 - Parsley Woods

Most Significant Bit: -
2nd Significant Bit: -
3rd Significant Bit: Course 36
4th Significant Bit: Course 35
5th Significant Bit: Course 34
6th Significant Bit: Course 33
7th Significant Bit: Course 32 (drains Water)
Least Significant Bit: Course 31

#######################
A813 - Sherbet Land

Most Significant Bit: Course 19 (Boss Stage)
2nd Significant Bit: Course 18
3rd Significant Bit: Course 17 (to Course 19)
4th Significant Bit: Course 16 (right, to Course 18)
5th Significant Bit: Course 16 (left, to Course 19)
6th Significant Bit: Course 15 (left, to Course 17)
7th Significant Bit: Course 15 (down, to Course 16)
Least Significant Bit: Course 14

#######################
A814 - Syrup Castle

Most Significant Bit: -
2nd Significant Bit: -
3rd Significant Bit: -
4th Significant Bit: -
5th Significant Bit: Course 40 (initializes Credits)
6th Significant Bit: Course 39
7th Significant Bit: Course 38
Least Significant Bit: Course 37

#######################
Debug Help

A375 - Clear Level
* 01 - Boss Fight Fanfare
* 02 - Regular Exit
* 03 - Glitched Exit (Genie Fight, Softlocks, Beat Game Flag set)