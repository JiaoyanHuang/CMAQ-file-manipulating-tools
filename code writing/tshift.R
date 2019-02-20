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


tshift <- function(file, path, source_time, target_time, outfile){

  library(ncdf4)
  library(abind)

  # path <- "C:/Users/jhuang/Documents"
  # file <- "emis2d.20110501.12us2.2023el_cb6v2_v6_11g+ss.camx.ioapi"
  # outfile <- "emis2d.20110501.12us2.2023el_cb6v2_v6_11g+ss.camx.ioapi_new"
  file1 <- sprintf("%s/%s",path, file)
  file2 <- sprintf("%s/%s",path, outfile)
  file.copy(file1, file2,overwrite = T)
  ncin <- nc_open(file2, write = T)

  # source_time <- "2011121 010000"
  # target_time <- "2011122 010000"
  time1 <- strptime(as.character(source_time),format = "%Y%j %H%M%S", tz = "GMT")
  time2 <- strptime(as.character(target_time),format = "%Y%j %H%M%S", tz = "GMT")
  time_diff <- time2 - time1

  TFLAG <- ncvar_get(ncin,"TFLAG")
  TFLAG_tmp1 <- paste(TFLAG[1,,],TFLAG[2,,]/1e4)
  TFLAG_tmp2 <- strptime(as.character(TFLAG_tmp1),format = "%Y%j %H", tz = "GMT")+time_diff
  TFLAG_tmp3 <- array(as.character(TFLAG_tmp2),dim(TFLAG)[2:3])
  TFLAG_d1 <- array(format(as.Date(TFLAG_tmp3, format = "%Y-%m-%d %H:%M:%S"),"%Y%j"),dim(TFLAG)[2:3])
  TFLAG_d2 <- array(paste(as.character(format(strptime(TFLAG_tmp3, format = "%Y-%m-%d %H:%M:%S"),"%H")),"0000",sep = ""),dim(TFLAG)[2:3])
  TFLAG_new <- abind(TFLAG_d1,TFLAG_d2,along=0)
  ncvar_put(ncin,"TFLAG",TFLAG_new)

  SDATE <- format(as.Date(as.character(target_time),format = "%Y%j"),"%Y%j")
  STIME <- paste(format(strptime(as.character(target_time),format = "%Y%j %H%M%S"),"%H"),"0000",sep="")
  ncatt_put(ncin,0,"SDATE",SDATE)
  ncatt_put(ncin,0,"STIME",STIME)
  nc_close(ncin)
}
