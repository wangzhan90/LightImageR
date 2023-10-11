# Process data from Raster
# by Zhan Wang, Department of Agricultural Economics, Purdue University 
# zhanwang@purdue.edu

rm(list = ls())
# Set work folder
setwd("F:/tempsave/LightImage/Github/")
library(raster)
library(rgdal)
library(maptools)
library(ggplot2)
# Read in data
# Raster data source: Li, X., Zhou, Y., Zhao, M., & Zhao, X. (2020). A harmonized global nighttime light dataset 1992–2018. Scientific data, 7(1), 168.
# https://www.nature.com/articles/s41597-020-0510-y
r = raster("Harmonized_DN_NTL_2008_calDMSP.tif")
crs=CRS("+proj=longlat +datum=WGS84 +no_defs")
# Shapefile data source: https://liuyanguu.github.io/post/2020/06/12/ggplot-us-state-and-china-province-heatmap/
china.shp = readShapePoly('shapefile/bou2_4p.shp',proj4string=crs)
# visualization
plot(r)
plot(china.shp, add = T)
# Zoom to China
r.china = crop(r, china.shp)
plot(r.china)
plot(china.shp, add = T)
writeRaster(r.china, format = "GTiff", overwrite = TRUE, filename = "ChinaExtent.tif")
# Keep grids in China only
r.chinaonly = mask(r.china, china.shp)
plot(r.chinaonly)
plot(china.shp, add = T)
writeRaster(r.chinaonly, format = "GTiff", overwrite = TRUE, filename = "ChinaOnly.tif")
# Convert raster to dataframe
df = as.data.frame(r.chinaonly, xy = T)
df = subset(df, is.na(Harmonized_DN_NTL_2008_calDMSP) == F)

# This csv is too large to save! It is due to the high resolution (30 arc sec)
# write.csv(df, "output.csv" ,row.names = F)

# Let's try to aggregate it to 5 arc min (10 times larger in resolution)
# Create empty 5 arcmin raster (you can find the extent from china.shp)
xmin = 73
xmax = 136
ymin =  9
ymax = 54

e.r.5min = extent(xmin, xmax, ymin, ymax)
r.5min = raster(res=1/12, ext=e.r.5min)
r.5min <- resample(r.china, r.5min, method='bilinear')

r.chinaonly.5min = mask(r.5min, china.shp)
plot(r.chinaonly.5min)
plot(china.shp, add = T)
writeRaster(r.chinaonly.5min, format = "GTiff", overwrite = TRUE, filename = "ChinaOnly5min.tif")
# Convert raster to dataframe
df.5min = as.data.frame(r.chinaonly.5min, xy = T)
df.5min = subset(df.5min, is.na(Harmonized_DN_NTL_2008_calDMSP) == F)
write.csv(df.5min, "output5min.csv" ,row.names = F)