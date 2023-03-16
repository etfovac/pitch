echo // PRAAT -> PITCH:
# CLI input params:
form: "Fill attributes"
       comment: "Choose folder with audio files: "
	   folder: "Test folder", "..\test files"
endform
folder$ = test_folder$ 
# variable name is the string id, lowercase, underscores for spaces
printline // 'folder$'

fileNames$# = fileNames$#(folder$ + "\*.wav")
for ifile to size(fileNames$#)
	file$ = folder$ + "\" + fileNames$#[ifile]
	printline // 'file$' 
	
	Read from file: file$
	name$ = selected$ (1)
	printline // 'name$'
	
	# Clear log file for current audio file
	logfile$ = folder$ + "\" + name$ + ".txt"
	deleteFile: logfile$
	
	fs = Get sampling frequency
	t = 1/fs
	shift = 64
	f0_low = 80
	f0_high = 300
	time_step = shift*t
	To Pitch... time_step f0_low f0_high
	
	# Write-out the header
	lines$# = {"// 'name$'", "// Input params:", "// Fs  = 'fs' [Hz]",
	..."// time step = 'time_step' [s]", "// F0 low  = 'f0_low' [Hz]",
	..."// F0 high = 'f0_high' [Hz]", "//",
	..."//Num	Time [s]	F0 (Pitch) [Hz]"}
	for line to size(lines$#)
		appendFileLine: logfile$, lines$#[line]
	endfor
	
	num_of_frames = Get number of frames
	for i from 1 to num_of_frames
		time = Get time from frame number... i
		f0 = Get value at time... time Hertz Linear
		line$ = "'i' 'tab$' 'time' 'tab$' 'f0'"
		appendFileLine: logfile$, line$
	endfor
endfor

# clean up
select all
Remove
printline // DONE.