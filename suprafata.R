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
hot <- read_html(rmdSel$getPageSource()[[1]])  
lin <- hot %>% html_nodes(css = "div.nodates_hotels>div:nth-child(2)>div>div>div>div>h3>a") %>% html_attr("href")
lin <- gsub("\n", "", lin)
lin <- paste0("https://www.booking.com", lin)

rmdSel$open()
rmdSel$navigate(lin)

# Click camera
click_camera <- rmdSel$findElement(using  = "css", value = "div.bodyconstraint_increased-min-width>div>div>div>div.rlt-right>div.hotelchars>div>div>div.description>table>tbody>tr.odd:first-child>td>div>div>a.jqrt>i.rt_room_type_ico")
click_camera$clickElement()

supr <- read_html(rmdSel$getPageSource()[[1]])
x <- supr %>% html_nodes(css = "div.room-lightbox-container>div>div.hprt-lightbox-right-container") %>% html_text()
x <- gsub("\n", "", x)
x <- gsub("\t", "", x)
x <- gsub(" ", "", x)

gsub("m².*","",x)


gsub("[^[:digit:].]", "",  x)

str_extract(x, "[[:digit:]]+")

as.numeric(gsub("[^\\d]+", "", x, perl=TRUE))
click_hot <- rmdSel$findElement(using  = "css", value = "div>div>div>div>div>h3>a>span")
click_hot$clickElement()
Sys.sleep(2)
