sapply( c('data.table', 'sdb', 'magrittr', 'ggplot2', 'DBI'),
        require, character.only = TRUE)

#--------------------------------------------------------------------------------------------------------------
# Time bleeding after capture
#--------------------------------------------------------------------------------------------------------------

# data
con = dbcon('jkrietsch', db = 'REPHatBARROW')  
d  = dbq(con, 'select * FROM CAPTURES')
dt = dbq(con, 'select * FROM TESTO')
dbDisconnect(con)

# add date
dt[, date_ := as.Date(date_)]
d[, date_ := as.Date(caught_time)]
d[, caught_time := as.POSIXct(caught_time)]
d[, bled_time := as.POSIXct(bled_time)]

d = merge(d[, !c('GnRH'), with = FALSE], dt[, .(ID, date_, GnRH, volume, T)], by = c('ID', 'date_'), 
          all.x = TRUE)

# exclude dead or injured birds
d[is.na(dead), dead := 0]
d = d[dead != 1]

# bleeding time
d[, diff_caught_bled := difftime(bled_time, caught_time, units = 'mins') %>% as.numeric]

# summary
d[!is.na(diff_caught_bled) & !is.na(T), 
  .(mean = mean(diff_caught_bled), sd = sd(diff_caught_bled), 
    min = min(diff_caught_bled), max = max(diff_caught_bled), .N)]


#--------------------------------------------------------------------------------------------------------------
# Timing nests found
#--------------------------------------------------------------------------------------------------------------

# data
con = dbcon('jkrietsch', db = 'REPHatBARROW')  
d  = dbq(con, 'select * FROM NESTS')
dbDisconnect(con)

# subset study site and period
d = d[plot == 'NARL' & year_ > 2016]

# check N
nrow(d) # 174
d[, .N, by = year_]


# clutches found incomplete
d[initial_clutch_size < clutch_size] |> nrow() / nrow(d) * 100 # 82

# when others found?
d[, initiation := as.POSIXct(initiation)]
d[, found_datetime := as.POSIXct(found_datetime)]

d[, complete := initiation + clutch_size * 86400]

d[, age_found := difftime(found_datetime, initiation, units = 'days') |> as.numeric()]
d[, age_found_complete := difftime(found_datetime, complete, units = 'days') |> as.numeric()]
d[age_found_complete < 1] |> nrow() / nrow(d) # 136 found until day after complete
d[age_found_complete < 5] |> nrow() / nrow(d) # 166 found within 5 days after complete

d[, .(initiation, initial_clutch_size, clutch_size, complete, found_datetime, age_found, age_found_complete)]

