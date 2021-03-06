# RUnit tests
# 
# resource 4334-bgaj on the Socrata demo site is USGS Earthquakes for 2012-11-01 API School Demo
#
# Author: Hugh 2013-07-15
###############################################################################

library('RUnit')

source("R/RSocrata.R")

test.posixifyLong <- function() {
	dt <- posixify("09/14/2012 10:38:01 PM")
	checkEquals("POSIXlt", class(dt)[1], "first data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(22, dt$hour, "hours")
	checkEquals(38, dt$min, "minutes")
	checkEquals(1, dt$sec, "seconds")
}

test.posixifyShort <- function() {
	dt <- posixify("09/14/2012")
	checkEquals("POSIXlt", class(dt)[1], "first data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(0, dt$hour, "hours")
	checkEquals(0, dt$min, "minutes")
	checkEquals(0, dt$sec, "seconds")
}

test.readSocrataCsv <- function() {
	df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(9, ncol(df), "columns")
}

test.readSocrataJson <- function() {
	df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.json')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(11, ncol(df), "columns")
}

test.readSocrataNoScheme <- function() {
	checkException(read.socrata('soda.demo.socrata.com/resource/4334-bgaj.csv'))
}

test.readSoQL <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=region')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(1, ncol(df), "columns")
}

test.readSoQLColumnNotFound <- function() {
	# SoQL API uses field names, not human names
	checkException(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=Region'))
}

test.readPrivate <- function() {
  checkException(read.socrata('http://data.cityofchicago.org/resource/j8vp-2qpg.json'))
}

test.readSocrataHumanReadable <- function() {
	df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(9, ncol(df), "columns")
}

test.readSocrataFormatNotSupported <- function() {
	# Unsupported data formats
	checkException(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.xml'))
}

test.readSocrataCalendarDateLong <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv')
	dt <- df$Datetime[1] # "2012-09-14 22:38:01"
	checkEquals("POSIXlt", class(dt)[1], "data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(22, dt$hour, "hours")
	checkEquals(38, dt$min, "minutes")
	checkEquals(1, dt$sec, "seconds")
}

test.readSocrataCalendarDateShort <- function() {
	df <- read.socrata('http://data.cityofchicago.org/resource/y93d-d9e3.csv?$order=debarment_date')
	dt <- df$DEBARMENT.DATE[1] # "05/21/1981"
	checkEquals("POSIXlt", class(dt)[1], "data type of a date")
	checkEquals(81, dt$year, "year")
	checkEquals(5, dt$mon + 1, "month")
	checkEquals(21, dt$mday, "day")
	checkEquals(0, dt$hour, "hours")
	checkEquals(0, dt$min, "minutes")
	checkEquals(0, dt$sec, "seconds")
}

test.isFourByFour <- function() {
	checkTrue(isFourByFour("4334-bgaj"), "ok")
	checkTrue(!isFourByFour("4334c-bgajc"), "11 characters instead of 9")
	checkTrue(!isFourByFour("433-bga"), "7 characters instead of 9")
	checkTrue(!isFourByFour("433-bgaj"), "3 characters before dash instead of 4")
	checkTrue(!isFourByFour("4334-!gaj"), "non-alphanumeric character")
}

test.isFourByFourUrl <- function() {
	checkException(read.socrata("https://soda.demo.socrata.com/api/views/4334c-bgajc"), "11 characters instead of 9")
	checkException(read.socrata("https://soda.demo.socrata.com/api/views/433-bga"), "7 characters instead of 9")
	checkException(read.socrata("https://soda.demo.socrata.com/api/views/433-bgaj"), "3 characters before dash instead of 4")
	checkException(read.socrata("https://soda.demo.socrata.com/api/views/4334-!gaj"), "non-alphanumeric character")
}

test.readSocrataInvalidUrl <- function() {
	checkException(read.socrata("a.fake.url.being.tested"), "invalid url")
}

test.readSocrataToken <- function(){
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv', app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns")  
}

test.readSocrataHumanReadableToken <- function(){
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj', app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns")  
}

test.readAPIConflict <- function(){
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns")
  # Check that function is calling the API token specified in url
  checkTrue(substr(validateUrl('https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94)=="ew2rEMuESuzWPqMkyPfOSGJgE")
}

test.readAPIConflictHumanReadable <- function(){
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns")
  # Check that function is calling the API token specified in url
  checkTrue(substr(validateUrl('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94)=="ew2rEMuESuzWPqMkyPfOSGJgE")
}

test.incorrectAPIQuery <- function(){
  # The query below is missing a $ before app_token.
  checkException(read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  # Check that it was only because of missing $  
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns") 
}

test.incorrectAPIQueryHumanReadable <- function(){
  # The query below is missing a $ before app_token.
  checkException(read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  # Check that it was only because of missing $  
  df <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE")
  checkEquals(1007, nrow(df), "rows")
  checkEquals(9, ncol(df), "columns") 
}

test.lsSocrata <- function() {
    # Makes some potentially erroneous assumptions about availability
    # of soda.demo.socrata.com
    df <- ls.socrata("https://soda.demo.socrata.com")
    checkEquals(TRUE, nrow(df) > 0)
    # Test comparing columns against data.json specifications:
    # https://project-open-data.cio.gov/v1.1/schema/
    core_names <- as.character(c("issued", "modified", "keyword", "landingPage", "theme", 
                                 "title", "accessLevel", "distribution", "description", 
                                 "identifier", "publisher", "contactPoint", "license"))
    checkEquals(as.logical(rep(TRUE, length(core_names))), core_names %in% names(df))
    # Check that all names in data.json are accounted for in ls.socrata return
    checkEquals(as.logical(rep(TRUE, length(names(df)))), names(df) %in% c(core_names))
}

test.lsSocrataInvalidURL <- function() {
    checkException(read.socrata("a.fake.url.being.tested"), "invalid url")
}

test.suite <- defineTestSuite("test Socrata SODA interface",
                              dirs = file.path("R/tests"),
                              testFileRegexp = '^test.*\\.R')

runAllTests <- function() { # Run during development, will complete regardless of errors
	test.result <- runTestSuite(test.suite)
	printTextProtocol(test.result) 
}

runAllTestsCI <- function() { # Ran for continuous integration tests, will stop if error found
  test.result <- runTestSuite(test.suite)
  if(getErrors(test.result)$nErr > 0 | getErrors(test.result)$nFail > 0) stop("TEST HAD ERRORS!")
}