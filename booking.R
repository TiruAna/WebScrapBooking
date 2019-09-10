
# start selenium server
# $ java -Dwebdriver.gecko.driver=geckodriver.exe -jar selenium-server-standalone-3.141.59.jar

library(RSelenium)
library(xml2)
library(rvest)

orase <- c("Bucuresti")

# Parametrii pentru filtre
nr_pers = 2; anulare_gratuita = TRUE
nr_pers = 2; anulare_gratuita = FALSE

nr_pers = 1; anulare_gratuita = TRUE
nr_pers = 1; anulare_gratuita = FALSE



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

# Mic dejun
dejun <- rmdSel$findElement(using = "css", value = "div[id=\"filter_mealplan\"]>div.filteroptions>a.filterelement")
dejun$clickElement()

# Pret RAMBURASBIL(anulare gratuita)/NERAMBURSABIL
if (isTRUE(anulare_gratuita)) {
  ram <- rmdSel$findElement(using = "css", value = "div[id=\"filter_fc\"]>div.filteroptions>a.filterelement")
  ram$clickElement()
}

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
  pret <- booking %>% html_nodes(css = "div.bui-price-display__value") %>% html_text()
  tip_camera <- booking %>% html_nodes(css = "a.room_link>strong") %>% html_text()
  nr_nopti <- booking %>%  html_nodes(css = "div.prco-ltr-right-align-helper>div.bui-price-display__label") %>% html_text()
  
  df1 <- data.frame(nr_stele = stele,
                    nume_hotel = hotel_name,
                    distanta = distanta,
                    tip_camera = tip_camera,
                    nr_nopti = nr_nopti, 
                    pret = pret)
  df <- rbind(df, df1)
    
  try({
    next_page <- rmdSel$findElement(using = "css", value = "a.paging-next")
    next_page$clickElement()
    }, silent = TRUE
    )
    Sys.sleep(2)
}

if (isTRUE(anulare_gratuita)) {
  names(df)[6] <- "pret_rambursabil"
} else {
  names(df)[6] <- "pret_nerambursabil"
}

if (nr_pers == 2 & anulare_gratuita == TRUE) {
  df2t <- df
}else if (nr_pers == 2 & anulare_gratuita == FALSE) {
  df2f <- df
}else if (nr_pers == 1 & anulare_gratuita == TRUE) {
  df1t <- df
}else {
  df1f <- df
}


clean <- function (df) {
  df <- unique(df)
  for (i in 1:ncol(df)) {
    df[,c(i)] <- as.character(df[,c(i)])
  }
  df$nume_hotel <- gsub("\n", "", df$nume_hotel)
  df$distanta <- gsub("\n", "", df$distanta)
  df[,c(6)] <- gsub("\n", "", df[,c(6)])
  df[,c(6)] <- gsub("\\.", "", df[,c(6)])
  df[,c(6)] <- as.numeric(gsub("([0-9]+).*$", "\\1", df[,c(6)]))
  pers_nopti <- data.frame(do.call(rbind, strsplit(df$nr_nopti, ",", fixed=TRUE)))
  names(pers_nopti) <- c("nr_nopti", "nr_pers")
  df <- df[,-c(5)]
  df <- cbind(df, pers_nopti)
  df$culegere <- Sys.Date()
  df$sejur <- "8noi"
  df$mic_dejun <- "DA"
  return (df)
}
c = clean(df2t)


df2t <- clean(df2t)
df2f <- clean(df2f)
df1t <- clean(df1t)
df1f <- clean(df1f)


df2j <- df2f %>% left_join(df2t[,c(2,6)], by=c("nume_hotel"="nume_hotel"))

write.csv(df2t, "df2t.csv")
write.csv(df2f, "df2f.csv")
write.csv(df1t, "df1t.csv")
write.csv(df1f, "df1f.csv")

df2tt <- clean(df2tt)
