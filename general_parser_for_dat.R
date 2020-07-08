#read all lines from an ascii file exported from ISIscan
allLines <- readLines(file.choose())

#Inspect the first couple of rows of the file (ex. 20)
head(allLines, 20)

#Strip first rows with information from ISIscan. Ex. there are 14 info lines.
allLines <- allLines[-1:-14]

#Create a header for the future .csv file. The header should contain wavelengths and variable names, if present.
wave_vis <- seq(400,1098,by=2)
wave_vis <- as.character(wave_vis)
wave_nir <- seq(1100,2498,by=2)
wave_nir <- as.character(wave_nir)
header <- c("Samples", wave_vis, wave_nir, "DMD", "BC", "WSC", "CP")
header <- paste(header, collapse = ",")

#create a file and add header with wavelengths and variable names
writeLines(header,'parsed.csv')

#create a vector to know on which line the samples start. Ex. each samples takes 133 rows.
#You can use this place to search for patterns (if you want to select a subset of samples with known naming pattern)
vectorCut <- seq(from = 1, to = NROW(allLines), by=133)

#Create a vector to store data for one sample. We will be reusing this one for each iteration.
result <- rep("na",133)

#iterate over vectorCut starting positions to create rows in csv (each row different sample)
#Find the starting position for each sample
for (i in vectorCut){
  beg <- i
  end <- i+132

  #Iterate
  counter = 1
  for (n in beg:end){
  
    #Parse, clean and concatenate lines belonging to each sample. In this case, there is 133 lines for each
    #This could be instrument specific
    result[counter] <- trimws(gsub("    ","",allLines[n]))
    result[counter] <- gsub("  "," ",result[counter])
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
# rm(result)
# rm(sample)
# rm(allLines)
# rm(beg)
# rm(counter)
# rm(i)
# rm(end)
# rm(header)
# rm(n)
# rm(new.name)
# rm(now)
# rm(vectorCut)
# rm(wave_nir)
# rm(wave_vis)