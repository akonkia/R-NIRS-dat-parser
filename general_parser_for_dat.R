#read all lines from an ascii file exported from ISIscan
data <- readLines(file.choose())

#Inspect the first couple of rows of the file (ex. 20)
head(data, 20)

#Find rows with information from ISIscan. They start with #
info <- data[grep("#", data)]
first_wav <- gsub("#FIRST_WAVELENGTH=", "",info [grep("FIRST_WAVELENGTH", info)])
second_wav <- gsub("#LAST_WAVELENGTH=", "",info [grep("LAST_WAVELENGTH", info)])
increment <- gsub("#WAVELENGTH_INCREMENT=", "",info [grep("WAVELENGTH_INCREMENT", info)])

#Inspect the first couple of rows of the file (info + the first row with samples)
head(data, (length(info)+1))

#Extract YNAME values to create a future header
yvars<- info[grep("YNAME", info)]
yvars <- gsub("#YNAMEn.=", "", yvars)

#Delete first rows starting with #
data <- data[-(grep("#", data))]

#Create a header for the .csv file. The header should contain wavelengths and variable names, if present.
wave_vis <- seq(first_wav[1],second_wav[1],by=as.numeric(increment[1]))
wave_vis <- as.character(wave_vis)
wave_nir <- seq(first_wav[2],second_wav[2],by=as.numeric(increment[1]))
wave_nir <- as.character(wave_nir)
header <- c("Samples", wave_vis, wave_nir, yvars)
header <- paste(header, collapse = ",")

#create a file and add header with wavelengths and variable names
writeLines(header,'parsed.csv')

#create a vector to know on which line the samples start. 
#You can use this place to search for patterns (if you want to select a subset of samples with known naming pattern)
#If a sample name contains at least one letter, run the following:
#vectorCut <- grep("[A-Za-z]", data)

#If a sample name contains only numbers with a known pattern, run the following:
vectorCut <- grep("64101", data)

nlines <- vectorCut[2]-vectorCut[1]

#Create a vector to store data for one sample. We will be reusing this one for each iteration.
result <- vector("character",length = nlines)

#Iterate over vectorCut starting positions to create rows in csv (each row different sample)
#Find the starting position for each sample
for (i in vectorCut){
  beg <- i
  end <- i+132
  
  #Iterate
  counter = 1
  for (n in beg:end){
    
    #Parse, clean and concatenate lines belonging to each sample.
    result[counter] <- trimws(gsub("\\s+", " ", data[n]))
    result[counter] <- gsub(" ",",",result[counter])
    
    counter <- counter+1
  }
  #Turn the vector with sample lines into one-liner
  sample <- paste(result, collapse = ",")
  
  #Write the one-liner to a csv file
  write.table(sample,file='parsed.csv', sep = ",", row.names = FALSE, col.names = FALSE, quote= FALSE, append=TRUE)
  
}

#rename the parsed.csv file with a timestamp
now <- Sys.time()
new.name <- paste0(format(now, "%Y%m%d_%H%M%S_"), "parsed.csv")
file.rename("parsed.csv", new.name)

# #Cleanup
# rm(list = ls())
