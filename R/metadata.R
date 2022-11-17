#========================================================================================================================
# Extract field data for colouration analysis
#========================================================================================================================

sapply( c('data.table', 'sdb','foreach', 'wadeR', 'sdbvis', 'magrittr'),
        require, character.only = TRUE)


# connection
con = dbcon('jkrietsch', db = 'REPHatBARROW')  

#------------------------------------------------------------------------------------------------------------------------
### CAPTURES
dc = dbq(con, 'select * FROM CAPTURES')

d = dc[, .(year_, author, ID, UL, UR, LL, LR, sex_observed, lat, lon, caught_time, tarsus, culmen, total_head, wing, 
           weight, bp, carries_egg, cloaca, haema, cam_id, head_t, head_l, wing_l, front, tail, tail_red, comments)]

d = d[year_ > 2016]


write.table(d, './DATA/CAPTURES', quote = TRUE, sep = '\t', row.names = FALSE)

dcr = read.table('./DATA/CAPTURES', sep = '\t', header = TRUE) %>% data.table

#------------------------------------------------------------------------------------------------------------------------
### NESTS
dn = dbq(con, 'select * FROM NESTS')

d = dn[, .(year_, nest, male_id, female_id, initiation, est_hatching_datetime, hatching_datetime, nest_state, comments)]

d = d[year_ > 2016]

write.table(d, './DATA/NESTS', quote = TRUE, sep = '\t', row.names = FALSE)

#------------------------------------------------------------------------------------------------------------------------
### TESTO
dt = dbq(con, 'select * FROM TESTO')

# no data so far
d = dt[, .(year_, ID, date_, GnRH, volume, T)]

write.table(d, './DATA/TESTO', quote = TRUE, sep = '\t', row.names = FALSE)

#------------------------------------------------------------------------------------------------------------------------










