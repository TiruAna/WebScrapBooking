
# 1. Descarcare date

# start selenium server
# $ java -Dwebdriver.gecko.driver=geckodriver.exe -jar selenium-server-standalone-3.141.59.jar

library(RSelenium)
library(xml2)
library(rvest)
?remoteDriver

orase <- c("Bucuresti", "Constanta", "Mamaia", "Eforie Nord", "Eforie Sud", "Neptun Constanta", "Venus Constanta", "Saturn Constanta", "Jupiter Constanta", "Olimp Constanta", "Cap Aurora Constanta", "Costinesti Constanta", "Navodari Constanta", 
           "Brasov", "Azuga", "Predeal", "Poiana Brasov", "Bran", "Sinaia", "Busteni")


rmdSel <- remoteDriver(remoteServerAddr = "127.0.0.1",
                       port = 4444L,
                       browserName = "firefox")
# driver<- rsDriver(browser=c("firefox"))
# remDr <- driver[["client"]]
# remDr$open()

booking_data <- list()

for(i in 1:length(orase)){
  
  rmdSel$open()
  rmdSel$navigate("https://www.booking.com/")
  
  search_location <- rmdSel$findElement(using = "css", value = "[name = 'ss']")
  search_location$sendKeysToElement(list(orase[i]))
  search_date_in <- rmdSel$findElement(using = "css", value = "div.sb-searchbox__input:nth-child(1)")
  search_date_in$clickElement()
  search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__control.bui-calendar__control--next")
  search_date_in$clickElement()
  search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__display")
  search_date_in_cin <- rmdSel$findElement(using  = "css", value = "[data-date = '2019-11-08']")
  search_date_in_cin$clickElement()
  search_date_in_cout <- rmdSel$findElement(using  = "css", value = "[data-date = '2019-11-10']")
  search_date_in_cout$clickElement()
  search_send <- rmdSel$findElement(using  = "css", value = "button.sb-searchbox__button")
  search_send$clickElement()
  try({
    
    hotels_only <- rmdSel$findElement(using  = "xpath", value = "//span[contains(., 'Hotels') and @class = 'filter_label']")
    hotels_only$clickElement()
    hotels_only <- rmdSel$findElement(using  = "xpath", value = "//span[contains(., 'Guesthouses')]")
    hotels_only$clickElement()
  }, silent = TRUE)
  # no_nigths <- rmdSel$findElement(using = "xpath", value = "//span[contains(., 'For 2 nights')]")
  # no_nigths$clickElement()
  try({
    no_pages <- rmdSel$findElement(using = "css", value = "li.bui-pagination__item:nth-last-child(1) > a > div:nth-child(2)")
    no_pages <- no_pages$getElementText()[[1]] 
    no_pages1 <- as.integer(no_pages)
  }, silent = TRUE
  )
  
  oras <- list()
  for(j in 1:no_pages1){
    rmdSel$executeScript(script = "window.scrollTo(0, document.body.scrollHeight);")
    
    booking <- read_html(rmdSel$getPageSource()[[1]])  
    hotel_name <- booking %>% html_nodes(css = "span.sr-hotel__name") %>% html_text()
    stele <- booking %>% html_nodes(css = "span.sr-hotel__name, div.sr_item_main_block > i[title]") %>% html_text()
    pret <- booking %>% html_nodes(css = "strong.price, div.prco-ltr-right-align-helper") %>% html_text()
    tip_camera <- booking %>% html_nodes(css = "span.room_link > strong") %>% html_text()
    mic_dejun <- booking %>% html_nodes(css = "span.sr-hotel__name, sup.sr_room_reinforcement") %>% html_text()
    disponibilitate <- booking %>% html_nodes(css = "a.hotel_name_link.url") %>% html_text()
    distanta <-  booking %>% html_nodes(css = ".distfromdest_clean") %>% html_text()
    
    oras[[j]] <- list(hotel_name = hotel_name, stele = stele, pret = pret, tip_camera = tip_camera, mic_dejun = mic_dejun, disponibilitate = disponibilitate, distanta = distanta)
    
    try({next_page <- rmdSel$findElement(using = "css", value = "a.paging-next")
    next_page$clickElement()}, silent = TRUE)
    Sys.sleep(2)
  }
  booking_data[[i]] <- oras
  rmdSel$close()
}

names(booking_data) <- orase






# 2. Salvare date ===================================================================================================

# 1. Luni
saveRDS(booking_data, "booking_19_21_luni.rds")
rm(list = ls())

# 2. Marti
saveRDS(booking_data, "booking_19_21_marti.rds")
rm(list = ls())

# 3. Miercuri
saveRDS(booking_data, "booking_19_21_miercuri.rds")
rm(list = ls())

# 4. Joi
saveRDS(booking_data, "booking_19_21_joi.rds")
rm(list = ls())

# 5. Vineri
saveRDS(booking_data, "booking_19_21_vineri.rds")
rm(list = ls())
