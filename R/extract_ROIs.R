#========================================================================================================================
# Extract ROIs from pictures
#========================================================================================================================

# Packages
sapply( c('data.table', 'magrittr', 'sdb', 'ggplot2', 'colorZapper', 'DBI', 'RSQLite', 'foreach'),
        require, character.only = TRUE)

# set working directory
path_pictures = '//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA_RENAMED_lowres/'

#------------------------------------------------------------------------------------------------------------------------
# Change path in database
#------------------------------------------------------------------------------------------------------------------------

# names of the tables
dbnames = c('front', 'head_l', 'head_t', 'wing')

foreach(i = dbnames) %do% {
  
  # connection
  con = dbConnect(drv = RSQLite::SQLite(), dbname = paste0('./DATA/sqlite_files/REPH_', i, '.sqlite'))
  df = dbGetQuery(con, statement = "SELECT * FROM 'files'") %>% data.table
  
  # get the file name
  df[, filename := sub('.*/', '', path)]
  
  # file with new path
  dfn = df[, .(path = paste0(path_pictures, i, '/', filename), id)]
  
  dbExecute(con, "drop table files")
  dbWriteTable(con, 'files', dfn, row.names = FALSE)
  dbDisconnect(con)
    
}

# check tables
con = dbConnect(drv = RSQLite::SQLite(), dbname = paste0('./DATA/sqlite_files/REPH_front.sqlite'))
df = dbGetQuery(con, statement = "SELECT * FROM 'files'") %>% data.table
dbDisconnect(con)
df[1, ]
nrow(df)

#------------------------------------------------------------------------------------------------------------------------
# Extract ROIs
#------------------------------------------------------------------------------------------------------------------------

# set the directory containing the existing SQLITE file
cz_file = './DATA/sqlite_files/REPH_front.sqlite'
cz_file = './DATA/sqlite_files/REPH_head_l.sqlite'
cz_file = './DATA/sqlite_files/REPH_head_t.sqlite'
cz_file = './DATA/sqlite_files/REPH_wing.sqlite'

# open the SQLITE file
CZopen(path = cz_file)  

# extract the RGB in the ROIs
CZextractROI(parallel = TRUE) # parallel FALSE/TRUE 

