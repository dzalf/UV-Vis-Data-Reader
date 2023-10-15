## **UV-Vis Data Processor and Plotter**

For users of the UV-Vis system Genesys 10S. This tool will aid you in processing data
captured during manual measurements and merging their values into a single _.csv_
("comma-separated values") file where each column is an individual absorption test.

This eliminates the need (and the _urge_) of using the VisionLite* software (for now ¬¬)

*_VisionLite has been discontinued. We will try to get the latest usable version_

## **Description/Dependencies**

1. Developed in/for [Octave 8.3+](https://octave.org)* and compatible with Matlab (not fully tested).
2. The script internally calls the _signal_ package.
3. The script uses the code from [BrewerMap](https://github.com/DrosteEffect/BrewerMap) which provides
accurate color schemes for data visualization.

*_Nanofunctional users: please note that all research PCs have Octave preinstalled_.

## **To use:**

1. Open Octave and change your browsing directory to the source files container (folder "UV-Vis-Data-Reader").
2. Run the file `uv-vis-loader.m` and follow the instructions.
3. Data can be plotted using different color schemes from the color theory from [Cynthia Brewer](http://colorbrewer.org).
4. Merged data will be saved in _.csv_ format.
5. Data peaks are computed based on an amplitude threshold provided by the user.
6. Peak finding results are displayed in the console for each data set. These values are plotted on top of the graphs using markers.
7. Final data files can be easily opened with _LibreOffice Calc_ (preinstalled on all research PCs).

## **TODO:**

    [x] Add peak detection
    [x] Add markers
    [x] Correct single file reading
    [x] Change axis units label

## **Screenshots**

- A typical Methyl Blue plot using "_Sequential-PuBu" color scheme:

![image](https://github.com/dzalf/UV-Vis-Data-Reader/blob/peaks-detection/Test%20Data/Console%20and%20Plot%20Outputs.png)

- Data can be read from any _.csv_ files processor (including OriginLab and [LibreOffice Calc](https://www.libreoffice.org))

![image](https://github.com/dzalf/UV-Vis-Data-Reader/blob/main/Test%20Data/Merged_Data_csv_Libre-Office.png)


