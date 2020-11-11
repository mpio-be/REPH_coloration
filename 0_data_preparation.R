#========================================================================================================================
# REPH body picture analysis data preparation
#========================================================================================================================

# Packages
sapply( c('data.table', 'magrittr', 'sdb', 'ggplot2', 'foreach', 'doFuture', 'reshape'),
        require, character.only = TRUE)

# Data
con = dbcon('jkrietsch', db = 'REPHatBARROW')  
d = dbq(con, 'select * FROM CAPTURES')
DBI::dbDisconnect(con)

# path to pictures
raw_path = '//ds/raw_data_kemp/FIELD/Barrow/'
new_path = '//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA_RENAMED/'

#------------------------------------------------------------------------------------------------------------------------
# Prepare data for analysis
#------------------------------------------------------------------------------------------------------------------------

# list all files
dff = data.table(year_ = c(rep(2017, 4), rep(2018, 4), rep(2019, 4)),
                 cam_id = rep(c(1:4), 3))

df = foreach(i = 1:nrow(dff), .combine = 'rbind') %do% {
  
  x = paste0(raw_path, dff$year_[i], '/DATA/RAW_DATA/PICTURES/CAMERA', dff$cam_id[i], '/')
  y = list.files(x, pattern = '.JPG') 
  
  dx = data.table(year_     = rep(dff$year_[i], length(y)),
                  cam_id    = rep(dff$cam_id[i], length(y)),
                  file_name = y,
                  raw_path  = x)
  
}

# convert in photo_id       
df[, photo_id := substring(file_name, 5, 8) %>% as.numeric]


# check data
d = d[external == 0 & !is.na(head_t)]
d = d[, .(year_,  caught_time, ID, author, cam_id, head_t = head_t %>% as.numeric, head_l = head_l %>% as.numeric, 
          wing_l = wing_l %>% as.numeric, front = front %>% as.numeric, tail = tail %>% as.numeric)]

# melt data to picture type
d = melt(setDT(d), id.vars = 1:5) %>% data.table
setnames(d, c('variable', 'value'), c('picture_type', 'photo_id'))

# exclude NA
d = d[!is.na(photo_id)]

# merge with file name
d = merge(d, df, by = c('year_', 'cam_id', 'photo_id'), all.x = TRUE)

# any missing?
d[is.na(file_name)]




# new name (year_ID_photo_ID)
d[, new_file_name := paste0('ID', ID, '_', as.Date(caught_time), '_type_', picture_type, '_c', cam_id,'_p', photo_id, '.JPG')]

# path connections
d[, raw_path := paste0(raw_path, file_name)] # raw data path
d[, new_path := paste0(new_path, new_file_name)] # renamed data path

# loop to copy and rename files
registerDoFuture()
plan(multiprocess)

foreach(i = 1:nrow(d)) %dopar%
  
  file.copy(from = d$raw_path[i], to = d$new_path[i], overwrite = FALSE, recursive = FALSE,
            copy.mode = TRUE, copy.date = FALSE)


# save table with raw and new names
saveRDS(d, './DATA/raw_data_renamed.rds')


