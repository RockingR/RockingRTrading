###1. get libraries ready for use
###########################################################################
#############################################################################
require(quantstrat)
require(devtools)
require(IKTrading)
require(DSTrading)

###2. Get data xts from yahoo
########################################################################3
##############################################################################3

getSymbols(Symbols = "SPY", from = "1998-01-01", to = "2012-12-31")

head(SPY)
tail(SPY)

class(SPY)
str(SPY)


###3. how to get the same type of data based on non-online data
#######################################################################
########################################################################

getwd() # get data into csv file and into working directory
y1501 <- read.csv("y1501.csv")
class(y1501) # check data frame

str(y1501) 
# check date data-- 
# 1. if date is index, not column, and is POSIX class, then use xts(x) directly
# 2. if date is column, like factor, not index or row names, not POSIX class, not character class, then use xts(x, order.by = )

########################
# # a wrong way to turn a dataframe into xts
# y1501.xts <- xts(y1501) # this code has error, as it is not time-based object
# 
# # to deal with its non-time-based object, we use order.by = 
# y1501_xts <- xts(y1501, order.by=as.Date(y1501$Date))
# head(y1501_xts) # everything is chacter class not num, all date and all prices
# str(y1501_xts)  # the problem is all data is character class
# class(y1501_xts) # now it is a xts
######################

# to solve --- use data columns as x, use date column as posix class in order.by
y1501_xts <- xts(y1501[,-1], order.by=as.POSIXct(y1501$Date))
head(y1501_xts)
str(y1501_xts)  # the problem is all data is character class
class(y1501_xts) # now it is a xts
class(index(y1501_xts))

############################################################################
###############################################################################
# how to understand the usage of xts and converts between xts and dataframe?
# ?xts
# # how to use xts
# 
# # how to turn matrix into xts
# data(sample_matrix)
# 
# # inspect the nature of the matrix
# class(sample_matrix) # include date info, and OHLC data
# head(sample_matrix)
# str(sample_matrix)  # date is row names in character, not Date class, not a column
# str(sample_matrix[,1]) # date is not a col but row names or index
# 
# # turn matrix into xts
# sample.xts <- as.xts(sample_matrix, descr='my new xts object') # description of data
# 
# class(sample.xts)
# str(sample.xts) # date is still index number, not a col, but POSIX classes
# 
# head(sample.xts)  # attribute 'descr' hidden from view
# attr(sample.xts,'descr') # Check its description attribute
# 
# #### both matrix and xts above using date data as index, only matrix date data is character class, xts's data is POSIX class
# 
# ## how to use xts to subset by time
# sample.xts['2007']  # all of 2007
# sample.xts['2007-03/']  # March 2007 to the end of the data set
# sample.xts['2007-03/2007']  # March 2007 to the end of 2007
# sample.xts['/'] # the whole data set
# sample.xts['/2007'] # the beginning of the data through 2007
# sample.xts['2007-01-03'] # just the 3rd of January 2007
# #######################################################################
# ######################################################################


# graph and zoom SPY
chart_Series(SPY)

# graph and zoom y1501
chart_Series(y1501_xts)
zoom_Chart("2008")
y1501_xts["2008"] # looking into the data, we know red referring to falling price
zoom_Chart("2008-05-01::2008-12-31")
chart_Series(y1501_xts, subset="2008-05-01::2008-12-31")
zoom_Chart("2008-01")
?chart_Series # x is a xts

# graph indicators to the existing main graph
sma <- SMA(x = Cl(SPY), n = 200)
# head(sma)
# tail(sma)
# Cl(SPY)
# SMA   # to check out the function structure
# args(SMA)  # to check out all the arguments
add_TA(sma, on = 1, lwd= 1.5, col = "green") # graph TA onto existing graph

# graph sma indicators for Y1501
sma.5 <- SMA(x = Cl(y1501_xts), n = 5)
sma.13 <- SMA(x = Cl(y1501_xts), n = 13)
sma.21 <- SMA(x = Cl(y1501_xts), n = 21)
sma.34 <- SMA(x = Cl(y1501_xts), n = 34)
sma.55 <- SMA(x = Cl(y1501_xts), n = 55)
sma.89 <- SMA(x = Cl(y1501_xts), n = 89)

add_TA(sma.5, on = 1, lwd= 1.5, col = "green") # graph TA onto existing graph
add_TA(sma.13, on = 1, lwd= 1.5, col = "gray") # graph TA onto existing graph
add_TA(sma.21, on = 1, lwd= 1.5, col = "cyan") # graph TA onto existing graph
add_TA(sma.34, on = 1, lwd= 1.5, col = "yellow") # graph TA onto existing graph
add_TA(sma.55, on = 1, lwd= 1.5, col = "blue") # graph TA onto existing graph
add_TA(sma.89, on = 1, lwd= 1.5, col = "red") # graph TA onto existing graph

#### how to use price data extraction functions
# #####################################################
# ?Cl() # the data has to be xts, and include either OHLC or OHLCA or OHLC with other columns like volume
# ## examples
# x <- y1501_xts
# head(Op(x))
# head(Hi(x))
# Lo(x)
# Cl(x)
# head(Vo(x))
# head(Ad(x))
# head(x)
# 
# head(seriesHi(x)) # the highest price
# seriesLo(x) # the lowest price
# seriesIncr(x, thresh=0, diff.=1L) # ?thresh and diff.???????
# # they return logical vector for indexing later.
# seriesDecr(x, thresh=0, diff.=1L)
# 
# head(OpCl(x)) # percentage diff of open price and close price
# 
# ClCl(x)
# HiCl(x)
# LoCl(x)
# LoHi(x)
# OpHi(x)
# OpLo(x)
# OpOp(x)
# 
# head(HLC(x))
# OHLC(x)
# OHLCV(x)
###################################################################

