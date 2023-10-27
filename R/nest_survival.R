#==============================================================================================================
# Nest survival
#==============================================================================================================

sapply( c('data.table', 'sdb', 'magrittr', 'auksRuak', 'sf'),
        require, character.only = TRUE)

# Data
con = dbcon('jkrietsch', db = 'REPHatBARROW')  
d = dbq(con, 'select * FROM NESTS')
DBI::dbDisconnect(con)

# subset years relevant for this study 
d = d[year_ %in% c(2017:2019)]

#--------------------------------------------------------------------------------------------------------------
# Days survived 
#--------------------------------------------------------------------------------------------------------------

# clutch complete 
d[, initiation := as.POSIXct(initiation)]
d[, clutch_complete := initiation + (clutch_size - 1) * 86400] # day from which incubation starts

# days survived since clutch complete
d[, days_survived_complete := difftime(nest_state_date, clutch_complete, units = 'days') |> as.numeric()]

# days survived since clutch initiation
d[, days_survived_initiation := difftime(nest_state_date, initiation, units = 'days') |> as.numeric()]

# quick check
d[, .(clutch_size, initiation, clutch_complete, days_survived_initiation, days_survived_complete)]

# subset nests with predation event or hatched
d = d[nest_state == 'P' | nest_state == 'H']

# subset nests with accurate information
d = d[nest_state_method > 0]

# summary 
d[, .N, nest_state_method] # 1 = temperature logger or rfid, 2 = GPS tag
d[plot == 'NARL', .N, nest_state_method] # only birds in study site

d[, .N, nest_state]

# subset relevant data
d = d[, .(year_, nest, male_id, female_id, found_datetime, plot, clutch_size, initiation, nest_state, 
          nest_state_date, nest_state_method, days_survived_complete, days_survived_initiation, comments)]

# save data
write.table(d, './DATA/NESTS_SURVIVAL.txt', quote = TRUE, sep = '\t', row.names = FALSE)


