### 02 DATA IMPORT ###############################################################
source("R/01_startup.R")


# Functions to read multiple csvs -----------------------------------------

read_bixi <- function(flnm) {
  read_csv(flnm, show_col_types = F)
}

read_weather <- function(flnm) {
  read_csv(flnm, show_col_types = F) %>% 
    mutate(filename = flnm) %>% 
    select(1:2,5,10,16,20) %>% 
    rename(longitude = 1, latitude = 2, date = 3, temp = 4, precip = 5, wind = 6)
}

# Import 2022 weather, BIXi, metro exit, and pedestrian street data -------

weather_22 <- 
  list.files(path = "./data/",
           pattern = "*P1H.csv",
           full.names = T) %>% 
  map_df(~read_weather(.))

trips_22 <- 
  list.files(path = "./data/",
             pattern = "*deplacements.csv",
             full.names = T) %>% 
  map_df(~read_bixi(.)) %>% 
  mutate(emplacement_id = row_number()) %>% 
  select(emplacement_id, 1:5) %>% 
  mutate(duration_sec = time_length(interval(start_date, end_date), "seconds"))


stations_22 <- 
  list.files(path = "./data/",
             pattern = "*stations.csv",
             full.names = T) %>% 
  map_df(~read_bixi(.)) %>% 
  distinct() %>% 
  filter(!name == "Cadillac / Sherbrooke") %>% 
  filter(!name == "Place Émilie-Gamelin") %>% 
  mutate(latitude = case_when((pk == 856) ~ 45.492899,
                              TRUE ~ latitude)) %>% 
  mutate(longitude = case_when((pk == 856) ~ -73.556447,
                               TRUE ~ longitude))

metro_exits <- 
  read_csv("data/gtfs/stops.txt") %>%
  filter(location_type == 2) %>% 
  select(1:5)

ped_streets <- st_read("data/pedstreets") %>% 
  mutate(street_id = row_number()) %>% 
  rename(name = layer) %>% 
  select(2,1)

# Save processed data -----------------------------------------------------

qsavem(trips_22, stations_22, file = "data/bixi_22.qs")
qsavem(weather_22, file = "data/weather_22.qs")
qsavem(metro_exits, file = "data/metro.qs")
qsavem(ped_streets, file = "data/ped_streets.qs")

rm(trips_22, stations_22, weather_22, metro_exits, read_bixi, read_weather, ped_streets)
