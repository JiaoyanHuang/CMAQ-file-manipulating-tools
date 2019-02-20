#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path1: path to the ACON file
#' @param ACON: target netcdf file
#' @param path2: path to the GRID file
#' @param GRID: GRIDCRO2D file
#' @param GRID: GRIDCRO2D file
#' @param poll: pollytant or variable
#' @param TS: Timestemp
#' @param LAY: Layer
#' @param outpath: outpath
#' @export
#' @examples
#'
#'

CMAQ_map <- function(ACON, path1, GRID, path2, poll, TS, LAY, outpath){

  library(ncdf4)
  # prepare the paths and files for nc input
  file1 <- sprintf("%s/%s",path1, ACON)
  file2 <- sprintf("%s/%s",path2, GRID)

  # read LAT/LON and data
  ncin <- nc_open(file1)
  gridin <- nc_open(file2)
  LAT <- ncvar_get(gridin,"LAT")
  LON <- ncvar_get(gridin,"LON")

  nvar <- length(ncin$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncin$var[[i]]$name
  ipoll <- which(npoll == poll)
  pndim <- ncin$var[[ipoll]]$ndims
  dimlist <- matrix("",pndim,2)
  for (kk in 1:pndim){
    dimlist[kk,1] <- ncin$var[[ipoll]]$dim[[kk]]$name
    dimlist[kk,2] <- length(ncin$var[[ipoll]]$dim[[kk]]$vals)
  }

  nLay <- dimlist[3,2]
  nStep <- dimlist[4,2]
  date <- ncatt_get(ncin,0,"SDATE")$value
  TSTEP <- ncvar_get(ncin,"TFLAG")[2,1,]
  tstamp <- as.character(paste(date,TSTEP[TS],sep = " "))

  data_tmp <- ncvar_get(ncin,poll)

  if(length(dim(data_tmp)) == 2){
    data <- as.vector(data_tmp)
  }else if(length(dim(data_tmp)) == 3){
    if(nLay == 1){
      data <- as.vector(data_tmp[,,TS])
    }else if(nStep == 1){
      data <- as.vector(data_tmp[,,LAY])
    }
  }else if(length(dim(data_tmp)) == 4){
    data <- as.vector(data_tmp[,,LAY,TS])
  }

  # data <- as.vector(ncvar_get(ncin,poll)[,,1]) #take the TSTEP 1

  library(ggplot2)
  library(reshape2)
  library(akima)

  data_2 <- data.frame(cbind(as.vector(LON),as.vector(LAT),data))
  colnames(data_2) <- c("LON","LAT","POLL")

  fld <- with(data_2, interp(x = LON, y = LAT, z = POLL))

   df <- melt(fld$z, na.rm = TRUE)
   names(df) <- c("x", "y", "POLL")
   df$Lon <- fld$x[df$x]
   df$Lat <- fld$y[df$y]

  library(ggmap)
  us_states <- map_data("state")
  plottitle <- sprintf("%s Layer: %s date: %s",ncin$var[[ipoll]]$name,LAY, tstamp)
  unit <- sprintf("%s (%s)", poll, ncatt_get(ncin,poll)$units)

  outfile <- sprintf("%s/%s_Lay_%s_%s.png",outpath,poll,LAY,tstamp)

  p <-  ggplot() +
    coord_fixed(1.5) +
    geom_polygon(data=us_states ,aes(x=long, y=lat, group=group), colour="black", fill="red", alpha=0) +
    geom_tile(data = df, aes(x = Lon, y = Lat, fill = POLL), alpha = 0.8) +
    ggtitle(plottitle) +
    xlab("Longitude") +
    ylab("Latitude") +
    scale_fill_continuous(name = unit,
                          low = "white", high = "blue")
  png(outfile,units="in", width=5, height=4, res=300)
  print(p)
  dev.off()
}
