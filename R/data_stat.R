#' summarize county level MOVESoutput
#'
#' This function summarize county level MOVESouput
#' @param path: path to the file
#' @param file: target netcdf file
#' @param reportfile: file for stat report
#' @export
#' @examples
#'


data_stat <- function(file, path, reportfile){

  library(ncdf4)


  # path <- "C:/Users/jhuang/Documents"
  # file <- "emis2d.20110501.12us2.2023el_cb6v2_v6_11g+ss.camx.ioapi"
  reportfile <- sprintf("%s/%s",path, reportfile)
  if (file.exists(reportfile)) file.remove(reportfile)
  file1 <- sprintf("%s/%s",path, file)
  ncin <- nc_open(file1)

  nvar <- length(ncin$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncin$var[[i]]$name

  for (i in 2:nvar){
    write(paste(npoll[i],"data summary"),reportfile,append = TRUE)
    data <- ncvar_get(ncin,npoll[i])
    max_loc <- which( data==max(data) , arr.ind = T )
    min_loc <- which( data==min(data) , arr.ind = T )
    write(paste("Max  ",max(data), "@(c,r,l) =(",max_loc[1],max_loc[2],max_loc[3],")"),reportfile,append = TRUE)
    write(paste("Min  ",min(data), "@(c,r,l) =(",min_loc[1,1],min_loc[1,2],min_loc[1,3],")"),reportfile,append = TRUE)
    write(paste("Mean ",mean(data)),reportfile,append = TRUE)
    write(paste("std  ",sd(data)),reportfile,append = TRUE)
  }
  nc_close(ncin)
}
