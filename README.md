# Detect Fundamental Frequency (Pitch) in speech
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/etfovac/pitch/blob/main/LICENSE) 

* Praat: Run Praat script on a test speech signal, log detected Fundamental Frequency F<sub>0</sub> to file as reference. 
* MATLAB: Pre-Processing: Use Threshold in time domain to segment the voiced speech.  
* MATLAB: Use Cepstrum processing on voiced speech to detect Pitch i.e. Fundamental Frequency F<sub>0</sub>. Detection done using: Threshold, Median and Non-linear Filtering.  
* Compare graphs of resulting F<sub>0</sub> contours detected in MATLAB and Praat as referent tool. 

### Keywords:  
> Speech Processing, Cepstrum, Fundamental Frequency, Praat, MATLAB  

### Table of Contents (Wiki)
[Wiki Home](https://github.com/etfovac/pitch/wiki)  
[Overview](https://github.com/etfovac/pitch/wiki/Overview)  
[Notes](https://github.com/etfovac/pitch/wiki/Notes)  
[Examples](https://github.com/etfovac/pitch/wiki/Examples)  
[References](https://github.com/etfovac/pitch/wiki/References)  

### Screenshots 
Praat scans the ```test files``` folder for .wav files and saves Timestamps and	```F0 (Pitch) [Hz]``` in .txt.  
Run ```src/praat_batch.bat```  
<img src="./graphics/cmd output.png" alt="cmd output">  
(check Praat data in MATLAB with ```src/test_read_praat_output.m```)  

Run ```src/main.m```
<img src="./graphics/Fig 1.png" alt="Fig 1"> 
<img src="./graphics/Fig 2.png" alt="Fig 2"> 
<img src="./graphics/Fig 3.png" alt="Fig 3"> 
<img src="./graphics/Fig 4.png" alt="Fig 4"> 
<img src="./graphics/Fig 5.png" alt="Fig 5"> 
<img src="./graphics/Fig 6.png" alt="Fig 6"> 
Cepstrum quick reminder:   
<img src="./graphics/Cepstrum_signal_analysis.png" alt="[Cepstrum_signal_analysis](https://en.wikipedia.org/wiki/Cepstrum#/media/File:Cepstrum_signal_analysis.png)">

[pitch](https://github.com/etfovac/pitch) is maintained by [etfovac](https://github.com/etfovac).
