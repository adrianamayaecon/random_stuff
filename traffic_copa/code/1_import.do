global copa "$dropbox/traffic_copa"
global traffic "$dropbox/caltrans_pems/trafficdata/d07_text_station_hour"
global data "$dropbox/traffic_copa/data/traffic/california"

*****************************************************************
*****************************************************************
*****************************************************************
*****************************************************************
/*/ Import META data for stations
* Only needs to run once. Other projects use this code too.
cd "$traffic"
local filelist : dir . files "*_meta*.txt"
local n = 1
foreach file in `filelist'{
	import delimited `"`file'"', clear
	gen ymd = substr("`file'",15,10)
	gen start_date = date(ymd, "YMD")
	format start_date %td
	gen year = yofd(start_date)
	rename id stationid
	if `n' == 1 {
		save "d07_stations_meta", replace
		sleep 500
	} 
	else{
		append using "d07_stations_meta"
		duplicates drop
		save "d07_stations_meta", replace
		sleep 500
	}
	local ++n
}



*/
*****************************************************************
*****************************************************************
*****************************************************************
*****************************************************************
*****************************************************************

// Keep all monitors that have consistent characteristics from 2015-2017
use "$traffic/d07_stations_meta", clear
keep stationid district county city latitude longitude fwy dir type year
keep if inrange(year, 2015, 2017)
duplicates drop
duplicates tag stationid latitude longitude, gen(consistent)
keep if consistent==2
*Consistent
drop year consistent
duplicates drop
save "$data/d07_stations_meta_consistent", replace


*Station hourly data 
local n = 1
foreach yr of numlist 2015/2017{
	foreach mo in "05" "06"{

		import delimited "$traffic/d07_text_station_hour_`yr'_`mo'.txt", clear 

		rename (v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18) (timestamp stationid district route direc lane_type station_length samples observed total_flow occupancy speed delay_35 delay_40 delay_45 delay_50 delay_55 delay_60)


		local a=19
			foreach i of numlist 1/14{
				if `a'<43 {
					rename v`a' local_flow_`i'
					local a=`a'+3 
					}
				else {
					continue, break
					}
			}

		local a=20
			foreach i of numlist 1/14{
				if `a'<43 {
					rename v`a' local_occ_`i'
					local a=`a'+3 
					}
				else {
					continue, break
					}
			}

		local a=21
			foreach i of numlist 1/14{
				if `a'<43 {
					rename v`a' local_speed_`i'
					local a=`a'+3 
					}
				else {
					continue, break
					}
			}
		merge m:1 stationid using "$data/d07_stations_meta_consistent", keep(3) nogen
		keep if county == 37
		gen double datetime=clock(timestamp, "MDYhms")
		gen date = dofc(datetime)
		gen ym = ym(year(date), month(date))
		gen double time = hms(hh(datetime), mm(datetime), ss(datetime))
		format date %td
		format ym %tm
		format time %tcHH:MM
		format datetime %tcNN/DD/CCYY_HH:MM:SS
		drop timestamp
		if `n'==1 {
			save "$data/d07_stations_sample", replace
			}
		else {
			append using "$data/d07_stations_sample"
			save "$data/d07_stations_sample", replace
			}
		display as text _dup(59) "-"
		display as error "`mo', `yr' finished!" 
		display as text _dup(59) "-"
		local ++n
}
}