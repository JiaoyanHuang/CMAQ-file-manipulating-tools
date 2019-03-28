# CMAQ-input
This package is used to modify CMAQ input such as emission, boundary and initial condition, it can also be used to vituralize netcdf files.
<!--- comment out
## This is test
![](https://github.com/JiaoyanHuang/MOVESdata/blob/master/plots/2025_PM2.5_emission.png)
--->
## 1. var_stat <br />
This is a function to do general statistics on all variable in a ioapi netcdf file.
data_stat(file, path, reportfile) which generates max, min, mean, standard deviation for each variable

example data_stat(file, path, "test.txt")


20190220 update 2D tile map is ready, but some cells are mislocated, most of them are OK.

![SO2 tile map](plots/SO2_Lay_1_2006213%200.png)

