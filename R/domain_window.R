#' #' summarize county level MOVESoutput
#' #'
#' #' This function summarize county level MOVESouput
#' #' @param path: path to the file
#' #' @param file: target netcdf file
#' #' @param var: the variable you would like to change
#' #' @param ratio: the ratio you would like to apply
#' #' @export
#' #' @examples
#' #'
#' #'
#'
#' domain_wndw <- function(file, path, inpoll, outpoll, outfile, ratio){

  library(ncdf4)

  path <- "C:/Users/jhuang/Documents"
  file <- "emis_mole_all_20060801_12US1_cmaq_cb05_tx_C25_2006am.ncf"
  outfile <- sprintf("%s_test",file)
  file1 <- sprintf("%s/%s",path, file)
  GRID <- "GRIDCRO2D_Benchmark"
  file2 <- sprintf("%s/%s",path, GRID)
  poll <- "SO2"
  file3 <- sprintf("%s/%s",path, outfile)
  file.copy(file1, file3,overwrite = T)
  ncin <- nc_open(file1)
  gridin <- nc_open(file2)
  LAT <- ncvar_get(gridin,"LAT")
  LON <- ncvar_get(gridin,"LON")


# }
