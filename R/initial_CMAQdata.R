#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path: path to the file
#' @param file: target netcdf file
#' @param var: the variable you would like to change
#' @param ratio: the ratio you would like to apply
#' @export
#' @examples
#'
#'

var_change <- function(file, path, var, ratio){

  library(ncdf4)
  path <- path
  file <- file
  poll <- var
  file1 <- sprintf("%s/file",path, file)
  file1 <- sprintf("%s/file_new",path, file)
  file.copy(file1, file2,overwrite = T)


  ncin <- nc_open(file2, write = T)
  data_tmp1 <- ncvar_get(ncin,poll)
  data_tmp2 <- test*ratio
  ncvar_put( ncin, poll, data_tmp2)
  nc_close(ncin)
}
