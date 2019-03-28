#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path: path to the file
#' @param BC: boundary condition netcdf file
#' @param IC: initial condition netcdf file
#' @param poll: pollution/species
#' @param lay: layer
#' @param outfile: outfile name
#' @export
#' @examples
#'
#'

IC_BC_VIR <- function(path, BC, IC, poll, lay, outpath){

  library(ncdf4)

  # path <- "C:/Users/jhuang/Documents"
  # BC <- "BCON_D502a_CMAQ-BENCHMARK_profile"
  file1 <- sprintf("%s/%s",path, BC)
  # IC <- "ICON_D502a_CMAQ-BENCHMARK_profile"
  file2 <- sprintf("%s/%s",path, IC)
  # poll <- "SO2"
  # lay <- 1
  ncBC <- nc_open(file1)
  ncIC <- nc_open(file2)
  # ncGRID <- nc_open(file3)

  nCOL <- ncIC$dim$COL$len
  nROW <- ncIC$dim$ROW$len

  sSB <- 1
  eSB <- sSB + nCOL
  sEB <- 1 + eSB
  eEB <- sEB + nROW
  sNB <- 1 + eEB
  eNB <- sNB + nCOL
  sWB <- 1 + eNB
  eWB <- sWB + nROW

  data <- ncvar_get(ncBC,poll)[,lay]

  data_tmp <- data.frame(matrix(0,eWB,3))
  colnames(data_tmp) <- c("COL","ROW","VALUE")

  for (i in 1:eWB){
    if(i < sEB){
      data_tmp$COL[i] <- i
      data_tmp$ROW[i] <- 1
      data_tmp$VALUE[i] <- data[i]
    }else if(i < sNB){
      data_tmp$COL[i] <- nCOL + 2
      data_tmp$ROW[i] <- i - eSB
      data_tmp$VALUE[i] <- data[i]
    }else if(i < sWB){
      data_tmp$COL[i] <- sWB - i + 1
      data_tmp$ROW[i] <- nROW + 2
      data_tmp$VALUE[i] <- data[i]
    }else{
      data_tmp$COL[i] <- 1
      data_tmp$ROW[i] <- eWB - i + 2
      data_tmp$VALUE[i] <- data[i]
    }
  }

  library(ggplot2)

  p <- ggplot(data = data_tmp, aes(x = COL, y = ROW, fill = VALUE)) +
    geom_tile() +
    scale_fill_continuous(low = "white", high = "blue") +
    labs(fill=ncBC$var$SO2$units) +
    ggtitle(sprintf("%s boundary condition, layer: %s",poll,lay))

  outfile <- sprintf("%s/%s.png",path,BC)
  png(outfile,units="in", width=5, height=4, res=300)
  print(p)
  dev.off()
}
