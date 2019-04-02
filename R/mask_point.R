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
#' @param mask_name: mask variable name
#' @export
#' @examples
#'
#'

Mask_point <- function(path, NC1, GRID, outfile, REAL, poll, t, mask_name){

  library(ncdf4)

  # path <- "C:/Users/jhuang/Documents"
  # NC1 <- "emis_mole_all_20060801_12US1_cmaq_cb05_tx_C25_2006am.ncf"
  file1 <- sprintf("%s/%s",path, NC1)
  # GRID <- "GRIDCRO2D_Benchmark"
  file2 <- sprintf("%s/%s",path, GRID)
  file3 <- sprintf("%s/%s",path,outfile)
  file.copy(file2, file3,overwrite = T)
  # REAL <- "test.csv"
  file4 <- sprintf("%s/%s",path,REAL)
  mask_point <- read.csv(file4)
  colnames(mask_point) <- c("LON","LAT")
  mask_point$COL <- 0
  mask_point$ROW <- 0

  # poll <- "SO2"
  # lay <- 1
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

  for (i in 1:length(mask_point$LON)){
    data_tmp$dis <- ((data_tmp$LON - mask_point$LON[i])^2 + (data_tmp$LAT - mask_point$LAT[i])^2)^0.5
    mask_point$COL[i] <- data_tmp[which.min(data_tmp$dis),1]
    mask_point$ROW[i] <- data_tmp[which.min(data_tmp$dis),2]
  }
  library(stringr)
  mask_point$COLROW <- str_c(mask_point$COL,",",mask_point$ROW)


  for(i in 1:length(data_tmp$COL)){
    if(data_tmp$COLROW[i] %in% mask_point$COLROW){
      data_tmp$value[i] <- index1
    }else{
      data_tmp$value[i] <- index2
    }
  }
  vartmp <- ncvar_def(mask_name,"",ncout$var$LWMASK$dim)
  ncout <- ncvar_add(ncout,vartmp)
  ncvar_put(ncout,mask_name,array(data_tmp$value,dim = c(length(COL),length(ROW),1,1)))
  nc_close(ncout)
}
