Title: CMAQ file manipulating tools (CMAQ FMT) Author: Jiaoyan J. Huang Date: 2019-04-11

# OVERVIEW

This package is used to modify CMAQ input/output files such as emission, boundary and initial condition, it can also be used to vituralize netcdf files.

# PREREQUISITES

* OS : Linux, Mac OS, Windows
* R>=3.4.3 
  * ncdf4
  * ggplot2
  * reshape2
  * akima
  * ggmap
  * urbnmapr
  * tidyverse
  * oce
  * stringr
  * abind
  
# INSTALLATION

install.packages("devtools")

library(devtools)

install_github("JiaoyanHuang/CMAQ-file-manipulating-tools")


## 1. var_stat <br />
This is a function to do general statistics on all variable in a ioapi netcdf file.
data_stat(file, path, reportfile) which generates max, min, mean, standard deviation for each variable

## 2. var_add <br />
This is a function to add a variable into current ioapi netcdf file using current variable with a ratio.
var_add(file, path, inpoll, outpoll, outfile, ratio). This function is usually used to add missing species in initial/boundary condition files, and/or emission files. It copies a original netcdf file to a target netcf file, and adds a variable based on the given inpoll and multiplied with a given ratio. 

When the CMAQ is updated, the species might be changed, you can add a new varible which is a new varible in the new version. This function would be handy, you can add variable to match the species in emission files between previous and current verions.

## 3. var_change <br />
This is a function to reduce/increase the values in variables with a ratio. For example you would like to reduce all SO2 emission in all grid-cells to half. 
var_change(file, path, inpoll, outfile, ratio)

## 4. tshift <br />
This is a funciton to change time step, same as m3tshift.
tshift(file, path, source_time, target_time, outfile)

## 5. CMAQmap <br />
This is a funciton to vituralize CMAQ data.
CMAQ_map(ACON, path1, GRID, path2, poll, TS, LAY, outpath)
example:
20190220 update 2D tile map is ready, but some cells are mislocated, most of them are OK.
CMAQ_map(ACON, path1, GRID, path2, "so2, TS, LAY, outpath)
![SO2 tile map](plots/SO2_Lay_1_2006213%200.png)

## 6. IC-BC-VIR <br />
This is a funciton to vituralize coundary condition data.
IC_BC_VIR(path, BC, IC, BDY, poll, lay, outpath, country,xlimit)
example:
IC_BC_VIR(path, BC,IC,BDY,"O3",2, path, c("usa","Canada","Mexico"),c(-200,-50))

![SO2 boundary_condition](plots/BCON_D502a_CMAQ-BENCHMARK_profile.png)

## 7. mask_point and mask_area <br />
These functions are used to mask out the given points (long and lat) or mask out the areas with given boundary for example

![SO2 boundary_condition](plots/SO2_mask_Lay_1_2006213%200.png)

![MASK area](plots/SO2_maskarea_Lay_1_2006213%200.png)
