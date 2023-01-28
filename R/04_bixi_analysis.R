### 03 BIXI Analysis ##############################################################
source("R/01_startup.R")

qload("data/bixi_final_22.qs")
#qload("data/bixi_22.qs")
qload("data/weather_22.qs")

trips_22 <- 
  trips_22 %>% 
  mutate(precip = replace_na(precip,0),
         wind = replace_na(wind, 0))



# weather -----------------------------------------------------------------
arriving_weather <- 
  trips_22 %>% group_by(start_date, emplacement_pk_start, precip, wind) %>% summarise(c = n())

leaving_weather <- 
  trips_22 %>% group_by(end_date, emplacement_pk_end, precip, wind) %>% summarise(c = n())

test <- lm(c ~ precip + wind, arriving_weather)
summary(test)

test2 <- lm(c ~ precip + wind, leaving_weather)
summary(test2)

# metro -------------------------------------------------------------------


hii <- 
  trips_22 %>% left_join(stations_22, by = c("emplacement_pk_start" = "pk")) %>% 
  mutate(no_metro = case_when(exits400m == 0 ~ T,
                              TRUE ~ F),
         nonpro_metro = case_when(exits400m == 1 ~ T,
                              TRUE ~ F),
         pro_metro = case_when(exits400m == 2 ~ T,
                              TRUE ~ F)) %>% 
  group_by(start_date, emplacement_pk_start) %>% 
  summarise(c_metro = sum(no_metro), c_nonpro_metro = sum(nonpro_metro),
            c_pro_metro = sum(pro_metro)) 



# streets -----------------------------------------------------------------



library(tmap)

tmap_mode("view") +
  tm_shape(ped_streets_1200m) +
  tm_polygons("red") +
  tm_shape(exits_1200m) +
  tm_polygons()

tmap_mode("view") +
  tm_shape(exits_sf) +
  tm_dots() +
  tm_shape(stations_sf %>% filter(pk == 324)) +
  tm_dots() 

hrs %>% filter(duration_min < 15 )

ggplot(data = hrs) + 
  geom_histogram(bins = 5,mapping = aes(x = duration_sec))

stations_sf <- 
  stations_22 %>% 
  st_as_sf(crs = 4326,coords = c("latitude", "longitude")) %>% 
  st_transform(32618) %>% 
  st_coordinates()