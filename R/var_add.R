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

var_add <- function(file, path, inpoll, outpoll, outfile, ratio){

  library(ncdf4)
  file1 <- sprintf("%s/%s",path, file)
  file2 <- sprintf("%s/%s",path, outfile)
  file.copy(file1, file2,overwrite = T)
  ncin <- nc_open(file2, write = T)
  nvar <- length(ncin$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncin$var[[i]]$name

  ipoll <- which(npoll == inpoll)
  unit <- ncin$var[[ipoll]]$units
  ndim <- ncin$var[[ipoll]]$ndims
  misval <- ncin$var[[ipoll]]$missval
  prec <- ncin$var[[ipoll]]$prec
  lgname <- outpoll
  name <- outpoll
  vartmp <- ncvar_def(name,unit,ncin$var[[ipoll]]$dim, misval,longname=lgname)
  ncin <- ncvar_add(ncin,vartmp)


  data_tmp1 <- ncvar_get(ncin,trimws(ncin$var[[ipoll]]$longname))
  data_tmp2 <- data_tmp1*ratio
  ncvar_put( ncin, name, data_tmp2)
  ncatt_put(ncin, name, "longname", name)
  ncatt_put(ncin, name, "var_desc", sprintf("VARIABLE %s",lgname))
  var_list_tmp <- ncatt_get(ncin,0)$`VAR-LIST`
  var_tmp <- strtrim(paste(name,"                "),16)
  var_list <- paste(var_list_tmp,var_tmp)
  ncatt_put(ncin, 0, "VAR-LIST", var_list)
  nc_close(ncin)
}
