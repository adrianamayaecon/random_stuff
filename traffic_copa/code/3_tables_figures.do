global copa "$dropbox/traffic_copa"
global data "$copa/data"
global traffic "$data/traffic/california"
*ssc install palettes
*ssc install colrspace

local buffersmap = 0
local effectmap = 1
local fig1 = 0
local figa1 = 0
local fig2 = 0
local regtable = 0
local impact = 0

if `buffersmap' == 1{
	use "$copa/data/buffers-rosebowl", clear
	colorpalette HSV qualitative, n(5) nograph
	twoway (scatter latitude longitude if buffer==1, mcolor("`r(p10)'") msize(vsmall)) ///
	 (scatter latitude longitude if buffer==2, mcolor("`r(p9)'") msize(vsmall)) ///
	 (scatter latitude longitude if buffer==3, mcolor("`r(p8)'") msize(vsmall)) ///
	 (scatter latitude longitude if buffer==4, mcolor("`r(p7)'") msize(vsmall)) ///
	 (scatter latitude longitude if stadium==1, mcolor(red) msize(large)), ///
	 xlabel(minmax, nolabels noticks) xtitle("") ///
	 ylabel(minmax, nolabels noticks) ytitle("") ///
	 legend(off) scheme(s1color) title("Rose Bowl") subtitle("Pasedena, California")
	graph export "$copa/figures/rosebowl.png", replace

}

if `effectmap' == 1{
    use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)

	keep if month == 6 & year == 2016
	gen gamedays = inlist(day, 4, 7, 9)

	preserve
	keep if time == clock("17:00", "hm") & inlist(dow, 2, 4, 6) & gamedays==0
	collapse (mean) delaybl=delay_60, by(stationid time)
	tempfile baseline
	save `baseline', replace
	restore
	
	keep if gamedays==1
	collapse (mean) delay_60, by(stationid latitude longitude time)
	
	merge m:1 stationid time using `baseline', keep(3) nogen

	gen change = delay_60 - delaybl
	keep if time == clock("17:00", "hm")
	xtile speedcat = change, nq(5)

	colorpalette red yellow green, ipolate(5)
	twoway (scatter latitude longitude if speedcat==5, mcolor("`r(p5)'") msize(tiny)) ///
	 (scatter latitude longitude if speedcat==4, mcolor("`r(p4)'") msize(tiny)) ///
	 (scatter latitude longitude if speedcat==3, mcolor("`r(p3)'") msize(tiny)) ///
	 (scatter latitude longitude if speedcat==2, mcolor("`r(p2)'") msize(tiny)) ///
	 (scatter latitude longitude if speedcat==1, mcolor("`r(p1)'") msize(tiny)), ///
	 xlabel(minmax, nolabels noticks) xtitle("") ///
	 ylabel(minmax, nolabels noticks) ytitle("") ///
	 legend(off) scheme(s1color) title("Rose Bowl") subtitle("Pasedena, California")
}


if `fig1' == 1{
	use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)
	keep if month == 6 & year == 2016
	gen gamedays = inlist(day, 4, 7, 9)
	
	merge m:1 stationid using "$copa/data/buffers-rosebowl", nogen
	keep if inlist(buffer, 1)
	
	collapse (mean) speed delay_60, by(gamedays time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset gamedays time
	
	twoway (area speedmax time if tin(19:00, 21:00), bcolor(gs15) base(`speedmin')) ///
	(line speed time if gamedays == 0, lpattern(dash)) ///
	(line speed time if gamedays == 1), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Speed") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "All Other Days") lab(3 "Game Days") rows(1) order(3 2 1)) ///
	name(speed, replace)
	
	graph export "$copa/figures/speed-rosebowl.png", replace
	
	twoway (area delaymax time if tin(19:00, 21:00), bcolor(gs15) base(0)) ///
	(line delay_60 time if gamedays == 0, lpattern(dash)) ///
	(line delay_60 time if gamedays == 1), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Delay") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "All Other Days") lab(3 "Game Days") rows(1) order(3 2 1)) ///
	name(delay, replace)
	
	graph export "$copa/figures/delay-rosebowl.png", replace

*****************************************************************************
*****************************************************************************	

	use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)
	keep if month == 6 & year == 2016 & dow == 6
	gen game = inlist(day, 4)
	
	merge m:1 stationid using "$copa/data/buffers-rosebowl", nogen
	keep if inlist(buffer, 1)
	
	preserve
	collapse (mean) speed delay_60, by(day time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset day time
	
	twoway (area speedmax time if tin(19:00, 21:00), bcolor(gs15) base(`speedmin')) ///
	(line speed time if day == 25, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 18, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 11, lpattern(dot) lcolor(red)) ///
	(line speed time if day == 4, lcolor(gs0)), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Speed") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Saturdays") lab(3 "Game 1") rows(1) order(3 2 1)) ///
	name(speed, replace)
	
	graph export "$copa/figures/speed-rosebowl-game1.png", replace
	
	restore
	collapse (mean) speed delay_60, by(game time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset game time
	
	twoway (area delaymax time if tin(19:00, 21:00), bcolor(gs15) base(0)) ///
	(line delay_60 time if game == 0, lpattern(dash)) ///
	(line delay_60 time if game == 1), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Delay") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Saturdays") lab(3 "Game 1") rows(1) order(3 2 1)) ///
	name(delay, replace)
	
	graph export "$copa/figures/delay-rosebowl-game1.png", replace
	
*****************************************************************************
*****************************************************************************	

	use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)
	keep if month == 6 & year == 2016 & dow == 2
	gen game = inlist(day, 7)

	
	merge m:1 stationid using "$copa/data/buffers-rosebowl", nogen
	keep if inlist(buffer, 1)
	
	preserve
	collapse (mean) speed delay_60, by(day time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset day time
	
	twoway (area speedmax time if tin(19:00, 21:00), bcolor(gs15) base(`speedmin')) ///
	(line speed time if day == 28, lpattern(dot) lcolor(red)) ///
	(line speed time if day == 21, lpattern(dot) lcolor(blue)) ///
	(line speed time if day == 14, lpattern(dot) lcolor(green)) ///
	(line speed time if day == 7,  lcolor(gs0)), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Speed") scheme(s1color) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Tuesdays") lab(3 "Game 2") rows(1) order(3 2 1)) ///
	name(speed, replace)
	
	graph export "$copa/figures/speed-rosebowl-game2.png", replace
	
	restore
	collapse (mean) speed delay_60, by(game time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset game time
	
	twoway (area delaymax time if tin(19:00, 21:00), bcolor(gs15) base(0)) ///
	(line delay_60 time if game == 0, lpattern(dash)) ///
	(line delay_60 time if game == 1), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Delay") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Tuesdays") lab(3 "Game 2") rows(1) order(3 2 1)) ///
	name(delay, replace)
	
	graph export "$copa/figures/delay-rosebowl-game2.png", replace

	
	
*****************************************************************************
*****************************************************************************	

	use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)
	keep if month == 6 & year == 2016 & dow == 4
	gen game = inlist(day, 9)

	
	merge m:1 stationid using "$copa/data/buffers-rosebowl", nogen
	keep if inlist(buffer, 1)
	
	preserve
	collapse (mean) speed delay_60, by(day time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset day time
	
	twoway (area speedmax time if tin(19:00, 21:00), bcolor(gs15) base(`speedmin')) ///
	(line speed time if day == 30, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 23, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 16, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 2, lpattern(dot) lcolor(gs3)) ///
	(line speed time if day == 9, lcolor(gs0)), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Speed") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Thursdays") lab(3 "Game 3") rows(1) order(3 2 1)) ///
	name(speed, replace)
	
	graph export "$copa/figures/speed-rosebowl-game3.png", replace
	
	restore
	collapse (mean) speed delay_60, by(game time)
	sum speed 
	gen speedmax = r(max) + 3
	local scalar speedmin = r(min)
	sum delay_60
	gen delaymax = r(max)
	xtset game time
	
	twoway (area delaymax time if tin(19:00, 21:00), bcolor(gs15) base(0)) ///
	(line delay_60 time if game == 0, lpattern(dash)) ///
	(line delay_60 time if game == 1), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Delay") scheme(s1mono) title("") ///
	legend(lab(1 "Game Time") lab(2 "Other Thursdays") lab(3 "Game 3") rows(1) order(3 2 1)) ///
	name(delay, replace)
	
	graph export "$copa/figures/delay-rosebowl-game3.png", replace

	
}

if `figa1' == 1{
	use "$traffic/d07_stations_sample", clear
	gen day = day(date)
	gen month = month(date)
	gen year = year(date)
	gen dow = dow(date)
	keep if month == 6 & year == 2016
	
	merge m:1 stationid using "$copa/data/buffers-rosebowl", nogen
	
	collapse (mean) delay_60, by(dow time)
	xtset dow time
	
	colorpalette HCL viridis, n(8) nograph
	twoway (line delay_60 time if dow == 0, lcolor("`r(p1)'") lpattern("_#")) ///
	(line delay_60 time if dow == 1, lcolor("`r(p2)'") lpattern("_#.")) ///
	(line delay_60 time if dow == 2, lcolor("`r(p3)'") lpattern("_#..")) ///
	(line delay_60 time if dow == 3, lcolor("`r(p4)'") lpattern("_#...")) ///
	(line delay_60 time if dow == 4, lcolor("`r(p5)'") lpattern("_#....")) ///
	(line delay_60 time if dow == 5, lcolor("`r(p6)'") lpattern("_#.....")) ///
	(line delay_60 time if dow == 6, lcolor("`r(p7)'") lpattern("_#......")), ///
	tlabel(0 (`=clock("06:00", "hm")') `=clock("23:59", "hm")', format(%tc+HH+:+MM)) ///
	xtitle("") ytitle("Delay") scheme(s1color) title("") ///
	legend(order(1 "Sunday" 2 "Monday" 3 "Tuesday" 4 "Wednesday" 5 "Thursday" 6 "Friday" 7 "Saturday") rows(7) ring(0) position(2) size(tiny) symysize(1pt) symxsize(7.2pt)) ///
	name(delay, replace)
	
	graph export "$copa/figures/delay-bydow-rosebowl.png", replace
}


if `fig2' == 1{
	use "$copa/data/reg-data-rosebowl", clear
	keep if month == 6 & year == 2016
	drop if buffer == 5 | buffer==.
	gen gameday = inlist(day, 4, 7, 9) 
	gen gametime = inrange(time, tc(15:00), tc(23:00))
	gen before = inrange(time, tc(15:00), tc(18:00))
	gen during = inrange(time, tc(19:00), tc(21:00))
	gen after = inrange(time, tc(22:00), tc(23:00))
	gen hour = hh(time)


	gen vclose = inlist(buffer, 1)
	gen close = inlist(buffer, 2)
	gen far = inlist(buffer, 3)
	gen vfar = inlist(buffer, 4)
	
	label variable gameday "Game Day"
	label variable gametime "(3pm-11pm)"
	label variable before "(3pm-6pm)"
	label variable during "(7pm-9pm)"
	label variable after "(10pm-11pm)"
	label variable vclose "Very close"
	label variable close "Close"
	label variable far "Far"
	
	foreach group in "vclose" "close" "far" "vfar"{
		eststo `group': reghdfe speed hour#1.gameday if `group'==1, absorb(stationid#time#dow) vce(cluster stationid)
	}
	
	coefplot vclose || close || far || vfar, vertical drop(_cons) yline(0) scheme(s1mono) ///
		xlab(6 "6:00 a.m." 11 "11:00 a.m." 16 "4:00 p.m." 21 "9:00 p.m.") ///
		addplot(scatteri -2 19 -2 21 8 21 8 19, recast(area) lwidth(none) fcolor(gs0%25))
		graph export "$copa/figures/delay-byhour-rosebowl.png", replace
		
************************************************************************
	use "$copa/data/reg-data-rosebowl", clear
	keep if month == 5 & year == 2015
	drop if buffer == 5 | buffer==.
	gen gameday = inlist(day, 16, 19, 21) 
	gen gametime = inrange(time, tc(15:00), tc(23:00))
	gen before = inrange(time, tc(15:00), tc(18:00))
	gen during = inrange(time, tc(19:00), tc(21:00))
	gen after = inrange(time, tc(22:00), tc(23:00))
	gen hour = hh(time)


	gen vclose = inlist(buffer, 1)
	gen close = inlist(buffer, 2)
	gen far = inlist(buffer, 3)
	gen vfar = inlist(buffer, 4)
	
	label variable gameday "Game Day"
	label variable gametime "(3pm-11pm)"
	label variable before "(3pm-6pm)"
	label variable during "(7pm-9pm)"
	label variable after "(10pm-11pm)"
	label variable vclose "Very close"
	label variable close "Close"
	label variable far "Far"
	
	foreach group in "vclose" "close" "far" "vfar"{
		eststo `group': reghdfe speed hour#1.gameday if `group'==1, absorb(stationid#time#dow) vce(cluster stationid)
	}
	
	coefplot vclose || close || far || vfar, vertical drop(_cons) yline(0) scheme(s1mono) ///
		xlab(6 "6:00 a.m." 11 "11:00 a.m." 16 "4:00 p.m." 21 "9:00 p.m.") ///
		addplot(scatteri -2 19 -2 21 8 21 8 19, recast(area) lwidth(none) fcolor(gs0%25))
		graph export "$copa/figures/delay-byhour-placebo-rosebowl.png", replace
}

if `regtable' == 1{
    eststo clear
	use "$copa/data/reg-data-rosebowl", clear
	drop if buffer == 5 | buffer==.
	gen gameday = inlist(day, 4, 7, 9) 
	gen gametime = inrange(time, tc(15:00), tc(23:00))
	gen before = inrange(time, tc(15:00), tc(18:00))
	gen during = inrange(time, tc(19:00), tc(21:00))
	gen after = inrange(time, tc(22:00), tc(23:00))

	gen vclose = inlist(buffer, 1)
	gen close = inlist(buffer, 2)
	gen far = inlist(buffer, 3)
	
	label variable gameday "Game Day"
	label variable gametime "(3pm-11pm)"
	label variable before "(3pm-6pm)"
	label variable during "(7pm-9pm)"
	label variable after "(10pm-11pm)"
	label variable vclose "Very close"
	label variable close "Close"
	label variable far "Far"
	
	
	eststo: reghdfe delay_60 1.gameday#1.gametime, absorb(stationid dow time) vce(cluster stationid)
	estadd local station "YES"
	estadd local dow "YES"
	estadd local dom " "
	estadd local hour "YES"
	estadd local sdt " "
	estadd local st " "
	
	eststo: reghdfe delay_60 1.gameday#1.gametime, absorb(stationid#time#dow) vce(cluster stationid)
	estadd local station " "
	estadd local dow " "
	estadd local dom " "
	estadd local hour " "
	estadd local sdt "YES"
	estadd local st " "

	
	eststo: reghdfe delay_60 1.gameday#1.gametime, absorb(stationid day time) vce(cluster stationid)
	estadd local station "YES"
	estadd local dow " "
	estadd local dom "YES"
	estadd local hour "YES"
	estadd local sdt " "
	estadd local st " "

	
	eststo: reghdfe delay_60 1.gameday#1.gametime, absorb(stationid#time day) vce(cluster stationid)
	estadd local station " "
	estadd local dow " "
	estadd local dom "YES"
	estadd local hour " "
	estadd local sdt " "
	estadd local st "YES"

	
	qui esttab using "$copa/tables/reg-gametime-rosebowl.tex", label replace noconstant ///
		nobase title("") b(%5.2f) se(%5.2f) ///
		stats(station dow dom hour st sdt N r2 F, fmt(0 0 0 0 0 0 %12.0fc %5.3fc) ///
			labels("Station" "Day-of-week (DoW)" "Day-of-month (DoM)" "Hour" "StationXHour" "StaionXDoWXHour" "Observations" "R-sq" "F-stat")) ///
		nomtitles interaction("$\times$") ///
		substitute("=1" "" "X" "$\times$" "-sq" "$^2$")
	eststo clear
	
*****************************************************************************	

}


if `impact' == 1{
    use "$copa/data/reg-data-rosebowl", clear
	drop if buffer == 5 | buffer==.
	gen gameday = inlist(day, 4, 7, 9) 
	gen gametime = inrange(time, tc(15:00), tc(23:00))
	*reghdfe delay_60 1.gameday 1.gameday#1.gametime, absorb(stationid dow time) vce(cluster stationid)
	
	
	*local bvclose = r(table)[1, 2]
	*local bclose = r(table)[1, 3]
	*local bfar = r(table)[1, 4]

	keep if lane_type == "OR" & inrange(buffer, 1, 3) & gametime == 1 & gameday == 1
	*collapse (sum) total_flow, by(buffer)
	collapse (sum) total_flow
	
	*gen delay = `bvclose' if buffer==1
	*replace delay = `bclose' if buffer==2
	*replace delay = `bfar' if buffer==3
	gen delay = 1.94
	
	replace total_flow = total_flow - 190000
	
	gen miles = 5
	gen hourlycost_lower = 12.5
	gen hourlycost_upper = 24.40
	gen totalcost_lower = ((total_flow * miles * delay)/60) * hourlycost_lower
	gen totalcost_upper = ((total_flow * miles * delay)/60) * hourlycost_upper
	
	*collapse (sum) total*
}

