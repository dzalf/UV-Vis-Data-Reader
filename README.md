## **UV-Vis Data Processor and Plotter**

For users of the UV-Vis system Genesys 10S short script you will be able to process data
captured during manual measurements and merge their values into a single _.csv_
("comma-separated values") file.

This eliminates the need (and the _urge_) of using the VisionLite* software (for now ¬¬)

*_VisionLite has been discontinued_

## **Dependencies**

1. Developed in [Octave](https://octave.org)* and compatible (not fully tested) with Matlab
2. The script calls the _signal_ package

*_Nanofunctional users: please note that all research PCs have Octave preinstalled_

3. The script uses the code from [BrewerMap](https://github.com/DrosteEffect/BrewerMap) which provides
accurate color schemes for data visualization

## **To use:**

1. Open Octave and select your browsing directory to the source files container (folder UV-Vis-Data-Reader)
2. Run the file `uv-vis-loader.m` and follow the instructions
3. Data can be plotted using different color schemes taken from the color theory from [Cynthia Brewer](http://colorbrewer.org)
4. Merged data will be saved in _.csv_ format
5. Final data files can be easily opened with LibreOffice Calc (preinstalled in all research PCs)

## **TODO:**
    [ ] Add peaks detection
    [ ] Add markers
    [x] Correct single file reading
    [ ] Change axis units label


## **Screenshots**

- A typical Methyl Blue plot using "_Sequential-Dark2_" color scheme:

![image](https://github.com/dzalf/UV-Vis-Data-Reader/blob/main/Test%20Data/Methyl-Blue-Test.png)

- Data can be read from any _.csv_ files processor (including OriginLab and [LibreOffice Calc](https://www.libreoffice.org))

![image](https://github.com/dzalf/UV-Vis-Data-Reader/blob/main/Test%20Data/Merged_Data_csv_Libre-Office.png)


