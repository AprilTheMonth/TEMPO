library(ncdf4)

library(data.table)

#setwd("/Volumes/Denali/data/satellite/TEMPO")

Sys.setenv(TZ="UTC")


files = list.files( "./nc", pattern="*.nc", full.names=TRUE, recursive=TRUE )

for ( f in seq_along(files) ) {


fin = files[f]


id = nc_open(fin)


print(fin)


dout = format( as.POSIXct(ncvar_get(id,"geolocation/time",start=c(1),count=c(1)),origin="1980-01-06 00:00:00 UTC"), "RData/%Y/%m/%d" )

if ( ! dir.exists(dout) ) { dir.create(dout,recursive=TRUE) }


fout = sprintf( "%s/%s", dout, gsub(".nc$", ".RData", basename(fin) ) )

if ( ! file.exists(fout) ) {


print(fout)


xtrack = ncvar_get(id,"xtrack")

mirror_step = ncvar_get(id,"mirror_step")


quick = subset( data.table( lon = as.vector(ncvar_get(id,"geolocation/longitude")),

                    lat = as.vector(ncvar_get(id,"geolocation/latitude")),

	    XNO2t  = as.vector( ncvar_get( id, "product/vertical_column_troposphere") ) ),

	    is.finite(XNO2t) & lat > 39 & lat < 46 & lon > -81 & lon < -70.5 )

if ( length(quick$XNO2t) == 0 ) { nc_close(id); next }


data = data.table(        lon    = as.vector(ncvar_get(id,"geolocation/longitude")),

                          lat    = as.vector(ncvar_get(id,"geolocation/latitude")),

	  lon_NE = as.vector(ncvar_get(id,"geolocation/longitude_bounds",start=c(1,1,1),count=c(1,-1,-1))),

	  lat_NE = as.vector(ncvar_get(id,"geolocation/latitude_bounds",start=c(1,1,1),count=c(1,-1,-1))),

	  lon_NW = as.vector(ncvar_get(id,"geolocation/longitude_bounds",start=c(2,1,1),count=c(1,-1,-1))),

	  lat_NW = as.vector(ncvar_get(id,"geolocation/latitude_bounds",start=c(2,1,1),count=c(1,-1,-1))),

	  lon_SW = as.vector(ncvar_get(id,"geolocation/longitude_bounds",start=c(3,1,1),count=c(1,-1,-1))),

	  lat_SW = as.vector(ncvar_get(id,"geolocation/latitude_bounds",start=c(3,1,1),count=c(1,-1,-1))),

	  lon_SE = as.vector(ncvar_get(id,"geolocation/longitude_bounds",start=c(4,1,1),count=c(1,-1,-1))),

	  lat_SE = as.vector(ncvar_get(id,"geolocation/latitude_bounds",start=c(4,1,1),count=c(1,-1,-1))),

                          time = as.vector(aperm(array( as.POSIXct(ncvar_get(id,"geolocation/time"),origin="1980-01-06 00:00:00 UTC"), dim=c(length(mirror_step),length(xtrack)) ),c(2,1))),

                           XNO2                                                = as.vector( ncvar_get( id, "product/vertical_column_stratosphere") ),

                           XNO2t                                               = as.vector( ncvar_get( id, "product/vertical_column_troposphere") ),

                           XNO2tu                                              = as.vector( ncvar_get( id, "product/vertical_column_troposphere_uncertainty")),

                           main_data_quality_flag                              = as.vector( ncvar_get( id, "product/main_data_quality_flag" ) ),

                           solar_zenith_angle                                  = as.vector( ncvar_get( id, "geolocation/solar_zenith_angle" ) ),

                           solar_azimuth_angle                                 = as.vector( ncvar_get( id, "geolocation/solar_azimuth_angle" ) ), 

                           viewing_zenith_angle                                = as.vector( ncvar_get( id, "geolocation/viewing_zenith_angle" ) ),                                 

                           relative_azimuth_angle                              = as.vector( ncvar_get( id, "geolocation/relative_azimuth_angle" ) ),

                           fit_rms_residual                                    = as.vector( ncvar_get( id, "qa_statistics/fit_rms_residual" ) ),   

 	  fit_convergence_flag                                = as.vector( ncvar_get( id, "qa_statistics/fit_convergence_flag" ) ),                                                            

                           vertical_column_total                               = as.vector( ncvar_get( id, "support_data/vertical_column_total" ) ),                               

                           vertical_column_total_uncertainty                   = as.vector( ncvar_get( id, "support_data/vertical_column_total_uncertainty" ) ),                   

                           fitted_slant_column                                 = as.vector( ncvar_get( id, "support_data/fitted_slant_column" ) ),                                 

                           fitted_slant_column_uncertainty                     = as.vector( ncvar_get( id, "support_data/fitted_slant_column_uncertainty" ) ),

                           snow_ice_fraction                                   = as.vector( ncvar_get( id, "support_data/snow_ice_fraction" ) ),                                   

                           terrain_height                                      = as.vector( ncvar_get( id, "support_data/terrain_height" ) ),

                           ground_pixel_quality_flag                           = as.vector( ncvar_get( id, "support_data/ground_pixel_quality_flag" ) ),

 	  surface_pressure                                    = as.vector( ncvar_get( id, "support_data/surface_pressure" ) ),                                    

                           tropopause_pressure                                 = as.vector( ncvar_get( id, "support_data/tropopause_pressure" ) ),

 	  scattering_weights_01                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 1,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_02                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 2,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_03                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 3,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_04                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 4,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_05                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 5,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_06                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 6,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_07                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 7,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_08                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 8,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_09                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c( 9,1,1), count=c( 1,-1,-1) ) ),	 

 	  scattering_weights_10                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(10,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_11                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(11,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_12                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(12,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_13                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(13,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_14                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(14,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_15                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(15,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_16                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(16,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_17                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(17,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_18                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(18,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_19                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(19,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_20                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(20,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_21                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(21,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_22                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(22,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_23                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(23,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_24                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(24,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_25                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(25,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_26                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(26,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_27                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(27,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_28                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(28,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_29                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(29,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_30                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(30,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_31                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(31,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_32                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(32,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_33                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(33,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_34                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(34,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_35                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(35,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_36                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(36,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_37                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(37,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_38                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(38,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_39                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(39,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_40                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(40,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_41                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(41,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_42                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(42,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_43                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(43,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_44                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(44,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_45                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(45,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_46                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(46,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_47                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(47,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_48                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(48,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_49                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(49,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_50                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(50,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_51                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(51,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_52                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(52,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_53                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(53,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_54                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(54,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_55                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(55,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_56                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(56,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_57                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(57,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_58                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(58,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_59                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(59,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_60                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(60,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_61                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(61,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_62                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(62,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_63                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(63,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_64                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(64,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_65                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(65,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_66                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(66,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_67                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(67,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_68                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(68,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_69                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(69,1,1), count=c( 1,-1,-1) ) ),	 

 	  scattering_weights_70                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(70,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_71                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(71,1,1), count=c( 1,-1,-1) ) ),

 	  scattering_weights_72                               = as.vector( ncvar_get( id, "support_data/scattering_weights", start=c(72,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_01                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 1,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_02                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 2,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_03                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 3,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_04                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 4,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_05                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 5,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_06                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 6,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_07                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 7,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_08                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 8,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_09                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c( 9,1,1), count=c( 1,-1,-1) ) ),	  	             

 	  gas_profile_10                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(10,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_11                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(11,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_12                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(12,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_13                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(13,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_14                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(14,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_15                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(15,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_16                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(16,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_17                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(17,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_18                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(18,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_19                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(19,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_20                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(20,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_21                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(21,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_22                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(22,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_23                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(23,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_24                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(24,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_25                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(25,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_26                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(26,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_27                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(27,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_28                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(28,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_29                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(29,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_30                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(30,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_31                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(31,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_32                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(32,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_33                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(33,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_34                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(34,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_35                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(35,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_36                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(36,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_37                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(37,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_38                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(38,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_39                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(39,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_40                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(40,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_41                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(41,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_42                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(42,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_43                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(43,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_44                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(44,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_45                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(45,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_46                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(46,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_47                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(47,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_48                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(48,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_49                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(49,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_50                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(50,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_51                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(51,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_52                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(52,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_53                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(53,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_54                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(54,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_55                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(55,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_56                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(56,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_57                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(57,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_58                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(58,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_59                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(59,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_60                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(60,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_61                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(61,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_62                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(62,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_63                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(63,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_64                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(64,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_65                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(65,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_66                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(66,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_67                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(67,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_68                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(68,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_69                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(69,1,1), count=c( 1,-1,-1) ) ),	 

 	  gas_profile_70                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(70,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_71                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(71,1,1), count=c( 1,-1,-1) ) ),

 	  gas_profile_72                                      = as.vector( ncvar_get( id, "support_data/gas_profile", start=c(72,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_01                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 1,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_02                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 2,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_03                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 3,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_04                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 4,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_05                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 5,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_06                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 6,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_07                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 7,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_08                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 8,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_09                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c( 9,1,1), count=c( 1,-1,-1) ) ),	 

 	  temperature_profile_10                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(10,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_11                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(11,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_12                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(12,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_13                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(13,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_14                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(14,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_15                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(15,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_16                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(16,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_17                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(17,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_18                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(18,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_19                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(19,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_20                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(20,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_21                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(21,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_22                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(22,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_23                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(23,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_24                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(24,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_25                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(25,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_26                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(26,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_27                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(27,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_28                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(28,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_29                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(29,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_30                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(30,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_31                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(31,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_32                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(32,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_33                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(33,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_34                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(34,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_35                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(35,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_36                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(36,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_37                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(37,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_38                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(38,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_39                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(39,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_40                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(40,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_41                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(41,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_42                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(42,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_43                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(43,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_44                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(44,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_45                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(45,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_46                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(46,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_47                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(47,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_48                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(48,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_49                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(49,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_50                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(50,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_51                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(51,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_52                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(52,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_53                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(53,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_54                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(54,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_55                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(55,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_56                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(56,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_57                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(57,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_58                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(58,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_59                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(59,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_60                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(60,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_61                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(61,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_62                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(62,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_63                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(63,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_64                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(64,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_65                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(65,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_66                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(66,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_67                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(67,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_68                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(68,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_69                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(69,1,1), count=c( 1,-1,-1) ) ),	 

 	  temperature_profile_70                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(70,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_71                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(71,1,1), count=c( 1,-1,-1) ) ),

 	  temperature_profile_72                              = as.vector( ncvar_get( id, "support_data/temperature_profile", start=c(72,1,1), count=c( 1,-1,-1) ) ),

 	  albedo                                              = as.vector( ncvar_get( id, "support_data/albedo" ) ),                                              

                           amf_total                                           = as.vector( ncvar_get( id, "support_data/amf_total" ) ),

                           amf_diagnostic_flag                                 = as.vector( ncvar_get( id, "support_data/amf_diagnostic_flag" ) ),                                           	 

                           eff_cloud_fraction                                  = as.vector( ncvar_get( id, "support_data/eff_cloud_fraction" ) ),                                  

                           amf_cloud_fraction                                  = as.vector( ncvar_get( id, "support_data/amf_cloud_fraction" ) ),                                  

                           amf_cloud_pressure                                  = as.vector( ncvar_get( id, "support_data/amf_cloud_pressure" ) ),                                  

                           amf_troposphere                                     = as.vector( ncvar_get( id, "support_data/amf_troposphere" ) ),                                     

                           amf_stratosphere                                    = as.vector( ncvar_get( id, "support_data/amf_stratosphere" ) )   

                  )


# New York State only

data = subset(data,is.finite(XNO2t) & lat > 39 & lat < 46 & lon > -81 & lon < -70.5 )


if ( length(data$XNO2t) > 0 ) {

   save(data,file=fout)

}


# library(ggplot2)

# ggplot(data) + geom_tile(aes(x=lon,y=lat,fill=surface_pressure),col=NA)


}

nc_close(id)

}