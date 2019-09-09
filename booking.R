
# start selenium server
# $ java -Dwebdriver.gecko.driver=geckodriver.exe -jar selenium-server-standalone-3.141.59.jar

library(RSelenium)
library(xml2)
library(rvest)

orase <- c("Bucuresti")

# Parametrii pentru filtre
nr_pers = 2


rmdSel <- remoteDriver(remoteServerAddr = "127.0.0.1",
                       port = 4444L,
                       browserName = "firefox")

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
 
if (nr_pers == 1) {
  search_nr_pers <- rmdSel$findElement(using = "css", value = "div.xp__input-group>label.xp__input")
  search_nr_pers$clickElement()
  one_pers <- rmdSel$findElement(using = "css", value = "div.sb-group__field-adults>div.bui-stepper>div.bui-stepper__wrapper>button>span")
  one_pers$clickElement()
}
  
# Cauta
search_send <- rmdSel$findElement(using  = "css", value = "button.sb-searchbox__button")
search_send$clickElement()

# Numar de stele
st <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"class-3\"]")
st$clickElement()
st4 <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"class-4\"]")
st4$clickElement()

# Hotel
hot <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"ht_id-204\"]")
hot$clickElement()

# Numai camere disponibile
cam <- rmdSel$findElement(using = "css", value = "div.filterbox[id=\"filter_out_of_stock\"]>div.filteroptions>a[data-id=\"oos-1\"]")
cam$clickElement()

# # Lant hotelier
# if (nr_pers == 2) {
#   lant1 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1029\"]")
#   lant1$clickElement()
#   lant2 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1051\"]")
#   lant2$clickElement()
#   lant3 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1050\"]")
#   lant3$clickElement()
#   lant4 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1045\"]")
#   lant4$clickElement()
#   lant5 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1053\"]")
#   lant5$clickElement()
# } else {
#   lant1 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1029\"]")
#   lant1$clickElement()
#   lant5 <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"chaincode-1053\"]")
#   lant5$clickElement()
# }

# Mic dejun
dejun <- rmdSel$findElement(using = "css", value = "div[id=\"filter_mealplan\"]>div.filteroptions>a.filterelement")
dejun$clickElement()

# Pret RAMBURASBIL(anulare gratuita)/NERAMBURSABIL
ram <- rmdSel$findElement(using = "css", value = "div[id=\"filter_fc\"]>div.filteroptions>a.filterelement")
ram$clickElement()



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
  
  stele <- booking %>% html_nodes(css = "i.bk-icon-wrapper>span.invisible_spoken") %>% html_text()
  hotel_name <- booking %>% html_nodes(css = "span.sr-hotel__name") %>% html_text()
  distanta <- booking %>% html_nodes(css = "div.sr_card_address_line>span:not([class])")%>% html_text()
  pret <- booking %>% html_nodes(css = "div.bui-price-display__value") %>% html_text()
  tip_camera <- booking %>% html_nodes(css = "a.room_link>strong") %>% html_text()
  nr_nopti <- booking %>%  html_nodes(css = "div.prco-ltr-right-align-helper>div.bui-price-display__label") %>% html_text()
  
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


try({
  hotels_only <- rmdSel$findElement(using  = "xpath", value = "//span[contains(., 'Hotels') and @class = 'filter_label']")
  hotels_only$clickElement()
  hotels_only <- rmdSel$findElement(using  = "xpath", value = "//span[contains(., 'Guesthouses')]")
  hotels_only$clickElement()
}, silent = TRUE)
# no_nigths <- rmdSel$findElement(using = "xpath", value = "//span[contains(., 'For 2 nights')]")
# no_nigths$clickElement()
  
  


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

hotel_name2 <- booking %>% html_nodes(css = "span.sr-hotel__name") %>% html_text()
pret2 <- booking %>% html_nodes(css = "div.bui-price-display__value") %>% html_text()
