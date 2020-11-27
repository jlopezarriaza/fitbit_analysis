# Until the version *following* httr 1.0.0 is available on CRAN, get the
# development version by uncommenting the following 2 lines
# library(devtools)
# install_github("hadley/httr")
library(httr)
library(dplyr)
library(lubridate)
library(magrittr)
library(foreach)

logging::basicConfig()
# Getting variables stored in
#   /Library/Frameworks/R.framework/Resources/etc/Renviron
FITBIT_KEY <- Sys.getenv('FITBIT_KEY')
FITBIT_SECRET <- Sys.getenv('FITBIT_SECRET')

# 1. Set up credentials
fitbit_endpoint <-
  oauth_endpoint(request = "https://api.fitbit.com/oauth2/token",
                 authorize = "https://www.fitbit.com/oauth2/authorize",
                 access = "https://api.fitbit.com/oauth2/token")

query_fitbit_data <- oauth_app(appname = "Get_data",
                               key = FITBIT_KEY,
                               secret = FITBIT_SECRET)
# 2. Get OAuth token. See dev.fitbit.com/docs/oauth2/#scope for information
scope <- c("activity", "heartrate", "location", "sleep")

fitbit_token <- oauth2.0_token(
  endpoint = fitbit_endpoint,
  app = query_fitbit_data,
  scope = date_sequencecope,
  use_basic_auth = TRUE,
  cache = FALSE,
  as_header = TRUE
)

token <- fitbit_token

start_date = as.Date('2017-01-10', format = "%Y-%m-%d")
end_date = today() - 1
date_sequence = seq(start_date, end_date, by = "days")


heart.rate.df <- foreach(
  this.date = date_sequence,
  .combine = dplyr::bind_rows,
  .errorhandling = 'remove'
) %do% {
  if (!file.exists(paste0(
    '~/Desktop/intraday-data/heart-rate/heartrate_',
    this.date,
    '.RDS'
  ))) {
    logging::loginfo(paste0('Getting data for ', this.date))
    resp <-
      GET(
        url =  paste0(
          'https://api.fitbit.com/1/user/-/activities/heart/date/',
          this.date,
          '/1d/1sec/time/00:00/23:59.json'
        ),
        config(token = fitbit_token)
      )
    dat_string <-
      methods::as(resp, 'character')
    dat_list <-
      jsonlite::fromJSON(dat_string)
    df <-
      dat_list$`activities-heart-intraday`$dataset
    df %<>% dplyr::mutate(day.time = as.POSIXct(paste(this.date, time)),
                          day = this.date)
    saveRDS(df,
            file = paste0(
              '~/Desktop/intraday-data/heart-rate/heartrate_',
              this.date,
              '.RDS'
            ))
    return(df)
  } else{
    logging::loginfo(paste0('Data already exists for ', this.date))
    return()
  }
}

steps.df <- foreach(
  this.date = date_sequence,
  .combine = dplyr::bind_rows,
  .errorhandling = 'remove'
) %do% {
  if (!file.exists(paste0('~/Desktop/intraday-data/steps/steps_', this.date, '.RDS'))) {
    logging::loginfo(paste0('Getting data for ', this.date))
    resp <-
      GET(
        url = paste0(
          "https://api.fitbit.com/1/user/-/activities/steps/date/",
          this.date,
          "/1d/1min.json"
        ),
        config(token = fitbit_token)
      )
    dat_string <- methods::as(resp, 'character')
    dat_list <- jsonlite::fromJSON(dat_string)
    df <-
      dat_list$`activities-steps-intraday`$dataset
    df %<>% dplyr::mutate(day.time = as.POSIXct(paste(this.date, time)),
                          day = this.date) %>%
      dplyr::rename(steps = value)
    saveRDS(df,
            file = paste0(
              '~/Desktop/intraday-data/steps/steps_',
              this.date,
              '.RDS'
            ))
    return(df)
  } else{
    logging::loginfo(paste0('Data already exists for ', this.date))
    return()
  }
}

elevation.df <- foreach(
  this.date = date_sequence,
  .combine = dplyr::bind_rows,
  .errorhandling = 'remove'
) %do% {
  if (!file.exists(paste0(
    '~/Desktop/intraday-data/elevation/elevation_',
    this.date,
    '.RDS'
  ))) {
    logging::loginfo(paste0('Getting data for ', this.date))
    resp <-
      GET(
        url = paste0(
          "https://api.fitbit.com/1/user/-/activities/elevation/date/",
          this.date,
          "/1d/1min/time/00:00/23:59.json"
        ),
        config(token = fitbit_token)
      )
    dat_string <-
      methods::as(resp, 'character')
    dat_list <-
      jsonlite::fromJSON(dat_string)
    df <-
      dat_list$`activities-elevation-intraday`$dataset
    df %<>% dplyr::mutate(day.time = as.POSIXct(paste(this.date, time)),
                          day = this.date) %>%
      dplyr::rename(elevation = value)
    saveRDS(df,
            file = paste0(
              '~/Desktop/intraday-data/elevation/elevation_',
              this.date,
              '.RDS'
            ))
    return(df)
  } else{
    logging::loginfo(paste0('Data already exists for ', this.date))
    return()
  }
}

floors.df <- foreach(
  this.date = date_sequence,
  .combine = dplyr::bind_rows,
  .errorhandling = 'remove'
) %do% {
  if (!file.exists(paste0(
    '~/Desktop/intraday-data/floors/floors_',
    this.date,
    '.RDS'
  ))) {
    logging::loginfo(paste0('Getting data for ', this.date))
    resp <-
      GET(
        url = paste0(
          "https://api.fitbit.com/1/user/-/activities/floors/date/",
          this.date,
          "/1d/1min.json"
        ),
        config(token = fitbit_token)
      )
    dat_string <- methods::as(resp, 'character')
    dat_list <- jsonlite::fromJSON(dat_string)
    df <-
      dat_list$`activities-floors-intraday`$dataset
    df %<>% dplyr::mutate(day.time = as.POSIXct(paste(this.date, time)),
                          day = this.date) %>%
      dplyr::rename(floors = value)
    saveRDS(df,
            file = paste0(
              '~/Desktop/intraday-data/floors/floors_',
              this.date,
              '.RDS'
            ))
    return(df)
  } else{
    logging::loginfo(paste0('Data already exists for ', this.date))
    return()
  }
}
