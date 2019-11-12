# match suprafata hoteluri
setwd("//tiru/inout/Hoteluri_Ancheta PPP_septembrie_2019/Suprafata")
hotel16 <- hotel2_2019.09.16_s[!duplicated(hotel2_2019.09.16_s$nume_hotel), ]
hotel17 <- hotel2_2019_09_17[!duplicated(hotel2_2019_09_17$nume_hotel), ]
hotel18 <- hotel2_2019_09_18[!duplicated(hotel2_2019_09_18$nume_hotel), ]
hotel19 <- hotel2_2019_09_19[!duplicated(hotel2_2019_09_19$nume_hotel), ]
hotel20 <- hotel2_2019_09_20[!duplicated(hotel2_2019_09_20$nume_hotel), ]

hotel20 <- left_join(hotel1_2019_09_20, hotel16[,c(4,10)], by = c("nume_hotel"="nume_hotel"))
write.csv(hotel20, "hotel1_2019_09_20_s.csv")

j <- inner_join(hotel16, hotel17[,c(3, 7)], by = c("nume_hotel"="nume_hotel"))
j <- inner_join(j, hotel18[,c(3, 7)], by = c("nume_hotel"="nume_hotel"))
j <- inner_join(j, hotel19[,c(3, 7)], by = c("nume_hotel"="nume_hotel"))
j <- inner_join(j, hotel20[,c(3, 7)], by = c("nume_hotel"="nume_hotel"))

write.csv(j, "hoteluri_tip2_suprafata.csv")

hotel16 <- left_join(hotel2_2019_09_16, hotel2_supr[,c(6,22)], by = c("nume_hotel"="nume_hotel"))
write.csv(hotel16, "hotel2_2019_09_16_s.csv")
