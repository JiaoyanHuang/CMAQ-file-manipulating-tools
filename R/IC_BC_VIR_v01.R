#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path: path to the file
#' @param BC: boundary condition netcdf file
#' @param IC: initial condition netcdf file
#' @param BDY: boundary condition GRID file
#' @param poll: pollution/species
#' @param lay: layer
#' @param outfile: outfile name
#' @param country: domain region
#' @param xlimit: range of longitude
#' @export
#' @examples
#'
#'

IC_BC_VIR <- function(path, BC, IC, BDY, poll, lay, outpath, country,xlimit){

  library(ncdf4)

  # path <- "C:/Users/jhuang/Documents"
  # BC <- "BCON_D502a_CMAQ-BENCHMARK_profile"
  file1 <- sprintf("%s/%s",path, BC)
  # IC <- "ICON_D502a_CMAQ-BENCHMARK_profile"
  file2 <- sprintf("%s/%s",path, IC)
  # BDY <- "GRIDBDY2D_Benchmark"
  file3 <- sprintf("%s/%s",path, BDY)
  # poll <- "SO2"
  # lay <- 1
  ncBC <- nc_open(file1)
  ncIC <- nc_open(file2)
  ncBDY <- nc_open(file3)

  nvar <- length(ncBC$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncBC$var[[i]]$name

  unit <- ncatt_get(ncBC,poll)$units

  BLAT <- ncvar_get(ncBDY,"LAT")
  BLON <- ncvar_get(ncBDY,"LON")

  nCOL <- ncIC$dim$COL$len
  nROW <- ncIC$dim$ROW$len

  data <- ncvar_get(ncBC,poll)[,lay]

  data_tmp <- data.frame(matrix(0,length(data),3))
  colnames(data_tmp) <- c("LAT","LON","VALUE")

  for (i in 1:length(data)){
    data_tmp[i,] <- c(BLAT[i],BLON[i],data[i])
  }

  library(ggplot2)
  library(ggmap)
  map <- map_data("world",country)

  p <-  ggplot() +
    coord_fixed(1.5) +
    geom_polygon(data=map ,aes(x=long, y=lat, group=group), colour="black", fill="red", alpha=0) +
    geom_point(data = data_tmp, aes(x = LON, y = LAT, colour = VALUE))+
    scale_color_continuous(low = "white", high = "blue") +
    labs(color=unit) +
    xlim(xlimit) +
    ggtitle(sprintf("%s boundary condition, layer: %s",poll,lay))

  outfile <- sprintf("%s/%s.png",path,BC)
  png(outfile,units="in", width=5, height=4, res=300)
  print(p)
  dev.off()
}
