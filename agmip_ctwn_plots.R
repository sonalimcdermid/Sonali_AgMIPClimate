####################################################################################################
###----------------------------------------------------------------------------------------------###
#                     \    ||   /
#      AA             \    ||   /  MMM    MMM  IIII  PPPPP
#     AAAA            \\   ||   /   MMM  MMM    II   P  PPP
#    AA  AA    ggggg  \\\\ ||  //   M  MM  M    II   PPPPP
#   AAAAAAAA  gg  gg     \\ ////    M      M    II   P
#  AA      AA  ggggg  \\   //      MM      MM  IIII  PPP
#                  g  \\\\     //    
#              gggg      \\ ////     The Agricultural Model Intercomparison and Improvement Project
#                          //
###----------------------------------------------------------------------------------------------###
####################################################################################################
###----------------------------------------------------------------------------------------------###

### AgMIP Regional Integrated Assessments: CTWN Sensitivity Analysis ##

# This routine is structured to produce line plots and boxplots related to a linear factor analysis, intended to explore crop, crop model, and site-specific sensitivities to changes in carbon dioxide concentration, temperature, water/precipitation, and nitrogen applications. The routine can, and should, be used by all RRTs in their sensitivity investigations, particularly related to Phase 2 of the DFID-funded regional integrated assessments

# Created: May 19, 2015
# Last edited: September 28th, 2015
# Author: Sonali McDermid, sps246@nyu.edu
# Co-authors: Alex Ruane, Cheryl Porter, and Ken Boote
# Routines are not gauranteed, and any help questions should be directed to the authors

# It is suggested that the User read carefully through this routine, and specifically note those lines that contain, or are preceeded by the word "CHANGE" in uppercase. These are areas that the User will need to change the inputs. The program is constructed to minimize the number of changes that the User makes, and can be modified by the User for her/his needs. These "CHANGE" statements can usually be found at the top of each section. 

# Also note that on some platforms, you may have difficulty creating either pdf or jpeg images. As such, we have included the commands to do both. Currently, the routine is set-up to print .pdfs. However, if you wish to switch to jpegs, please UNCOMMENT the preceding line. For example, to switch to jpeg, you would comment out the line starting with "pdf(. . .)", and uncomment the line starting with #jpeg('CO2 Sensitivity at N=30kg-ha.jpg', quality = 300). 

# The following is a key corresponding to the sensitivity tests
#CO2 @ 30
#1 360
#2 450
#3 540
#4 630
#5 720
#CO2 @180
#6 360
#7 450
#8 540
#9 630
#10 720
#Temp
#11 -2
#12 0
# 13 2
# 14 4
# 15 6
# 16 8
#Rainfall
# 17 25
# 18 50
# 19 75
# 20 100
# 21 125
# 22 150
# 23 175
# 24 200
#Fert
# 25 0
# 26 30
# 27 60
# 28 90
# 29 120
# 30 150
# 31 180
# 32 210

#----------------------Start Routine-------------------------#

# Section 1 - Read in ACMO files and assign arrays #

# Definitions
modname <- c('APSIM','DSSAT') # CHANGE: LIST MODEL NAMES ALPHABETICALLY (this is the order the files will be read in)
years <-c(1980:2009) # Assume 30 years (1980-2009) for all sensitivity tests
co2 <- c(360,450,540,630,720)
Tmaxmin <- c(-2,0,2,4,6,8)
Rainfall <- c(25,50,75,100,125,150,175,200)
Fertilizer <- c(0,30,60,90,120,150,180,210)
var <- matrix(0, 30, 32) # Pre-allocate, to speed things up.


# List all ACMO files
files <- list.files(path=".", pattern="ACMO*", full.names=T, recursive=FALSE)
for(d in 1:length(files)) {
data <- read.csv(file=files[d],skip = 2, head=TRUE,sep=",") # This is for ACMO files that have a header above column names
#data <- read.csv(file=files[d], head=TRUE,sep=",") # For ACMOs that start with column names (no lines to skip)
model <- paste(modname[d]) # This allows us to create a new dedicated variable for each model
for (i in 1:32) {
	var[,i] <- data$HWAH_S[(1+30*(i-1)):(30+30*(i-1))]
} 
assign(model, var)
}

# Section 2 #
#___________________________________________#
###### Lineplots of Linear Factor Analysis #######

# Section 2.1 #
#CO2 at 30 N________________________

# CHANGE NEXT 4 LINES - SPECIFY NUMBER OF MODELS AND MODEL NAMES HERE
nummod <- 1 #If you are just using one model here, just edit "model1". For now, this is set up for one or two models, but can be amended for 3.
model1 <- APSIM #Specify model name here. Make sure the legend is consistent
model2 <- DSSAT #Specify model name here. Make sure the legend is consistent
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# Get data for plotting
if(nummod==1) {
# Single model -
model <- model1} else {print("You are plotting multiple models")} 

if(nummod==2) {
# Two model matrix - preallocation 
 model <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .DSSAT Test n, APSIM Test n
 cols2 <- seq(2, by = 2, len = 32)
 model[,cols1] <- model1 # Fill in models of interest here
 model[,cols2] <- model2 # Fill in models of interest here
 } else {print("You are using only one model")}

 	if(nummod==1){
 		#jpeg('CO2 Sensitivity at N=30kg-ha.jpg', quality = 300)
pdf('CO2 Sensitivity at N=30kg-ha.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,1:5], na.rm=TRUE),max(model[,1:5], na.rm=TRUE)),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,1:5], type = "l", lty = 1:5, lwd = 1, pch = NULL,
          col = 1:5, xlab="Years", ylab="Yield")
          
legend("topright", title="CO2 Sensitivity at N=30kg/ha", cex=0.75, pch=16, col=1:5, legend=c("360ppm", "450ppm","540ppm","630ppm","720ppm"), ncol=2)
dev.off()} else {
	#jpeg('CO2 Sensitivity at N=30kg-ha.jpg', quality = 300)
	pdf('CO2 Sensitivity at N=30kg-ha.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,1:10], na.rm=TRUE),max(model[,1:10], na.rm=TRUE)+1000),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,1:10], type = "l", lty = 1:10, lwd = 1, pch = NULL,
          col = 1:10, xlab="Years", ylab="Yield")
          
legend("topright", title="CO2 Sensitivity at N=30kg/ha", cex=0.75, pch=16, col=1:10, legend=c(paste("360ppm", modname[1]),paste("360ppm", modname[2]),paste("450ppm", modname[1]),paste("450ppm", modname[2]),paste("540ppm", modname[1]),paste("540ppm", modname[2]),paste("630ppm", modname[1]),paste("630ppm", modname[2]),paste("720ppm", modname[1]),paste("720ppm", modname[2])), ncol=2)
dev.off()}

# Section 2.2 #
#CO2 at 180 N________________________

# CHANGE NEXT 4 LINES - SPECIFY NUMBER OF MODELS AND MODEL NAMES HERE
nummod <- 1 #If you are just using one model here, just edit "model1". For now, this is set up for one or two models, but can be amended for 3.
model1 <- APSIM #Specify model name here. Make sure the legend is consistent
model2 <- DSSAT #Specify model name here. Make sure the legend is consistent
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# Get data for plotting
if(nummod==1) {
# Single model -
model <- model1} else {print("You are plotting multiple models")} 

if(nummod==2) {
# Two model matrix - preallocation  
 model <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .DSSAT Test n, APSIM Test n
 cols2 <- seq(2, by = 2, len = 32)
 model[,cols1] <- model1 # Fill in models of interest here
 model[,cols2] <- model2 # Fill in models of interest here
 } else {print("You are using only one model")}
 
 	if(nummod==1){
 		#jpeg('CO2 Sensitivity at N=180kg-ha.jpg', quality = 300)
pdf('CO2 Sensitivity at N=180kg-ha.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,6:10], na.rm=TRUE),max(model[,6:10], na.rm=TRUE)),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,6:10], type = "l", lty = 1:5, lwd = 1, pch = NULL,
          col = 1:5, xlab="Years", ylab="Yield")
          
legend("topright", title="CO2 Sensitivity at N=180kg/ha", cex=0.75, pch=16, col=1:5, legend=c("360ppm", "450ppm","540ppm","630ppm","720ppm"), ncol=2)
dev.off()} else {
	#jpeg('CO2 Sensitivity at N=180kg-ha.jpg', quality = 300)
	pdf('CO2 Sensitivity at N=180kg-ha.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,11:20], na.rm=TRUE),max(model[,11:20], na.rm=TRUE)+1000),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,11:20], type = "l", lty = 1:10, lwd = 1, pch = NULL,
          col = 1:10, xlab="Years", ylab="Yield")
          
legend("topright", title="CO2 Sensitivity at N=180kg/ha", cex=0.75, pch=16, col=1:10, legend=c(paste("360ppm", modname[1]),paste("360ppm", modname[2]),paste("450ppm", modname[1]),paste("450ppm", modname[2]),paste("540ppm", modname[1]),paste("540ppm", modname[2]),paste("630ppm", modname[1]),paste("630ppm", modname[2]),paste("720ppm", modname[1]),paste("720ppm", modname[2])), ncol=2)
dev.off()}

# Section 2.3 #
#Tmax/Tmin________________________ 

# CHANGE NEXT 4 LINES - SPECIFY NUMBER OF MODELS AND MODEL NAMES HERE
nummod <- 1 #If you are just using one model here, just edit "model1". For now, this is set up for one or two models, but can be amended for 3.
model1 <- APSIM #Specify model name here. Make sure the legend is consistent
model2 <- DSSAT #Specify model name here. Make sure the legend is consistent
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# Get data for plotting
if(nummod==1) {
# Single model -
model <- model1} else {print("You are plotting multiple models")}

if(nummod==2) {
# Two model matrix - preallocation  
 model <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .DSSAT Test n, APSIM Test n
 cols2 <- seq(2, by = 2, len = 32)
 model[,cols1] <- model1 # Fill in models of interest here
 model[,cols2] <- model2 # Fill in models of interest here
 } else {print("You are using only one model")}
 	
 	if(nummod==1){
 		#jpeg('TmaxTmin Sensitivity.jpg', quality = 300)
pdf('TmaxTmin Sensitivity.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,11:16], na.rm=TRUE),max(model[,11:16], na.rm=TRUE)),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,11:16], type = "l", lty = 1:6, lwd = 1, pch = NULL,
          col = 1:6, xlab="Years", ylab="Yield")
          
legend("topright", title="TmaxTmin Sensitivity", cex=0.75, pch=16, col=1:6, legend=c("-2 degC", "0 degC","+2 degC","+4 degC","+6 degC","+8 degC"), ncol=2)
dev.off()} else {
	#jpeg('TmaxTmin Sensitivity.jpg', quality = 300)
	pdf('TmaxTmin Sensitivity.pdf')
	# All TmaxTmin tests are indices 21:32
plot(0,xlim=c(1980,2009),ylim=c(min(model[,23:24], na.rm=TRUE),max(model[,23:24], na.rm=TRUE)+1000),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,23:24], type = "l", lty = 1:12, lwd = 1, pch = NULL,
          col = 1:2, xlab="Years", ylab="Yield")
    
# Use this legend for all models and all tests       
#legend("topright", title="TmaxTmin Sensitivity", cex=0.75, pch=16, col=1:12, legend=c(paste("-2 degC", modname[1]),paste("-2 degC", modname[2]),paste("0 degC", modname[1]),paste("0 degC", modname[2]),paste("+2 degC", modname[1]),paste("+2 degC", modname[2]),paste("+4 degC", modname[1]),paste("+4 degC", modname[2]),paste("+6 degC", modname[1]),paste("+6 degC", modname[2]),paste("+8 degC", modname[1]),paste("+8 degC", modname[2])), ncol=2)

# Use this legend for all models and one test. Make sure the "col", which sets the colors, is consistent with the "col" in the matlines commands above
legend("topright", title="TmaxTmin Sensitivity", cex=0.75, pch=16, col=1:2, legend=c(paste("0 degC", modname[1]),paste("0 degC", modname[2])), ncol=2)
dev.off()}

# Section 2.4 #
#Rainfall________________________ 

# CHANGE NEXT 4 LINES - SPECIFY NUMBER OF MODELS AND MODEL NAMES HERE
nummod <- 1 #If you are just using one model here, just edit "model1". For now, this is set up for one or two models, but can be amended for 3.
model1 <- APSIM #Specify model name here. Make sure the legend is consistent
model2 <- DSSAT #Specify model name here. Make sure the legend is consistent
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# Get data for plotting
if(nummod==1) {
# Single model matrix
model <- model1} else {print("You are plotting multiple models")}

if(nummod==2) {
# Two model matrix - preallocation 
 model <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .DSSAT Test n, APSIM Test n
 cols2 <- seq(2, by = 2, len = 32)
 model[,cols1] <- model1 # Fill in models of interest here
 model[,cols2] <- model2 # Fill in models of interest here
 } else {print("You are using only one model")}
 	
 	if(nummod==1){
 		#jpeg('Rainfall Sensitivity.jpg', quality = 300)
pdf('Rainfall Sensitivity.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model1[,17:24], na.rm = TRUE),max(model1[,17:24], na.rm = TRUE)),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,17:24], type = "l", lty = 1:8, lwd = 1, pch = NULL,
          col = 1:8, xlab="Years", ylab="Yield")
          
legend("topright", title="Rainfall Sensitivity", cex=0.75, pch=16, col=1:8, legend=c("25%","50%","75%","100%","125%","150%","175%","200%"), ncol=2)
dev.off()} else {
	#jpeg('Rainfall Sensitivity.jpg', quality = 300)
	pdf('Rainfall Sensitivity.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,35:48], na.rm=TRUE),max(model[,35:48],na.rm=TRUE)+1000),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,35:48], type = "l", lty = 1:16, lwd = 1, pch = NULL,
          col = 1:16, xlab="Years", ylab="Yield")
          
legend("topright", title="Rainfall Sensitivity", cex=0.75, pch=16, col=1:16, legend=c(paste("25%", modname[1]),paste("25%", modname[2]), paste("50%", modname[1]),paste("50%", modname[2]),paste("75%", modname[1]),paste("75%", modname[2]),paste("100%", modname[1]),paste("100%", modname[2]),paste("125%", modname[1]),paste("125%", modname[2]),paste("150%", modname[1]),paste("150%", modname[2]),paste("175%", modname[1]),paste("175%", modname[2]),paste("200%", modname[1]),paste("200%", modname[2])), ncol=2)
dev.off()}

# Section 2.5 #
#Fertilizer (N)________________________

# CHANGE NEXT 4 LINES: SPECIFY NUMBER OF MODELS AND MODEL NAMES HERE
nummod <- 1 #If you are just using one model here, just edit "model1". For now, this is set up for one or two models, but can be amended for 3.
model1 <- APSIM #Specify model name here. Make sure the legend is consistent
model2 <- DSSAT #Specify model name here. Make sure the legend is consistent
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# Get data for plotting
if(nummod==1) {
# Single model -
model <- model1} else {print("You are plotting multiple models")} 

if(nummod==2) {
# Two model matrix - preallocation  
 model <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .DSSAT Test n, APSIM Test n
 cols2 <- seq(2, by = 2, len = 32)
 model[,cols1] <- model1 # Fill in models of interest here
 model[,cols2] <- model2 # Fill in models of interest here
 } else {print("You are using only one model")}
 	
 	if(nummod==1){
 		#jpeg('Fertilizer Sensitivity.jpg', quality = 300)
pdf('Fertilizer Sensitivity.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,25:32], na.rm=TRUE),max(model[,25:32], na.rm=TRUE)),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,25:32], type = "l", lty = 1:8, lwd = 1, pch = NULL,
          col = 1:8, xlab="Years", ylab="Yield")
          
legend("topright", title="Fertilizer Sensitivity (kg/ha)", cex=0.75, pch=16, col=1:8, legend=c("0","30","60","90","120","150","180","210"), ncol=2)
dev.off()} else {
	#jpeg('Fertilizer Sensitivity.jpg', quality = 300)
	pdf('Fertilizer Sensitivity.pdf')
plot(0,xlim=c(1980,2009),ylim=c(min(model[,49:64], na.rm=TRUE),max(model[,49:64], na.rm=TRUE)+1000),type="n",xlab="Years",ylab="Yield (kg/ha)")
matlines(years, model[,49:64], type = "l", lty = 1:16, lwd = 1, pch = NULL,
          col = 1:16, xlab="Years", ylab="Yield")
          
legend("topright", title="Fertilizer Sensitivity (kg/ha)", cex=0.75, pch=16, col=1:16, legend=c(paste("0", modname[1]),paste("0", modname[2]),paste("30", modname[2]),paste("30", modname[1]),paste("60", modname[2]),paste("60", modname[1]),paste("90", modname[2]),paste("90", modname[1]),paste("120", modname[2]),paste("120", modname[1]),paste("150", modname[2]),paste("150", modname[1]),paste("180", modname[2]),paste("180", modname[1]),paste("210", modname[1]),paste("210", modname[2])), ncol=2)
dev.off()}

# Section 3 #
#___________________________________________#
###### Prob of Exceedance of Linear Factor Analysis #######

# CHANGE NEXT LINES 311-313. Please refer to CTWN/C3MP Protocols (or above key) for identification of linear factor Test #
for(testnum in 1:32) {
model1 <- APSIM # Set model 1 here
model2 <- DSSAT # Set model 2 here
modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

P1 <- ecdf(model1[,testnum]) 
P2 <- ecdf(model2[,testnum]) 
r <- range(model1[,testnum],model2[,testnum],na.rm=TRUE) # Get x-axis limit
y1 = 1-P1(model1[,testnum])
y2 = 1-P2(model2[,testnum])
probe1 = sort(y1, decreasing=TRUE)
probe2 = sort(y2, decreasing=TRUE)
yields1 = sort(model1[,testnum], decreasing=FALSE)
yields2 = sort(model2[,testnum], decreasing=FALSE)

# Plot data
#jpeg('Prob of Exceedance.jpg', quality = 300)
pdf(paste('Prob of Exceedance', '_','Test',testnum,'.pdf',sep=''))
plot(0,xlim=c(r[1],r[2]),ylim=c(0,1),type="n",xlab="Yield (kg/ha)",ylab="Prob of Exceedance")
#plot(0,xlim=c(200,3000),ylim=c(0,1),type="n",xlab="Yield (kg/ha)",ylab="Prob of Exceedance")
points(yields1, probe1, type="o", pch = 20, col = "red", lwd = 2)
points(yields2, probe2, type="o", pch = 20, col = "blue", lwd = 2)
legend("topright", cex=0.75, pch=16, col=c("red","blue"), legend=c(modname[1],modname[2]), ncol=2)
dev.off()

}

#CHANGE: If you would like to create Prob of Exceedance plots for one sensitivity test at a time, then comment out lines 310-334, and uncomment the following lines. Make sure to amend the "testnum" to indicate what test you would like to see. See above for the key
# testnum <- 1 # Set Test Number here
# model1 <- APSIM # Set model 1 here
# model2 <- DSSAT # Set model 2 here
# modname <- c('APSIM','DSSAT') # Make sure the legend is consistent

# P1 <- ecdf(model1[,testnum]) 
# P2 <- ecdf(model2[,testnum]) 
# r <- range(model1[,testnum],model2[,testnum]) # Get x-axis limit
# y1 = 1-P1(model1[,testnum])
# y2 = 1-P2(model2[,testnum])
# probe1 = sort(y1, decreasing=TRUE)
# probe2 = sort(y2, decreasing=TRUE)
# yields1 = sort(model1[,testnum], decreasing=FALSE)
# yields2 = sort(model2[,testnum], decreasing=FALSE)

# # Plot data
# #jpeg('Prob of Exceedance.jpg', quality = 300)
# pdf('Prob of Exceedance.pdf')
# plot(0,xlim=c(r[1],r[2]),ylim=c(0,1),type="n",xlab="Yield (kg/ha)",ylab="Prob Exceedance")
# points(yields1, probe1, type="o", pch = 20, col = "red", lwd = 2)
# points(yields2, probe2, type="o", pch = 20, col = "blue", lwd = 2)
# legend("topright", cex=0.75, pch=16, col=c("red","blue"), legend=c(modname[1],modname[2]), ncol=2)
# dev.off()

# Section 4 #
#___________________________________________#
###### Boxplots of Linear Factor Analysis #######

# Create a matrix of alternating model results

# Two model matrix - "multimod" is our placeholder matrix here (will make routine run faster)
 multimod <- matrix(0,30,64)
 cols1 <- seq(1, by = 2, len = 32) # Want to list the same experiments from different models next to each other, e.g. DSSAT Test 1, APSIM Test 1, DSSAT Test 2, APSIM Test 2,. . .
 cols2 <- seq(2, by = 2, len = 32)
 multimod[,cols1] <- APSIM # CHANGE: FILL IN MODEL NAME HERE 
 multimod[,cols2] <- DSSAT # CHANGE: FILL IN MODEL NAME HERE
 modname <- c('APSIM','DSSAT') # CHANGE: Make sure the legend is consistent

# Three model matrix
 # multimod <- matrix(0,30,96)
 # cols1 <- seq(1, by = 3, len = 96)
 # cols2 <- seq(2, by = 3, len = 96)
 # cols3 <- seq(3, by = 3, len = 96)
 # multimod[,cols1] <- APSIM # CHANGE: FILL IN MODEL NAME HERE
 # multimod[,cols2] <- DSSAT # CHANGE: FILL IN MODEL NAME HERE
 # multimod[,cols3] <- INFO # CHANGE: FILL IN MODEL NAME HERE

# Section 4.1 #
#CO2 at 30 N________________________

# Create the plot
#jpeg('Boxplot CO2 Sensitivity at N=30kg-ha.jpg', quality = 300)
pdf('Boxplot CO2 Sensitivity at N=30kg-ha.pdf')
boxplot(multimod[,1:10], ylab = "Yield (kg/ha)", xlab = "CO2 Level (ppm)", las = 2, col = c("red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2"), at=c(1,2, 4,5, 7,8, 10,11, 13,14), names=c("360"," ","450"," ","540"," ","630"," ","720"," "), boxwex=0.5)
# Plot means on top of boxplots
col1 <- seq(1, by = 2, len = 5) 
col2 <- seq(2, by = 2, len = 5)
points(c(1, 4, 7, 10, 13), colMeans(multimod[,col1]), type="o", pch = 20, col = "darkgoldenrod1", lwd = 2)
points(c(2, 5, 8, 11, 14), colMeans(multimod[,col2]), type="o", pch = 20, col = "chartreuse3", lwd = 2)
legend("topright", title="CO2 Sensitivity at N=30kg/ha", cex=0.75, pch=16, col=c("red","cyan2","darkgoldenrod1","chartreuse3"), legend=c(modname[1], modname[2],paste("Mean", modname[1]),paste("Mean", modname[2])), ncol=2)
dev.off()

# Section 4.2 #
#CO2 at 180 N________________________

# Create the plot
#jpeg('Boxplot CO2 Sensitivity at N=180kg-ha.jpg', quality = 300)
pdf('Boxplot CO2 Sensitivity at N=180kg-ha.pdf')
boxplot(multimod[,11:20], ylab = "Yield (kg/ha)", xlab = "CO2 Level (ppm)", las = 2, col = c("red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2"), at=c(1,2, 4,5, 7,8, 10,11, 13,14), names=c("360"," ","450"," ","540"," ","630"," ","720"," "), boxwex=0.5)
# Plot means on top of boxplots
col1 <- seq(11, by = 2, len = 5) 
col2 <- seq(12, by = 2, len = 5)
points(c(1, 4, 7, 10, 13), colMeans(multimod[,col1]), type="o", pch = 20, col = "darkgoldenrod1", lwd = 2)
points(c(2, 5, 8, 11, 14), colMeans(multimod[,col2]), type="o", pch = 20, col = "chartreuse3", lwd = 2)
legend("topright", title="CO2 Sensitivity at N=180kg/ha", cex=0.75, pch=16, col=c("red","cyan2","darkgoldenrod1","chartreuse3"), legend=c(modname[1], modname[2],paste("Mean", modname[1]),paste("Mean", modname[2])), ncol=2)
dev.off()

# Section 4.3 #
#Tmax/Tmin________________________

# Create the plot
#jpeg('Boxplot TmaxTmin Sensitivity.jpg', quality = 300)
pdf('Boxplot TmaxTmin Sensitivity.pdf')
boxplot(multimod[,21:32], ylab = "Yield (kg/ha)", xlab = "TmaxTmin Change (deg C)", las = 2, col = c("red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2"), at=c(1,2, 4,5, 7,8, 10,11, 13,14, 16,17), names=c("-2"," ","0"," ","+2"," ","+4"," ","+6"," ","+8"," "), boxwex=0.5)
# Plot means on top of boxplots
col1 <- seq(21, by = 2, len = 6) 
col2 <- seq(22, by = 2, len = 6)
points(c(1, 4, 7, 10, 13, 16), colMeans(multimod[,col1]), type="o", pch = 20, col = "darkgoldenrod1", lwd = 2)
points(c(2, 5, 8, 11, 14, 17), colMeans(multimod[,col2]), type="o", pch = 20, col = "chartreuse3", lwd = 2)
legend("topright", title="TmaxTmin Sensitivity", cex=0.75, pch=16, col=c("red","cyan2","darkgoldenrod1","chartreuse3"), legend=c(modname[1], modname[2],paste("Mean", modname[1]),paste("Mean", modname[2])), ncol=2)
dev.off()

# Section 4.4 #
#Rainfall________________________ 

# Create the plot
#jpeg('Boxplot Rainfall Sensitivity.jpg', quality = 300)
pdf('Boxplot Rainfall Sensitivity.pdf')
boxplot(multimod[,33:48], ylab = "Yield (kg/ha)", xlab = "Rainfall Change (%)", las = 2, col = c("red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2"), at=c(1,2, 4,5, 7,8, 10,11, 13,14, 16,17, 19,20, 22,23), names=c("25"," ","50"," ","75"," ","100"," ","125"," ","150"," ","175"," ","200"," "), boxwex=0.5)
# Plot means on top of boxplots
col1 <- seq(33, by = 2, len = 8) 
col2 <- seq(34, by = 2, len = 8)
points(c(1, 4, 7, 10, 13, 16, 19, 22), colMeans(multimod[,col1]), type="o", pch = 20, col = "darkgoldenrod1", lwd = 2)
points(c(2, 5, 8, 11, 14, 17, 20, 23), colMeans(multimod[,col2]), type="o", pch = 20, col = "chartreuse3", lwd = 2)
legend("topright", title="TmaxTmin Sensitivity", cex=0.75, pch=16, col=c("red","cyan2","darkgoldenrod1","chartreuse3"), legend=c(modname[1], modname[2],paste("Mean", modname[1]),paste("Mean", modname[2])), ncol=2)
dev.off()

# Section 4.5 #
#Fertilizer (N)________________________

# Create the plot
#jpeg('Boxplot Fertilizer Sensitivity.jpg', quality = 300)
pdf('Boxplot Fertilizer Sensitivity.pdf')
boxplot(multimod[,49:64], ylab = "Yield (kg/ha)", xlab = "Fertilizer Application (kg/ha)", las = 2, col = c("red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2","red","cyan2"), at=c(1,2, 4,5, 7,8, 10,11, 13,14, 16,17, 19,20, 22,23), names=c("0"," ","30"," ","60"," ","90"," ","120"," ","150"," ","180"," ","210"," "), boxwex=0.5)
# Plot means on top of boxplots
col1 <- seq(49, by = 2, len = 8) 
col2 <- seq(50, by = 2, len = 8)
points(c(1, 4, 7, 10, 13, 16, 19, 22), colMeans(multimod[,col1]), type="o", pch = 20, col = "darkgoldenrod1", lwd = 2)
points(c(2, 5, 8, 11, 14, 17, 20, 23), colMeans(multimod[,col2]), type="o", pch = 20, col = "chartreuse3", lwd = 2)
legend("topright", title="N Sensitivity", cex=0.75, pch=16, col=c("red","cyan2","darkgoldenrod1","chartreuse3"), legend=c(modname[1], modname[2],paste("Mean", modname[1]),paste("Mean", modname[2])), ncol=2)
dev.off()

