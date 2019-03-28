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

  sCOL <- 10
  eCOL <- 30
  sROW <- 10
  eROW <- 30
  dCOL <- eCOL - sCOL + 1
  dROW <- eROW - sROW + 1
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
  ncout <- nc_open(file3, write = T)
  gridin <- nc_open(file2)
  LAT <- ncvar_get(gridin,"LAT")
  LON <- ncvar_get(gridin,"LON")

  nvar <- length(ncin$var)
  npoll <- array(0,nvar)
  for (i in 1:nvar)
    npoll[i] <- ncin$var[[i]]$name

  ndimen <- array(0,ncin$ndims)
  for (i in 1:ncin$ndims)
    ndimen[i] <- ncin$dim[[i]]$name

  v_val <- c(ncin$dim[[4]]$vals,seq(ncin$dim[[4]]$len+1,ncin$dim[[4]]$len+9,1))

  #define diemnsions
  t <- ncdim_def(ndimen[1],"",ncin$dim[[1]]$vals,unlim = T)
  d <- ncdim_def(ndimen[2],"",ncin$dim[[2]]$vals)
  z <- ncdim_def(ndimen[3],"",ncin$dim[[3]]$vals)
  v <- ncdim_def(ndimen[4],"",ncin$dim[[4]]$vals)
  y <- ncdim_def(ndimen[5],"",ncin$dim[[5]]$vals) #[sROW:eROW])
  x <- ncdim_def(ndimen[6],"",ncin$dim[[6]]$vals) #[sCOL:eCOL])

  # add var to make dimension in correct order
  varp1 <- ncvar_def("VAR1","",t)
  ncnew <- nc_create("test1.nc", varp1 )
  varp2 <- ncvar_def("VAR2","",list(d,z,v,y,x))
  ncnew <- ncvar_add(ncnew,varp2)
  # varp3 <- ncvar_def(ndimen[3],"",z)
  # ncnew <- ncvar_add(ncnew,varp3)
  # varp4 <- ncvar_def(ndimen[4],"",v)
  # ncnew <- ncvar_add(ncnew,varp4)
  # varp5 <- ncvar_def(ndimen[5],"",y)
  # ncnew <- ncvar_add(ncnew,varp5)
  # varp6 <- ncvar_def(ndimen[6],"",x)
  # ncnew <- ncvar_add(ncnew,varp6)


  var_dim1 <- list(d,v,t)
  var1 <- ncvar_def(npoll[1],ncin$var[[1]]$units,var_dim1,longname = ncin$var[[1]]$longname,prec = "integer")
  ncnew <- ncvar_add(ncnew,var1)
  dt <- ncvar_get(ncin,"TFLAG")
  # dtt <- array(c(as.vector(dt),as.vector(dt[,1:8,])),c(2,ncin$nvars+8,ncin$dim$TSTEP$len))
  ncvar_put(ncnew, var1,dt)
  ncatt_put(ncnew,npoll[1], "var_desc", "Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS                                ")

  for (i in 2:length(npoll)){
    var_dim <- list(x,y,z,t)
    var <- ncvar_def(npoll[i],ncin$var[[i]]$units,var_dim, longname = ncin$var[[i]]$longname)
    ncnew <- ncvar_add(ncnew,var)

    var_val <- as.vector(ncvar_get(ncin,npoll[i]))#[sCOL:eCOL,sROW:eROW,])
    ncvar_put(ncnew, var,var_val)
    ncatt_put(ncnew,npoll[i], "var_desc", sprintf("Model species %s",ncin$var[[i]]$longname))
  }

  nc_close(ncnew)
  nctest <- nc_open("test1.nc", write = T)

  nc_att <- ncatt_get(ncin,0)
  g_att_name <- names(nc_att)
  for (i in 1:length(nc_att)){
    ncatt_put(ncnew,0,g_att_name[i],nc_att[[i]])
  }

  nc_close(ncnew)
  # nctest <- nc_open("test1.nc", write = T)
  #
  # XORIG <- ncatt_get(ncin,0,"XORIG")
  # YORIG <- ncatt_get(ncin,0,"YORIG")
  # XCELL <- ncatt_get(ncin,0,"XCELL")
  # YCELL <- ncatt_get(ncin,0,"YCELL")
  # XORIGnew <- XORIG$value + (sCOL - 1) * XCELL$value
  # YORIGnew <- YORIG$value + (sROW - 1) * YCELL$value
  #
  # ncatt_put(nctest,0,"XORIG",XORIGnew)
  # ncatt_put(nctest,0,"YORIG",YORIGnew)
  #
  # nc_close(ncnew)
  # nctest <- nc_open("test1.nc")


  # data <- ncvar_get(ncout,"ACROLEIN")
  # datanew <- data[sCOL:eCOL,sROW:eROW,]
  # ncout$var[[2]]$size <- c(dCOL,dROW,1,25)
  # nc_close(ncout)
  # ncout <- nc_open(file3, write = T)
  # ncvar_put(ncout,"ACROLEIN",datanew)


# }
