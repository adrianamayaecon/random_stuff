global copa "$dropbox/traffic_copa"
global data "$copa/data"
global traffic "$data/traffic/california"
*ssc install geodist


use "$traffic/d07_stations_sample", clear
gen day = day(date)
gen month = month(date)
gen year = year(date)
gen dow = dow(date)

preserve
keep stationid latitude longitude
duplicates drop
geodist 34.1613 -118.1676 latitude longitude, gen(dist_to_stadium)
xtile buffer = dist_to_stadium, nq(5)
gen stations = 1
set obs `=_N+1'
replace stationid = 99 if stationid==.
replace latitude = 34.1613 if stationid==99
replace longitude = -118.1676 if stationid==99
gen stadium = 1 if stationid==99

save "$copa/data/buffers-rosebowl", replace

keep if stations == 1
tempfile buffers 
save `buffers', replace
restore
merge m:1 stationid using `buffers', nogen

save "$copa/data/reg-data-rosebowl", replace
