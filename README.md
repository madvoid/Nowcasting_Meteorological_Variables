# Data Filling of Micrometeorological Variables in Complex Terrain for High-Resolution Nowcasting

Repository for code accompanying paper _Data Filling of Micrometeorological Variables in Complex Terrain for High-Resolution Nowcasting_ published in Atmosphere. Below is a description of the top level folders. Files with `.m` extensions are run with Matlab, and files with `.ipynb` extentions are run with Python 3 and Jupiter.

## Top Level Folders/Files

* `Averaging Period`: Code studying the effect of the averaging period on performance. This was not published, but was requested by a reviewer.
* `Combination Test`: Calculate performance when using different input LEMS. Found in Appendix C.
* `Combined Statistics`: Code used to make all box plot figures in the manuscript.
* `Correlation Analysis`: Code used to make Figure A5 in Appendix D.

* `Day Focus ANN`: All ANN code is found here. There are separate scripts for each environmental variable, and separate plotting scripts for each environmental variable.

* `Day Focus LinReg`: All MLR code is found here. There are separate scripts for each environmental variable, and separate plotting scripts for each environmental variable.

* `Day Focus RFR`: All RFR code for Appendix E is found here. There are separate scripts for each environmental variable, and separate plotting scripts for each environmental variable.

* `Hidden Nodes`: Code used to analyze the number of hidden nodes required
* `LEMS_Avg_Latest.mat`: The main data file which can be read with Matlab. Only one copy of the data is included, and it may need to be copied/moved into run folders as necessary. The data is stored as a Matlab structure array. Code to read the data in can be seen in the various scripts throughout the repository.
* `Location Sensitivity`: Code to analyze the sensitivity to input LEMS locations as seen in Appendix C.
* `Time Series Plots`: Code to create time series Figures 5 and 6