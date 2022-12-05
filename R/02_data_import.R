### 02 DATA IMPORT ###############################################################
source("R/01_startup.R")


# Function to read multiple csvs ------------------------------------------

read_plus <- function(flnm) {
  read_csv(flnm, show_col_types = F) %>% 
    mutate(filename = flnm)
}

# Import 2022 BIXi data ---------------------------------------------------


trips_22 <- 
  list.files(path = "./data/",
             pattern = "*deplacements.csv",
             full.names = T) %>% 
  map_df(~read_plus(.))

stations_22 <- 
  list.files(path = "./data/",
             pattern = "*stations.csv",
             full.names = T) %>% 
  map_df(~read_plus(.))


# testing -----------------------------------------------------------------

stations_22 %>% group_by(pk) %>% count(latitude) %>% count(pk) %>% view()


# Save processed data -----------------------------------------------------

qsavem(trips_22, stations_22, file = "data/bixi_22.qs")
rm(trips_22,stations_22)


