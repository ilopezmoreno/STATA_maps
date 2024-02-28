clear


* Tutorial by Asjad Naqvi 
* https://us02web.zoom.us/rec/play/JcexLNAu9WyIzyF_dxt8enHGClKn3rVmZPe5YIAAz_cRTJzGqWUYewS3GJVd59yKwuMZHk4kxDA75Ko.d8Vwi0fsDIhSiYst?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FShbNfJMyUmvvBlKa97cSX-eQe9Suc953RR0FlWrrS-wdXO8gLuigOEoZetZUKchS.kiMLXaVYqYYK5uei






// Step 1: Install packagers

ssc install spmap, replace 		// the core package
ssc install geo2xy, replace 	// for projections
ssc install palettes, replace 	// for colors
ssc install colrspace, replace	

ssc install schemepack, replace // optional
set scheme white_tableau

graph set window fontface "Arial Narrow"

help spmap




// Step 2: get the data

* Download the official World Bank boundaries shapefile here: 
* https://datacatalog.worldbank.org/search/dataset/0038272





// Step 3: set up the data

global root "C:/Users/d57917il/Documents/GitHub/STATA_maps"

cd "$root"

capture mkdir "maps"

dir

spshape2dta WB_countries_Admin0_10m, saving(world) replace

use world
scatter _CY _CX

spmap using world_shp, id(_ID)
graph export "$root/maps/1_first_map.png", replace

spmap POP_EST using world_shp, id(_ID)
graph export "$root/maps/2_pop_est.png", replace

use world_shp, clear
scatter _Y _X, msize(tiny)
graph export "$root/maps/3_world_shape.png", replace

	
	replace _X = 180 if _X > 180 & _X!=. 
	geo2xy _Y _X, proj(web_mercator) replace
	compress
	save world_shp2.dta, replace
	
	
use world, clear

spmap using world_shp, id(_ID)
graph export "$root/maps/4_world_shp.png", replace

spmap using world_shp2, id(_ID)
graph export "$root/maps/5_world_shp2.png", replace	





// Step 4: Let's make maps! 

// Generate GDP per capita variable
gen gdp_pc = (GDP_MD_EST / POP_EST ) * 1000000

// Kernel density estimate
kdensity gdp_pc
graph export "$root/maps/6_kdensity_gdppc.png", replace



spmap gdp_pc using world_shp2, id(_ID)
graph export "$root/maps/7_world_shp2.png", replace

spmap gdp_pc using world_shp2, id(_ID) fcolor(Blues)
graph export "$root/maps/8_world_shp2_blues.png", replace

spmap gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat)
graph export "$root/maps/9_world_shp2_heat.png", replace
 
spmap gdp_pc using world_shp2, id(_ID) cln(10) clmethod(eqint) fcolor(Heat)
graph export "$root/maps/10_world_shp2_heat_eqint.png", replace

spmap gdp_pc using world_shp2, id(_ID) clm(custom) /// 
clb(0 10000 20000 50000 100000 500000) fcolor(Heat)
graph export "$root/maps/11_world_shp2_heat_clb.png", replace




// Formating legends

format gdp_pc %12.0fc

spmap gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat)
graph export "$root/maps/12_world_shp2_heat_format.png", replace

spmap 	gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat) /// 
		legstyle(2) // "legstyle" removes the brackets for the range of values
graph 	export "$root/maps/13_world_shp2_heat_legstyle.png", replace

spmap 	gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat) legstyle(2) ///
		ocolor(black..) osize(0.1 ..) // 
graph 	export "$root/maps/14_world_shp2_heat_ocolor_osize.png", replace
		
spmap 	gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat) legstyle(2) ///
		legend(pos(7) size(2.5)) 		///
		ocolor(black..) osize(0.1 ..) 	// 
graph 	export "$root/maps/15_world_shp2_heat_legend_size.png", replace
		
spmap 	gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat) legstyle(2) ///
		legend(pos(7) size(2.5) region(fcolor(gs14))) ///
		ocolor(black..) osize(0.1 ..) 	// 
graph 	export "$root/maps/16_world_shp2_heat_fcolor.png", replace		
		
spmap 	gdp_pc using world_shp2, id(_ID) cln(10) fcolor(Heat) legstyle(2) ///
		legend(pos(7) size(2.5) region(fcolor(gs14)))	///
		ocolor(black..) osize(0.1 ..) 					///
		title ("GDP per capita", size(5)) 				/// 
		note("Source: World Bank files", size(3))		//
graph 	export "$root/maps/17_world_shp2_heat_title.png", replace		

		

		
		
		
		
// Customizing colors

help colorpalette

colorpalette viridis, n(10) 
return list



colorpalette viridis, n(10) nograph
local colors `r(p)'
spmap 	gdp_pc using world_shp2, id(_ID) 					/// 
		cln(10) fcolor("`colors'") legstyle(2) 				///
		legend(pos(7) size(2.5) region(fcolor(gs14)))		///
		ocolor(black..) osize(0.1 ..) 						///
		title ("GDP per capita", size(5)) 					/// 
		note("Source: World Bank files", size(3))			//
graph 	export "$root/maps/18_world_viridis.png", replace		
		

		
		
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
spmap 	gdp_pc using world_shp2, id(_ID) 					/// 
		cln(10) fcolor("`colors'") legstyle(2) 				///
		legend(pos(7) size(2.5) region(fcolor(gs14)))		///
		ocolor(black..) osize(0.09 ..) 						///
		title ("GDP per capita", size(5)) 					/// 
		note("Source: World Bank files", size(3))			//		
graph 	export "$root/maps/19_world_viridis_reverse.png", replace		

		
		
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
spmap 	gdp_pc using world_shp2 if REGION_WB=="Sub-Saharan Africa", /// 
		id(_ID) cln(10) fcolor("`colors'") legstyle(2) 			///
		legend(pos(7) size(2.5) region(fcolor(gs14)))			///
		ocolor(black..) osize(0.09 ..) 							///
		title ("GDP per capita in Sub-Saharan Africa", size(5)) /// 
		note("Source: World Bank files", size(3))				//
graph 	export "$root/maps/20_ssafrica_viridis_reverse.png", replace		