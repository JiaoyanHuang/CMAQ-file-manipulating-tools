#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path: path to the file
#' @param NC1: input netcdf file
#' @param GRID: GRID file
#' @param outfile: outfile with mask point
#' @param REAL: the real mask point in csv file
#' @param poll: pollution/species
#' @param t: time
#' @param ratio: ratio between boundary points
#' @param mask_name: mask variable name
#' @export
#' @examples
#'
#'

Mask_area <- function(path, NC1, GRID, outfile, REAL, ratio, poll, t, mask_name){

  library(ncdf4)
  library(urbnmapr)
  library(tidyverse)
  library(oce)

  # path <- "C:/Users/jhuang/Documents"
  # NC1 <- "emis_mole_all_20060801_12US1_cmaq_cb05_tx_C25_2006am.ncf"
  file1 <- sprintf("%s/%s",path, NC1)
  # GRID <- "GRIDCRO2D_Benchmark"
  file2 <- sprintf("%s/%s",path, GRID)
  # outfile <- "mask_area_test.nc"
  file3 <- sprintf("%s/%s",path,outfile)
  file.copy(file2, file3,overwrite = T)
  # ratio <- 4
  # REAL <- "test.csv"
  file4 <- sprintf("%s/%s",path,REAL)
  mask_boundary <- read.csv(file4)


  data_t <- data.frame(matrix(0,(length(mask_boundary$long)-1)*ratio + 1,2))
  colnames(data_t) <- c("LON","LAT")

  for(i in 1:length(mask_boundary$long)){
    ii <- (i-1)*ratio + 1
    ee <- (i-1)*ratio + ratio
    if (i != length(mask_boundary$long)){
      data_t$LON[c(ii:ee)] <- seq(mask_boundary$long[i],mask_boundary$long[i+1],length.out = ratio)
      data_t$LAT[c(ii:ee)] <- seq(mask_boundary$lat[i],mask_boundary$lat[i+1],length.out = ratio)
    }else{
      data_t$LON[ii] <- mask_boundary$long[i]
      data_t$LAT[ii] <- mask_boundary$lat[i]
    }
  }

  data_t$COL <- 0
  data_t$ROW <- 0


  # poll <- "SO2"
  # lay <- t
  index1 <- 1
  index2 <- 0
  ncin <- nc_open(file1)
  ncGRID <- nc_open(file2)
  ncout <- nc_open(file3, write = T)

  nvar <- length(ncin$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncin$var[[i]]$name

  unit <- ncatt_get(ncin,poll)$units

  LAT <- ncvar_get(ncGRID,"LAT")
  LON <- ncvar_get(ncGRID,"LON")
  COL <- ncin$dim$COL$vals
  ROW <- ncin$dim$ROW$vals
  data_tmp <- expand.grid(COL,ROW)
  colnames(data_tmp) <- c("COL","ROW")
  data_tmp$LON <- as.vector(LON)
  data_tmp$LAT <- as.vector(LAT)
  data_tmp$value <- as.vector(ncvar_get(ncin,poll)[,,t])

  data_tmp$COLROW <- str_c(data_tmp$COL,",",data_tmp$ROW)

  for (i in 1:length(data_t$LON)){
    data_tmp$dis <- ((data_tmp$LON - data_t$LON[i])^2 + (data_tmp$LAT - data_t$LAT[i])^2)^0.5
    data_t$COL[i] <- data_tmp[which.min(data_tmp$dis),1]
    data_t$ROW[i] <- data_tmp[which.min(data_tmp$dis),2]
  }

  library(stringr)
  data_t$COLROW <- str_c(data_t$COL,",",data_t$ROW)

  for(i in 1:length(data_tmp$COL)){
    if(data_tmp$COLROW[i] %in% data_t$COLROW){
      data_tmp$value[i] <- index1
    }else{
      data_tmp$value[i] <- index2
    }
  }

  for(i in 1:length(data_tmp$COL)){
    COL_tmp <- data_tmp$COL[i]
    ROW_tmp <- data_tmp$ROW[i]
    rowmax <- max(data_tmp[which(data_tmp$value == 1 & data_tmp$COL == COL_tmp),2])
    rowmin <- min(data_tmp[which(data_tmp$value == 1 & data_tmp$COL == COL_tmp),2])
    colmax <- max(data_tmp[which(data_tmp$value == 1 & data_tmp$ROW == ROW_tmp),1])
    colmin <- min(data_tmp[which(data_tmp$value == 1 & data_tmp$ROW == ROW_tmp),1])
    if(data_tmp$ROW[i] < rowmax & data_tmp$ROW[i] > rowmin &
       data_tmp$COL[i] < colmax & data_tmp$COL[i] > colmin){
      data_tmp$value[i] <- 1
    }
  }

  # mask_name <- "test_nc"
  vartmp <- ncvar_def(mask_name,"",ncout$var$LWMASK$dim)
  ncout <- ncvar_add(ncout,vartmp)
  ncvar_put(ncout,mask_name,array(data_tmp$value,dim = c(length(COL),length(ROW),1,1)))
  nc_close(ncout)
}
