# Load libraries
library(RSelenium)
library(rvest)
library(dplyr)
wd <- #YOUR PATH HERE
setwd(wd)

# Function to start RSelenium and create a remote driver
start_selenium <- function() {
  rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE, check = FALSE)
  remDr <- rD$client
  list(rD = rD, remDr = remDr)
}

# Function to extract data from a page
extract_page_data <- function(page) {
  listings <- page %>% html_nodes("div.cl-search-result")
  
  # Initialize vectors to store data for this page
  titles <- c()
  prices <- c()
  dates <- c()
  bedrooms <- c()
  links <- c()
  
  # Loop through each listing and extract data
  for (listing in listings) {
    title <- listing %>%
      html_attr("title")
    
    price <- listing %>%
      html_node("span.priceinfo") %>%
      html_text(trim = TRUE)
    
    date <- as.character(Sys.Date()) # Assuming date is the current scrape date # Assuming date is the current scrape date
    
    bedroom <- listing %>%
      html_node("span.post-bedrooms") %>%
      html_text(trim = TRUE)
    
    link <- listing %>%
      html_node("a") %>%
      html_attr("href")
    
    # Only keep listings with valid data
    if (!is.na(title) && !is.na(price) && !is.na(bedroom)) {
      titles <- c(titles, title)
      prices <- c(prices, price)
      dates <- c(dates, date)
      bedrooms <- c(bedrooms, bedroom)
      links <- c(links, link)
    }
  }
  
  list(titles = titles, prices = prices, dates = dates, bedrooms = bedrooms, links = links)
}

# Function to log data to a CSV file
log_data <- function(data, file_path) {
  if (!file.exists(file_path)) {
    write.csv(data, file_path, row.names = FALSE)
  } else {
    write.table(data, file_path, append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
  }
}

# Main script
run_script <- function() {
  # Record start time
  start_time <- Sys.time()
  
  # Start RSelenium
  selenium <- start_selenium()
  remDr <- selenium$remDr
  rD <- selenium$rD
  
  # Ensure RSelenium is stopped properly
  on.exit({
    remDr$close()
    rD$server$stop()
  }, add = TRUE)
  
  # Initialize variables to store listings
  all_titles <- c()
  all_prices <- c()
  all_dates <- c()
  all_bedrooms <- c()
  all_links <- c()
  
  # Define the base URL - you can change it to whatever
  base_url <- "https://vancouver.craigslist.org/search/vancouver-bc/apa?lat=49.2576&lon=-123.1319&search_distance=4.6
"
  
  # Navigate to the initial page
  remDr$navigate(base_url)
  Sys.sleep(10) # wait for 10 seconds
  
  # Loop to iterate over multiple pages
  repeat {
    page_source <- remDr$getPageSource()[[1]]
    page <- read_html(page_source)
    
    # Extract data from the current page
    page_data <- extract_page_data(page)
    all_titles <- c(all_titles, page_data$titles)
    all_prices <- c(all_prices, page_data$prices)
    all_dates <- c(all_dates, page_data$dates)
    all_bedrooms <- c(all_bedrooms, page_data$bedrooms)
    all_links <- c(all_links, page_data$links)
    
    # Check if there is a "next" button and it is not disabled
    next_button <- remDr$findElements(using = "css selector", value = "button.cl-next-page")
    if (length(next_button) == 0) {
      message("No more pages. Exiting loop.")
      break
    }
    
    # Check if the "next" button is disabled
    next_button_class <- next_button[[1]]$getElementAttribute("class")[[1]]
    if (grepl("disabled", next_button_class)) {
      message("Next button is disabled. Exiting loop.")
      break
    }
    
    # Click the "next" button to go to the next page
    next_button[[1]]$clickElement()
    Sys.sleep(10) # wait for the next page to load
  }
  
  # Record end time
  end_time <- Sys.time()
  
  # Calculate run time
  run_time <- difftime(end_time, start_time, units = 'mins')
  
  # Combine data into a dataframe
  apartments <- data.frame(
    title = all_titles,
    price = all_prices,
    date = all_dates,
    bedrooms = all_bedrooms,
    link = all_links,
    stringsAsFactors = FALSE
  )
  # Log data to a CSV file
  log_data(apartments, "vancouver_craigslist_rentals.csv") # Or whatever city you pick
  
  # Print the dataframe and run time
  print(paste("Run time:", run_time))
}

# Run the main script
run_script()
