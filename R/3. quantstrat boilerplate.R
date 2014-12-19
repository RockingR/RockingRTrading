#####1. every new R.file, the packages need to be required###########
require(quantstrat)

require(devtools)

require(IKTrading)
require(DSTrading)

############ 2. boilerplate copy and paste codes#################

options("getSymbols.warning4.0"=FALSE)
rm(list=ls(.blotter), envir=.blotter)
currency("USD")
Sys.setenv(TZ="UTC")

####3. after the above codes are cope and pasted
#################################
symbols <- "SPY"
suppressMessages(getSymbols(symbols, from="1998-01-01", to="2012-12-31"))
stock(symbols, currency="USD", multiplier=1)
initDate="1990-01-01"

#### all we need to do here is to swap the content with our own etf or symbols

#trade sizing and initial equity settings
tradeSize <- 100000
initEq <- tradeSize*length(symbols)

strategy.st <- portfolio.st <- account.st <- "RSI_10_6"  # "DollarVsATRos"
rm.strat(strategy.st)
initPortf(portfolio.st, symbols=symbols, initDate=initDate, currency='USD')
initAcct(account.st, portfolios=portfolio.st, initDate=initDate, currency='USD',initEq=initEq)
initOrders(portfolio.st, initDate=initDate)
strategy(strategy.st, store=TRUE)  
# stratRSI_10_6 <- strategy(strategy.st, store=TRUE) # apply all indicators, signals and rules to strategy
# stratRSI_10_6

### 4. trading strategy#####################################################
###########################################
# 4.1 close must be above SMA200
# 4.2 buy when RSI2 cross under 10
# 4.3 buy again when RSI2 cross under 6
# 4.4 sell when price cross above SMA5


### 5. set up parameters###################
#######################################################3

nRSI = 2
thresh1 = 10
thresh2 = 6

nSMAexit = 5
nSMAfilter = 200

period = 10
pctATR = .02
maxPct = .04


###6. add indicators to the strategy##########################################################################################

######?add.indicator
add.indicator(strategy.st, name ="lagATR", arguments = list(HLC = quote(HLC(mktdata)), n = period), label = "atrX")

# ?lagATR # args = HLC, n = usually 14, maType, lag = 1 usually, to calc ATR
# ATR is about volatility of price, can help with trade sizing
# 'atrX is the column of ATR of SPY pricing volatility


add.indicator(strategy.st, name = "RSI", arguments = list(price = quote(Cl(mktdata)), n = nRSI), label = "rsi")

# ?RSI # args = price, n, maType
# RSI is for overbought and oversold measures
# how to use RSI functions
#############################################3
# data(ttrc)
# str(ttrc)
# price <- ttrc[,"Close"]
# 
# # Default case
# rsi <- RSI(price)
# str(rsi)
# # Case of one 'maType' for both MAs
# rsiMA1 <- RSI(price, n=14, maType="WMA", wts=ttrc[,"Volume"])
# 
# # Case of two different 'maType's for both MAs
# rsiMA2 <- RSI(price, n=14, maType=list(maUp=list(EMA,ratio=1/5),
#                                        maDown=list(WMA,wts=1:10)))
#########################################################################


add.indicator(strategy.st, name = "SMA", arguments = list(x = quote(Cl(mktdata)), n = nSMAexit), label = "quickMA")

# ?SMA  # args = x, n 
# quickMA = SMA.5

add.indicator(strategy.st, name = "SMA", arguments = list(x = quote(Cl(mktdata)), n = nSMAfilter), label = "filterMA")

# filterMA = SMA.200

### to see the indicator values together with SPY original data
# ############################################################3
out <- applyIndicators(strategy.st, SPY)
tail(out)
names(out) # all the names of cols with SPY...in front
#  [1] "SPY.Open"     "SPY.High"     "SPY.Low"      "SPY.Close"    "SPY.Volume"  
# [6] "SPY.Adjusted" "atr.atrX"     "EMA.rsi"      "SMA.quickMA"  "SMA.filterMA"
# ##################################################################

#### what is mktdata? ##############
#####################################3
# HLC(mktdata)
# HLC(SPY)
# mktdata is just a variable for all xts objects, there is no object as 'mktdata' but only SPY

# strategy("example", store=TRUE) what does it do##############
# what can applyIndicators do ##########################
##############################################################
# getSymbols("SPY", src='yahoo')
# add.indicator('example', 'SMA', arguments=list(x=quote(Ad(SPY)), n=20))
# out <- applyIndicators('example', SPY)
# tail(out)
# head(out,25)
# ?applyIndicators # mktdata = SPY, strategy = "example", ...
# ###########    it will return SPY data together with indicator data ###
# 
# #### give detailed info of strategies and its elements
# ?getStrategy
# getStrategy('example')$indicators
# getStrategy('example')
####################################################
####################################################


####7. add signals ##########
##################################

# 4.1 close must be above SMA200, and name the vector satisfy this condition 'uptrend'
add.signal(strategy.st, name = "sigComparison", arguments = list(columns = c("SPY.Close", "SMA.filterMA"), relationship = "gt"), label = "uptrend") # did not mention 'SPY' here, but maybe assumed
# 
# ?add.signal
# ?sigComparison 
#### sigComparison(label, data = mktdata, columns, relationship = c("gt", "lt", "eq", "gte", "lte"), offset1 = 0, offset2 = 0)
######################

# 4.2 find out all the prices when RSI value cross under 10 =  thresh1
add.signal(strategy.st, name = "sigThreshold", arguments = list(column = "EMA.rsi", threshold = thresh1, relationship = "lt", cross = FALSE), label = "rsiThresh1")

# ?sigThreshold  # sigThreshold(label, data = mktdata, column, threshold = 0, relationship = c("gt", "lt", "eq", "gte", "lte"), cross = FALSE)
# # cross = TRUE means only return true for the first observation
###########

# 4.3 find out all the prices when RSI value cross under 6 = Thresh2
add.signal(strategy.st, name = "sigThreshold", arguments = list(column = "EMA.rsi", threshold = thresh2, relationship = "lt", cross = FALSE), label = "rsiThresh2")
#############


# 4.4 find out all the prices when 4.1 condition and 4.2 conditions are met together, in which we can make a buy
add.signal(strategy.st, name = "sigAND", arguments = list(columns = c("rsithresh1", "uptrend"), cross = TRUE), label = "longEntry1")

#?sigAND  
## columns--the signal columns to intersect 
# cross--whether to only provide a true value for crossing values
# return a new signal column that intersects the provided columns


# 4.5 find out all prices when both condition uptrend and thresh2 happen, and make a second buy
add.signal(strategy.st, name = "sigAND", arguments = list(columns = c("rsiThresh2", "upTrend"), cross = TRUE), label = "longEntry2") 


# 4.6 find out all prices when close cross over SMA.5 and make a sell to exit
add.signal(strategy.st, name = "sigCrossover", arguments = list(columns = c("SPY.Close", "SMA.quickMA"), relationship = "gt"), label = "exitLongNormal")


# 4.7 find out all prices when close cross over SMA.200, and sell a second time
add.signal(strategy.st, name = "sigCrossover", arguments = list(columns = c("SPY.Close", "SMA.filterMA"), relationship = "lt"), label = "exitLongFilter")

test <- applyIndicators(strategy.st, mktdata=OHLC(SPY))

test <- applySignals(strategy.st, mktdata=SPY)
tail(test)
tail(test)
out <- applySignals(strategy.st, SPY)
tail(out)
names(out) # all the names of cols with SPY...in front
?applySignals


#########################################
# 5 adding rules
##########################################
# 5.1 rule1

add.rule(strategy.st, name = "ruleSignal", arguments = list(sigcol = "longEntry1", sigval = TRUE, ordertype = "market", orderside = "long", replace = FALSE, prefer = "Open", osFUN = osDollarATR, tradeSize = tradeSize, pctATR = pctATR, maxPctATR = pctATR, atrMod = "X"), type = "enter", path.dep = TRUE, label = "enterLong1")

# 5.2 rule
add.rule(strategy.st, name = "ruleSignal", arguments = list(sigcol = "longEntry2", sigval = TRUE, ordertype = "market", orderside = "long", replace = FALSE, prefer = "Open", osFun = osDollarATR, tradeSize = tradeSize, pctATR = pctATR, maxPctATR = maxPct, atrMod = "X"), type = "enter", path.dep = TRUE, label = "enterLong2")

# 5.3 rule
add.rule(strategy.st, name = "ruleSignal", arguments = list(sigcol = "exitLongNormal", sigval = TRUE, orderqty = "all", ordertype = "market", orderside = "long", replace = FALSE, prefer = "Open"), type = "exit", path.dep = TRUE, label = "normalExitLong")
         
# 5.4 rule
add.rule(strategy.st, name = "ruleSignal", arguments = list(sigcol = "exitLongFilter", sigval = TRUE, orderqty = "all", ordertype = "market", orderside = "long", replace = FALSE, prefer = "Open"), type = "exit", path.dep = TRUE, label = "filterExitLong")
         
         
####################################
# 6. apply strategy
##################################3

t1 <- Sys.time()
out <- applyStrategy(strategy = strategy.st, portfolios = portfolio.st)
t2 <- Sys.time()
print(t2-t1)

######################################
# set up analytics
#######################################

updatePortf(portfolio.st)
dateRange <- time(getPortfolio(portfolio.st)$summary)[-1]
updateAcct(portfolio.st, dateRange)
updateEndEq(account.st)


######################################
# 7. trade statistics
#####################################
tStats <- tradeStats(Portfolios = portfolio.st, use = "trades", inclZeroDays = FALSE)
tStats[,4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)
print(data.frame(t(tStats[, -c(1,2)])))
(aggPF <- sum(tStats$Gross.Profits)/-sum(tStats$Gross.Losses) )
(aggCorrect <- mean(tStats$Percent.Positive))
(numTrades <- sum(tStats$Num, Trades))
(meanAvgWLR <- mean(tStats$Avg.WinLoss.Ratio[tStats$Avg.WinLoss.Ratio < Inf], na.rm = TRUE))

########################
#daily and duration statistics
########################

dstats <- dailyStats(Portfolios - portfolio.st, use = "Equity")
rownames(dStats) <- gsub(".DailyEndEq", "", rownames(dStats))
print(data.frame(t(dStats)))
durStats <- durationStatistics(Portfolio = portfolio.st, Symbols = sort(symbols))
indivOurStats <- durationStatistics(Portfolio = portfolio.st, Symbols = sort(symbols), aggregate = FALSE)
print(t(durStats))
print(t(indivOurStats))


###################################################
# market exposure
###################################################

tmp <- list()
length(tmp) <- length(symbols)
for(i in 1:nrow(dStats)) {
  totalDays <- norw(get(rownames(dStats)[i]))
  mktExposure <- dStats$Total.Days[i]/totalDays
  tmp[[i]] <- c(rownames(dStats)[i],round(mktExposure,3))
}
mktExposure <- data.frame(do.call(rbind, tmp))
colnames(mktExposure) <- c("Symbol", "mktExposure")
print(mktExposure)
print(mean(as.numeric(as.character(mktExposure$mktExposure))))



