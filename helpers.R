fetch_earthquake_data <- function(days = 30, min_magnitude = 0) {
  end_date <- Sys.time()
  start_date <- end_date - days * 24 * 60 * 60
  start_str <- format(start_date, "%Y-%m-%dT%H:%M:%S")
  end_str <- format(end_date, "%Y-%m-%dT%H:%M:%S")
  
  base_url <- "https://earthquake.usgs.gov/fdsnws/event/1/query"
  url <- sprintf(
    "%s?format=geojson&starttime=%s&endtime=%s&minmagnitude=%s&minlatitude=3&maxlatitude=15&minlongitude=33&maxlongitude=48&orderby=time&limit=1000",
    base_url, start_str, end_str, min_magnitude
  )
  
  tryCatch({
    response <- httr::GET(url, httr::user_agent("R-earthquake-dashboard"), httr::timeout(10))
    stop_for_status(response)
    data <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))
    
    if (length(data$features) == 0) return(data.frame(time = as.POSIXct(character()), magnitude = numeric()))
    
    earthquakes <- data.frame(
      time = as.POSIXct(data$features$properties$time / 1000, origin = "1970-01-01", tz = "UTC"),
      magnitude = data$features$properties$mag,
      place = data$features$properties$place,
      longitude = sapply(data$features$geometry$coordinates, `[`, 1),
      latitude = sapply(data$features$geometry$coordinates, `[`, 2),
      depth = sapply(data$features$geometry$coordinates, `[`, 3)
    )
    
    earthquakes$time <- force_tz(earthquakes$time, Sys.timezone())
    return(earthquakes)
  }, error = function(e) {
    warning("Error fetching earthquake data: ", e$message)
    return(data.frame(time = as.POSIXct(character()), magnitude = numeric()))
  })
}

fetch_earthquake_news <- function() {
  tryCatch({
    url <- "https://news.google.com/rss/search?q=ethiopian+earthquake&hl=en-US&gl=US&ceid=US:en"
    response <- httr::GET(url, httr::user_agent("R-earthquake-dashboard"), httr::timeout(5))
    stop_for_status(response)
    
    content_text <- httr::content(response, "text", encoding = "UTF-8")
    rss_data <- xml2::read_xml(content_text)
    news_items <- xml2::xml_find_all(rss_data, "//item")
    
    titles <- xml2::xml_text(xml2::xml_find_all(news_items, ".//title"))
    links <- xml2::xml_text(xml2::xml_find_all(news_items, ".//link"))
    
    if (length(titles) == 0) return(data.frame(Title = "No recent earthquake news", Link = ""))
    data.frame(Title = sprintf('<a href="%s" target="_blank">%s</a>', links, titles), stringsAsFactors = FALSE)
  }, error = function(e) {
    data.frame(Title = "Error fetching news", stringsAsFactors = FALSE)
  })
}