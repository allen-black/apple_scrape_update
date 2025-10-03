library(rjson)
library(httr)
library(stringi)
library(tibble)
library(jsonlite)



output <- tribble (~date, ~site, ~appName, ~id, ~userRatingCount, ~userRatingCountForCurrentVersion, ~averageUserRating, ~averageUserRatingForCurrentVersion, ~currentVersionReleaseDate, ~version, ~fileSizeBytes, ~releaseDate, ~releaseNotes, ~appId)

timestamp <- Sys.time()

sites <- tribble (~siteName, ~url,
                  'Mayo Clinic', 'https://itunes.apple.com/lookup?id=523220194',
                  'Cleveland Clinic', 'https://itunes.apple.com/lookup?id=1464300206',
                  'Johns Hopkins Medicine',	'https://itunes.apple.com/lookup?id=1495861981',
                  'Mount Sinai',	'https://itunes.apple.com/lookup?id=1570642373',
                  'Penn Medicine',	'https://itunes.apple.com/lookup?id=1440687165',
                  'Cedars-Sinai',	'https://itunes.apple.com/lookup?id=1034088603',
                  'Houston Methodist',	'https://itunes.apple.com/lookup?id=1025186416',
                  'NYU Langone Health',	'https://itunes.apple.com/lookup?id=1196929294',
                  'Stanford Health Care',	'https://itunes.apple.com/lookup?id=922978966',
                  'Northwestern Medicine',	'https://itunes.apple.com/lookup?id=1442290209',
                  'New York - Presbyterian',	'https://itunes.apple.com/lookup?id=1067978515',
                  'University of Michigan Health',	'https://itunes.apple.com/lookup?id=1452632342',
                  'Mass General Brigham, Inc',	'https://itunes.apple.com/lookup?id=1175078347',
                  'Vanderbilt University Medical Center',	'https://itunes.apple.com/lookup?id=1114939674',
                  'Epic',	'https://itunes.apple.com/lookup?id=382952264',
                  'Kaiser Permanente',	'https://itunes.apple.com/lookup?id=493390354',
                  'Primary Care On Demand Wis.', 'https://itunes.apple.com/lookup?id=6462700069'
)

iterations <- nrow(sites)
strings <- stri_rand_strings(iterations, 30, pattern = "[A-Za-z0-9]")

for(i in 1:iterations) {
  
  url_json <- sites$url[i]
  raw_json <- httr::GET(url_json) %>% 
    httr::content()
  
  myData <- rjson::fromJSON(raw_json)
  
  averageUserRating <- myData[["results"]][[1]][["averageUserRating"]]
  userRatingCount <- myData[["results"]][[1]][["userRatingCount"]]
  
  trackCensoredName <- myData[["results"]][[1]][["trackCensoredName"]]
  currentVersionReleaseDate <- myData[["results"]][[1]][["currentVersionReleaseDate"]]
  fileSizeBytes <- myData[["results"]][[1]][["fileSizeBytes"]]
  releaseDate <- myData[["results"]][[1]][["releaseDate"]]
  releaseNotes <- NULL
  averageUserRatingForCurrentVersion <- myData[["results"]][[1]][["averageUserRatingForCurrentVersion"]]
  
  userRatingCountForCurrentVersion <- myData[["results"]][[1]][["userRatingCountForCurrentVersion"]]
  userRatingCount <- myData[["results"]][[1]][["userRatingCount"]]
  trackName <- myData[["results"]][[1]][["trackName"]]
  version <- myData[["results"]][[1]][["version"]]
  appId <- myData[["results"]][[1]][["trackId"]]
  userRatingCountForCurrentVersion <- myData[["results"]][[1]][["userRatingCountForCurrentVersion"]]
  
  output <- output %>% add_row (
    date = timestamp, 
    site = sites$siteName[i], 
    appName = trackName,
    id = strings[i], 
    userRatingCount = userRatingCount,
    userRatingCountForCurrentVersion = userRatingCountForCurrentVersion,
    averageUserRating = averageUserRating,
    averageUserRatingForCurrentVersion = averageUserRatingForCurrentVersion,
    currentVersionReleaseDate = currentVersionReleaseDate,
    version = version,
    fileSizeBytes=fileSizeBytes,
    releaseDate=releaseDate,
    releaseNotes = releaseNotes,
    appId = appId
  )
}

write.table(output,paste0('apple_ratings.csv'),append = TRUE, sep=',', col.names = FALSE)   

