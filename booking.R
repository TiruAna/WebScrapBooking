
# start selenium server
# $ java -Dwebdriver.gecko.driver=geckodriver.exe -jar selenium-server-standalone-3.141.59.jar

library(RSelenium)
library(xml2)
library(rvest)


orase <- c("Bucuresti")

rmdSel <- remoteDriver(remoteServerAddr = "127.0.0.1",
                       port = 4444L,
                       browserName = "firefox")

# driver<- rsDriver(browser=c("firefox"))
# remDr <- driver[["client"]]
# remDr$open()

booking_data <- list()

rmdSel$open()
rmdSel$navigate("https://www.booking.com/")
  
search_location <- rmdSel$findElement(using = "css", value = "[name = 'ss']")
search_location$sendKeysToElement(list(orase[1]))
  
search_date_in <- rmdSel$findElement(using = "css", value = "div.sb-searchbox__input:nth-child(1)")
search_date_in$clickElement()

search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__control.bui-calendar__control--next")
search_date_in$clickElement()
  
search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__display")
search_date_in_cin <- rmdSel$findElement(using  = "css", value = "[data-date = '2019-11-08']")
search_date_in_cin$clickElement()
search_date_in_cout <- rmdSel$findElement(using  = "css", value = "[data-date = '2019-11-10']")
search_date_in_cout$clickElement()
 
search_nr_pers <- rmdSel$findElement(using = "css", value = "div.xp__input-group>label.xp__input")
search_nr_pers$clickElement() 

one_pers <- rmdSel$findElement(using = "css", value = "div.sb-group__field-adults>div.bui-stepper>div.bui-stepper__wrapper>button>span")
one_pers$clickElement()  

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
  booking <- read_html(rmdSel$getPageSource()[[j]])  
  
  hotel_name <- booking %>% html_nodes(css = "span.sr-hotel__name") %>% html_text()
  stele <- booking %>% html_nodes(css = "span.sr-hotel__name, div.sr_item_main_block > i[title]") %>% html_text()
  pret <- booking %>% html_nodes(css = "strong.price, div.prco-ltr-right-align-helper") %>% html_text()
  tip_camera <- booking %>% html_nodes(css = "span.room_link > strong") %>% html_text()
  mic_dejun <- booking %>% html_nodes(css = "span.sr-hotel__name, sup.sr_room_reinforcement") %>% html_text()
  disponibilitate <- booking %>% html_nodes(css = "a.hotel_name_link.url") %>% html_text()
  distanta <-  booking %>% html_nodes(css = ".distfromdest_clean") %>% html_text()
    
  oras[[j]] <- list(hotel_name = hotel_name,
                    stele = stele, 
                    pret = pret, 
                    tip_camera = tip_camera, 
                    mic_dejun = mic_dejun, 
                    disponibilitate = disponibilitate,
                    distanta = distanta)
    
  try({
    next_page <- rmdSel$findElement(using = "css", value = "a.paging-next")
    next_page$clickElement()
    }, silent = TRUE
    )
    Sys.sleep(2)
}
  booking_data[[1]] <- oras
  rmdSel$close()


names(booking_data) <- orase



x <- read_html("https://www.booking.com/searchresults.ro.html?label=gen173nr-1FCAEoggI46AdIM1gEaMABiAEBmAEguAEXyAEP2AEB6AEB-AELiAIBqAIDuAK-8tLrBcACAQ&sid=59510b199f80252755baac8448d29868&sb=1&src=index&src_elem=sb&error_url=https%3A%2F%2Fwww.booking.com%2Findex.ro.html%3Flabel%3Dgen173nr-1FCAEoggI46AdIM1gEaMABiAEBmAEguAEXyAEP2AEB6AEB-AELiAIBqAIDuAK-8tLrBcACAQ%3Bsid%3D59510b199f80252755baac8448d29868%3Bsb_price_type%3Dtotal%26%3B&ss=Bucure%C8%99ti%2C+Regiunea+Bucuresti+-+Ilfov%2C+Rom%C3%A2nia&is_ski_area=0&checkin_monthday=8&checkin_month=11&checkin_year=2019&checkout_monthday=10&checkout_month=11&checkout_year=2019&group_adults=2&group_children=0&no_rooms=1&b_h4u_keep_filters=&from_sf=1&ss_raw=Bucuresti&ac_position=0&ac_langcode=ro&ac_click_type=b&dest_id=-1153951&dest_type=city&iata=BUH&place_id_lat=44.4333&place_id_lon=26.1&search_pageview_id=9b133a5f4ad8019f&search_selected=true") %>%
     html_nodes("div.filterbox>div.filteroptions > a[data-id=\"class-3\"]") %>%
     html_text("href")

  booking %>%
  html_nodes("div.filterbox>div.filteroptions > a[data-id=\"class-3\"]") %>%
  html_attr("href")
  
  
  st <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"class-3\"]")
  st$clickElement()
  
  st4 <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"class-4\"]")
  st4$clickElement()

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

*label.bui-checkbox>div.bui-checkbox__label>span.filter_label