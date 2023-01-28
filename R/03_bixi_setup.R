### 03 BIXI SETUP ##############################################################
source("R/01_startup.R")


qload("data/bixi_22.qs")
qload("data/weather_22.qs")
qload("data/metro.qs")
qload("data/ped_streets.qs")




# Trip Categorization -----------------------------------------------------


trips_22 <- 
  trips_22 %>% 
  mutate(start_date = floor_date(start_date, "hour"), end_date = floor_date(end_date, "hour")) %>% 
  mutate(length = case_when((duration_sec / 60) <= 15 ~ 0,
                            (duration_sec / 60) >= 45 ~ 2,
                            TRUE ~ 1))

# Trip Weather Data -------------------------------------------------------


trips_22 <- 
  trips_22 %>% 
  left_join(weather_22, by = c("start_date" = "date")) %>% 
  select(-c(longitude,latitude))


# Exit and Street buffers -------------------------------------------------


exits_sf <- 
  metro_exits %>% 
  st_as_sf(crs = 4326,coords = c("stop_lon","stop_lat")) %>% 
  st_transform(32618)

exits_400m <- 
  exits_sf %>% 
  st_buffer(400)

# exits_800m <- 
#   exits_sf %>% 
#   st_buffer(800)
# 
# exits_1200m <- 
#   exits_sf %>% 
#   st_buffer(1200)

ped_streets_400m <- 
  ped_streets %>% 
  st_buffer(400)

# ped_streets_800m <- 
#   ped_streets %>% 
#   st_buffer(800)
# 
# ped_streets_1200m <- 
#   ped_streets %>% 
#   st_buffer(1200)


# Mark Stations -----------------------------------------------------------

stations_sf <-
  stations_22 %>% 
  st_as_sf(crs = 4326,coords = c("longitude", "latitude")) %>% 
  st_transform(32618)

metrocat <- function(x) {  
  if (length(x) == 0) {
    return (0) }
  for(i in 1:length(x)) {
    if (x[i] %in% c(17:35,86:88)) {
      return(2) }}
  return (1)
}

stations_exits_400m <- 
  st_intersects(stations_sf, exits_400m) %>%  
  sapply(metrocat)

# stations_exits_800m <- 
#   st_intersects(stations_sf, exits_800m) %>%  
#   sapply(metrocat)
# 
# stations_exits_1200m <- 
#   st_intersects(stations_sf, exits_1200m) %>%  
#   sapply(metrocat)

stations_22 <- 
  stations_22 %>% 
  mutate(exits400m = stations_exits_400m)


stations_streets_400m <- 
  st_intersects(stations_sf, ped_streets_400m, sparse = F) %>% 
  as_tibble()

colnames(stations_streets_400m) <- ped_streets$name

# stations_streets_800m <- 
#   st_intersects(stations_sf, ped_streets_800m, sparse = F) %>% 
#   as_tibble()
# 
# colnames(stations_streets_800m) <- ped_streets$name
# 
# stations_streets_1200m <- 
#   st_intersects(stations_sf, ped_streets_1200m, sparse = F) %>% 
#   as_tibble()
# 
# colnames(stations_streets_1200m) <- ped_streets$name


stations_22 <- 
  stations_22 %>% 
  bind_cols(stations_streets_400m)
  
# Save processed data -----------------------------------------------------

qsavem(trips_22, stations_22, file = "data/bixi_final_22.qs")
rm(exits_400m, exits_sf, metro_exits, ped_streets, ped_streets_400m, stations_sf, stations_streets_400m,
   trips_22, stations_22, weather_22, stations_exits_400m, metrocat)

   