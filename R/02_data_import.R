### 02 DATA IMPORT ###############################################################
source("R/01_startup.R")


# Functions to read multiple csvs -----------------------------------------

read_bixi <- function(flnm) {
  read_csv(flnm, show_col_types = F) %>% 
    mutate(filename = flnm)
}

read_weather <- function(flnm) {
  read_csv(flnm, show_col_types = F) %>% 
    mutate(filename = flnm) %>% 
    select(1:2,5,10,16,20,30) %>% 
    rename(longitude = 1, lattitude = 2, date = 3, temp = 4, precip = 5, wind = 6, weather = 7)
}

# Import 2022 weather, BIXi, and metro exit data --------------------------

weather_22 <- 
  list.files(path = "./data/",
           pattern = "*P1H.csv",
           full.names = T) %>% 
  map_df(~read_weather(.))

trips_22 <- 
  list.files(path = "./data/",
             pattern = "*deplacements.csv",
             full.names = T) %>% 
  map_df(~read_bixi(.))

stations_22 <- 
  list.files(path = "./data/",
             pattern = "*stations.csv",
             full.names = T) %>% 
  map_df(~read_bixi(.)) %>% 
  select(-filename) %>% 
  distinct() %>% 
  filter(!name == "Cadillac / Sherbrooke") %>% 
  filter(!name == "Place Émilie-Gamelin") %>% 
  mutate(latitude = case_when((pk == 856) ~ 45.492899,
                              TRUE ~ latitude)) %>% 
  mutate(longitude = case_when((pk == 856) ~ -73.556447,
                               TRUE ~ longitude))

metro_exits <- 
  read_csv("data/gtfs/stops.txt") %>% 
  filter(location_type == 2)

# Save processed data -----------------------------------------------------

qsavem(trips_22, stations_22, file = "data/bixi_22.qs")
qsavem(weather_22, file = "data/weather_22.qs")
qsavem(metro_exits, file = "data/metro.qs")
rm(trips_22, stations_22, weather_22, metro_exits, read_bixi, read_weather)
