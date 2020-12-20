All programs and features work as expected. We are flooring our answers.
A challenge that came up as we were debugging our design was trying to understand what our old assembly code from Lab 1 was doing.

Changes to the provided test benches:
	We instantiate our CPU at the beginning of each test bench as well
	We added lines 59-61 in test_bench_1.v, 58-60 in test_bench_2.v, and 58-60 in test_bench_2.v. All these changes change init/Reset to 0 so that our programs can start running
    In test_bench3.v, lines 95-96 are commented out to test answers with flooring

How to run a program:
0) Make sure that the assembler is in the same directory as the other files.
1) Call the python assembler with 'python assembler.py' and enter one of the following to the prompt: p1, p2, p3
	a) The assembler will overwrite LUT.v and InstROM.v with the appropriate settings. 
		In InstROM.v, it will change the file to read the correct machine_code file.
		In LUT.v, it will adjust the LUT values to match the branch locations for each program.
2) Compile the .v files with the appropriate machine_code on Modelsim/Quartus.
3) Switch to the correct test bench
4) Simulate and run!

Zoom link:
https://ucsd.zoom.us/rec/play/rDwaBewxNRnANk25yJYMhWZUyZKYsfrcucCfSk0J3OVPXKmrlI9LaXZsj7HXEyj6qY81-qQIqrUTIBU.rgAjmnxNUeEC0PQY?autoplay=true&continueMode=true&startTime=1607735514000

First two recordings were tests. Press the '>|' button in the bottom left to skip recordings.
The demo is shown in the third recording.

Timestamps:
	Overview: 0:00
	Program 1: 3:26
	Program 2: 9:07
	Program 3: 12:30
