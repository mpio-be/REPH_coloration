#========================================================================================================================
# Egg analysis data summary
#========================================================================================================================

# Packages
sapply( c('data.table', 'magrittr', 'sdb', 'ggplot2'),
        require, character.only = TRUE)

# Data
con = dbcon('jkrietsch', db = 'REPHatBARROW')  
d = dbq(con, 'select * FROM CAPTURES')
DBI::dbDisconnect(con)

dr = readRDS('./DATA/raw_data_renamed.rds')

#------------------------------------------------------------------------------------------------------------------------
# Data summary
#------------------------------------------------------------------------------------------------------------------------

dr[, ID_year := paste0(ID, '_', substr(year_, 3,4 ))]

dr %>% nrow
unique(dr, by = 'ID') %>% nrow
unique(dr, by = 'ID_year') %>% nrow

dr[, .N, picture_type]


d = d[external == 0 & !is.na(head_t)]
d = d[, .(year_,  caught_time, ID, sex_observed, author, cam_id, head_t = head_t %>% as.numeric, head_l = head_l %>% as.numeric, 
          wing_l = wing_l %>% as.numeric, front = front %>% as.numeric, tail = tail %>% as.numeric)]

d[, ID_year := paste0(ID, '_', substring(year_, 3,4))]

ds = d[, .N, ID]
ds[, .N, N]

ds = unique(d, by = c('ID', 'year_')) 
ds = ds[, .N, .(ID, sex_observed)]
ds[, .N, .(years = N, sex_observed)]

ds[N > 1]

# unique ID
ds = unique(d, by = 'ID') 
ds %>% nrow
ds[, .N, sex_observed]
