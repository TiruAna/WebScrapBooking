# Suprafata
library(RSelenium)
library(xml2)
library(rvest)

hotel1_2019.09.16 <- hoteluri_tip2_suprafata

s <- Sys.time()
sup <- c()
hot <- c()

for (i in 1:10) {
  print(i)
  rmdSel <- remoteDriver(remoteServerAddr = "127.0.0.1",
                         port = 4444L,
                         browserName = "firefox")
  
  rmdSel$open()
  rmdSel$navigate("https://www.booking.com/")
  Sys.sleep(2)
  
  lang <- rmdSel$findElement(using = "css", value = "a.popover_trigger>img")
  lang$clickElement()
  Sys.sleep(2)
  
  ro <- rmdSel$findElement(using = "css", value = "a[hreflang=\"ro\"].no_target_blank>span.seldescription")
  ro$clickElement()
  Sys.sleep(2)
  
  sh <- paste("Bucuresti", hotel1_2019.09.16$nume_hotel[i])
  
  search_location <- rmdSel$findElement(using = "css", value = "[name = 'ss']")
  search_location$sendKeysToElement(list(sh))
  hot <- c(hot, hotel1_2019.09.16$nume_hotel[i])
  
  # Cauta
  search_send <- rmdSel$findElement(using  = "css", value = "button.sb-searchbox__button")
  search_send$clickElement()
  Sys.sleep(2)
  
  
  # Click hotel
  hot <- read_html(rmdSel$getPageSource()[[1]])  
  lin <- hot %>% html_nodes(css = "div.nodates_hotels>div:nth-child(2)>div>div>div>div>h3>a") %>% html_attr("href")
  Sys.sleep(2)
  lin <- gsub("\n", "", lin)
  lin <- paste0("https://www.booking.com", lin)
  
  
  #rmdSel$open()
  rmdSel$navigate(lin)
  Sys.sleep(2)
  
  # Extract nume de camere
  cam <- read_html(rmdSel$getPageSource()[[1]])  
  nume <- cam %>% html_nodes(css = "div>a.jqrt") %>% html_text()
  nume <- gsub("\n", "", nume)
  nume <- gsub("\\.", "", nume)
  num <- trimws(as.character.POSIXt(nume))
  pos <- which(num == hotel1_2019.09.16$tip_camera[i])
  
  
  if (length(pos) == 0) {
    # Click camera
    click_camera <- rmdSel$findElement(using  = "css", value = "div.bodyconstraint_increased-min-width>div>div>div>div.rlt-right>div.hotelchars>div>div>div.description>table>tbody>tr.odd:first-child>td>div>div>a.jqrt>i.rt_room_type_ico")
    click_camera$clickElement()
    Sys.sleep(2)
  } else {
    
    if (pos == 2) {
      pos = 3
    } else if (pos == 3) {
      pos = 5
    } else if (pos == 4) {
      pos = 7
    } else if (pos == 5) {
      pos = 9
    } else if (pos == 6) {
      pos = 11
    } else if (pos == 7) {
      pos = 13
    } else if (pos == 8) {
      pos = 15
    } else if (pos == 9) {
      pos = 17
    }
    
    v <- paste0("table#maxotel_rooms>tbody>tr:nth-child(", pos, ")>td>div>div>a.jqrt>i.rt_room_type_ico")
    
    click_camera <- rmdSel$findElement(using  = "css", value = v)
    
    click_camera$clickElement()
    Sys.sleep(2)
  }
  
  
  supr <- read_html(rmdSel$getPageSource()[[1]])
  x <- supr %>% html_nodes(css = "div.room-lightbox-container>div>div.hprt-lightbox-right-container") %>% html_text()
  x <- gsub("\n", "", x)
  x <- gsub("\t", "", x)
  x <- gsub(" ", "", x)
  x <- gsub("m².*","",x)
  x <- gsub("[^[:digit:].]", "",  x)
  if (length(x)==0) {
    hotel1_2019.09.16$suprafata[i] <- NA
  } else {
    hotel1_2019.09.16$suprafata[i] <- x
  }
  
  sup <- c(sup, x)
  rmdSel$close()
}

t <- Sys.time()-s

test <- hotel1_2019.09.16 %>% group_by(suprafata) %>% summarise(n=n())

hotel2_supr$suprafata <- as.numeric(hotel2_supr$suprafata)

s <- subset(hotel2_supr, hotel2_supr$suprafata < 20)

write.csv(hotel1_2019.09.16, "hotel2_supr.csv")
