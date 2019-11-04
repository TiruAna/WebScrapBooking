# Suprafata
library(RSelenium)
library(xml2)
library(rvest)

hot1 <- read.csv("hotel1_2019-09-19.csv")

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
search_location$sendKeysToElement(list(hot1$nume_hotel[2]))

# Cauta
search_send <- rmdSel$findElement(using  = "css", value = "button.sb-searchbox__button")
search_send$clickElement()
Sys.sleep(2)

# Click hotel
click_hot <- rmdSel$findElement(using  = "css", value = "div>div>div>div>div>h3>a>span")
click_hot$clickElement()
Sys.sleep(2)

# Click camera
click_camera <- rmdSel$findElement(using  = "css", value = "td.ftd>div>div.room-info>a.jqrt:first-of-type")
click_camera$clickElement()
Sys.sleep(2)

"td.ftd>div>div.room-info>a"
