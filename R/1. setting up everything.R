######################################################
######################################################
# to prepare all R and Rstudio
# latest version of R, Rstudio, Rtools
# ignore the defaults package
# install "foreach" package through Rstudio package install button
# then install all packages below then evertyhing should be working
# if more problems then search online 


install.packages("quantstrat", repos = "http://R-Forge.R-project.org")
install.packages("zoo")
install.packages("TTR", repos = "http://R-Forge.R-project.org") # the latest TTR solve problem of Defaults
install.packages("Defaults", repos = "http://R-Forge.R-project.org") # it is not available for R 3.0.3

install.packages("devtools")
require(quantstrat)
require(devtools)
install_github(repo = "IKTrading", username = "IlyaKipnis")
install_github(repo = "DSTrading", username = "IlyaKipnis")
require(IKTrading)
require(DSTrading)


sessionInfo()
install.packages("blotter", repos="http://R-Forge.R-project.org") # it seems the newest version of blotter from 0.8.19 moving to 0.9.1644

###############################################################################################################################
# how to make use of Demos
#
# A demo is an .R file that lives in demo/. Demos are like examples, but tend to be longer, and instead of focussing on a single function, show how to weave together multiple functions to solve a problem.
# 
# You list and access demos with demo():
#   
#   Show all available demos: demo().
# Show all demos in a package: demo(package = "httr").
# Run a specific demo: demo("oauth1-twitter", package = "httr").
# Find a demo: system.file("demo", "oauth1-twitter.R", package = "httr").
