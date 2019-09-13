# Pagina5
# Pagina4
# Pagina3

# start selenium server
# $ java -Dwebdriver.gecko.driver=geckodriver.exe -jar selenium-server-standalone-3.141.59.jar

library(RSelenium)
library(xml2)
library(rvest)
library(dplyr)

orase <- c("Bucuresti")

# Parametrii pentru filtre
data1 = c("[data-date = '2019-11-08']", "[data-date = '2019-11-09']")
data2 = c("[data-date = '2019-11-15']", "[data-date = '2019-11-16']")
data3 = c("[data-date = '2019-11-22']", "[data-date = '2019-11-23']")
data4 = c("[data-date = '2019-11-29']", "[data-date = '2019-11-30']")
sejur_list = list(data1, data2, data3, data4)

baie_privata <- TRUE
baie_privata <- FALSE


df_fin <- data.frame()
for (i in 1:length(sejur_list)) {  
  rmdSel <- remoteDriver(remoteServerAddr = "127.0.0.1",
                         port = 4444L,
                         browserName = "firefox")
  
  rmdSel$open()
  rmdSel$navigate("https://www.booking.com/")
  
  lang <- rmdSel$findElement(using = "css", value = "a.popover_trigger>img")
  lang$clickElement()
  
  ro <- rmdSel$findElement(using = "css", value = "a[hreflang=\"ro\"].no_target_blank>span.seldescription")
  ro$clickElement()
  
  search_location <- rmdSel$findElement(using = "css", value = "[name = 'ss']")
  search_location$sendKeysToElement(list(orase[1]))
  
  search_date_in <- rmdSel$findElement(using = "css", value = "div.sb-searchbox__input:nth-child(1)")
  search_date_in$clickElement()
  search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__control.bui-calendar__control--next")
  search_date_in$clickElement()
  search_date_in <- rmdSel$findElement(using = "css", value = "div.bui-calendar__display")
  
  search_date_in_cin <- rmdSel$findElement(using  = "css", value = sejur_list[[i]][1])
  search_date_in_cin$clickElement()
  search_date_in_cout <- rmdSel$findElement(using  = "css", value = sejur_list[[i]][2])
  search_date_in_cout$clickElement()
  
  # Cauta
  search_send <- rmdSel$findElement(using  = "css", value = "button.sb-searchbox__button")
  search_send$clickElement()
  
  # Hostel
  hot <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"ht_id-203\"]")
  hot$clickElement()
  Sys.sleep(2)
  
  # Numai camere disponibile
  cam <- rmdSel$findElement(using = "css", value = "div.filterbox[id=\"filter_out_of_stock\"]>div.filteroptions>a[data-id=\"oos-1\"]")
  cam$clickElement()
  Sys.sleep(2)
  
  # Baie privata
  baie <- rmdSel$findElement(using = "css", value = "div.filteroptions>a[data-id=\"roomfacility-38\"]" )
  baie$clickElement()
  # "div.filterbox[id=\"filter_min_bathrooms\"]>div.filteroptions>a[data-id=\"min_bathrooms-1\"]"
  Sys.sleep(2)
  
  # Pret RAMBURASBIL(anulare gratuita)/NERAMBURSABIL
  if (isTRUE(anulare_gratuita)) {
    ram <- rmdSel$findElement(using = "css", value = "div[id=\"filter_fc\"]>div.filteroptions>a.filterelement")
    ram$clickElement()
  }
  Sys.sleep(2)
  
  # Self-catering
  dejun <- rmdSel$findElement(using = "css", value = "div[id=\"filter_mealplan\"]>div.filteroptions>a[data-id=\"mealplan-999\"]")
  dejun$clickElement()
  #"div[id=\"filter_mealplan\"]>div.filteroptions>a.filterelement"
  
  Sys.sleep(2)
  
  # Numar de stele
  st <- rmdSel$findElement(using = "css", value = "div.filterbox>div.filteroptions > a[data-id=\"class-1\"]")
  st$clickElement()
  Sys.sleep(2)
  
  no_pages1 <- 1
  try({
    no_pages <- rmdSel$findElement(using = "css", value = "li.bui-pagination__item:nth-last-child(1) > a > div:nth-child(2)")
    no_pages <- no_pages$getElementText()[[1]]
    no_pages1 <- as.integer(no_pages)
  }, silent = TRUE
  )
  
  df <- data.frame()
  for(j in 1:no_pages1){
    rmdSel$executeScript(script = "window.scrollTo(0, document.body.scrollHeight);")
    booking <- read_html(rmdSel$getPageSource()[[1]])  
    
    stele <- booking %>% html_nodes(css = "i.bk-icon-wrapper>span.invisible_spoken") %>% html_text()
    hotel_name <- booking %>% html_nodes(css = "span.sr-hotel__name") %>% html_text()
    distanta <- booking %>% html_nodes(css = "div.sr_card_address_line>span:not([class])")%>% html_text()
    pret <- booking %>% html_nodes(css = "div.room_details>div>div>div:first-child>div.roomPrice>div.prco-wrapper>div>div.bui-price-display__value") %>% html_text()
    tip_camera <- booking %>% html_nodes(css = "div.room_details>div>div>div:first-child>div.roomName>div>a.room_link>strong") %>% html_text()
    nr_nopti <- booking %>%  html_nodes(css = "div.room_details>div>div>div:first-child>div.roomPrice>div.prco-wrapper>div.prco-ltr-right-align-helper>div.bui-price-display__label") %>% html_text()
    
    print(stele)
    print(hotel_name)
    
    culegere <- rep(Sys.Date(), length(hotel_name))
    z1 <- strsplit(gsub("\\]|\\'", "", sejur_list[[i]][1]), "-", fixed = TRUE)[[1]][4]
    z2 <- strsplit(gsub("\\]|\\'", "", sejur_list[[i]][2]), "-", fixed = TRUE)[[1]][4]
    period <- paste(paste(z1, z2, sep = "-"), "nov", sep = " ")
    sejur <- rep(period, length(hotel_name))
    rambursabil <- rep("DA", length(hotel_name))
    df1 <- data.frame(nr_stele = stele,
                      nume_hotel = hotel_name,
                      distanta = distanta,
                      tip_camera = tip_camera,
                      nr_nopti = nr_nopti,
                      culegere = culegere, 
                      sejur = sejur,
                      rambursabil = rambursabil,
                      pret = pret)
    df <- rbind(df, df1)
    
    if (j < no_pages1) { 
      print(j)
      next_page <- rmdSel$findElement(using = "css", value = "a.paging-next")
      next_page$clickElement()
    }
    
    Sys.sleep(2)
  }
  
  if (isTRUE(mic_dejun_inclus)) {
    names(df)[9] <- "pret_mic_dejun_inclus"
  } else {
    names(df)[9] <- "pret_fara_mic_dejun"
  }
  df_fin <- rbind(df_fin, df)
}


if (mic_dejun_inclus == TRUE) {
  df2t <- df_fin
}else if (mic_dejun_inclus == FALSE) {
  df2f <- df_fin
}


clean <- function (df) {
  df <- unique(df)
  for (i in 1:ncol(df)) {
    df[,c(i)] <- as.character(df[,c(i)])
  }
  df$nume_hotel <- gsub("\n", "", df$nume_hotel)
  df$distanta <- gsub("\n", "", df$distanta)
  df[,c(9)] <- gsub("\n", "", df[,c(9)])
  df[,c(9)] <- gsub("\\.", "", df[,c(9)])
  df[,c(9)] <- gsub("\\,", "", df[,c(9)])
  df[,c(9)] <- as.numeric(gsub("([0-9]+).*$", "\\1", df[,c(9)]))
  pers_nopti <- data.frame(do.call(rbind, strsplit(df$nr_nopti, ",", fixed=TRUE)))
  names(pers_nopti) <- c("nr_nopti", "nr_pers")
  df <- df[,-c(5)]
  df <- cbind(df, pers_nopti)
  return (df)
}


df2tc <- clean(df2t)
df2fc <- clean(df2f)


df2j <- df2fc %>% left_join(df2tc[,c(2,6,8)], by=c("nume_hotel"="nume_hotel","sejur"="sejur"))
df2j <- unique(df2j)

df2j$distanta <- gsub("la", "", df2j$distanta)
df2j$distanta <- gsub("de centru", "", df2j$distanta)
df2j$distanta <- trimws(df2j$distanta)

write.csv(df2j, paste0("hotel4_", Sys.Date(), ".csv"))





