
# PACKAGES 
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 
          'foreach', 'colorspace'),
          require, character.only = TRUE)

# COLLECT raw DATA 
  d = fread( here('//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA/RGB.csv') )

# PERFORM calibration

  # some values have R+G+B = 0 making calibration unfeasible (RGB/0=impossible)
  d = subset(d, d$R!=0 | d$G!=0 | d$B!=0)
  
  # create unique ID to associate body part+grey+white
  d$uniqueid = paste(d$parts, d$path, d$id, sep="_")
  
  #split the dataset in roi, grey and white
  gr<-df[mark=="standard_grey"]
  wh<-df[mark=="standard_white"]
  roi<-df[mark!="standard_grey" & mark!="standard_white"]
  
  #calibrate RGBs in standard_grey
  gr <- gr %>% 
    group_by(path) %>%
    mutate(R=mean(R/((R+G+B)/3)), 
           G=mean(G/((R+G+B)/3)), 
           B=mean(B/((R+G+B)/3))) %>%
    filter (! duplicated(path)) %>% #keep one row for each pic
    select(-"mark")
  
  #calibrate RGBs in standard_white and merge the two datasets
  cal_patch <- wh %>% 
    group_by(path) %>%
    mutate(R=mean(R/((R+G+B)/3)), 
           G=mean(G/((R+G+B)/3)), 
           B=mean(B/((R+G+B)/3))) %>%
    filter (! duplicated(path)) %>%
    select(-"mark") %>%
    left_join(gr, by = c("path", "parts", "id"), suffix = c("_white", "_grey"))
  
  #perform calibration [(RGBroi/RGBgrey)/RGBwhite]
  d <- roi %>%
    left_join(cal_patch, by = c("path", "parts", "id")) %>%
    mutate(R=(R/R_grey)/R_white, G=(G/G_grey)/G_white, B=(B/B_grey)/ B_white) %>%
    select(c("parts", "mark", "id", "path", "R", "G", "B")) #keep relevant columns only
  
  #check d
  head(d)
  summary(d)
  
  # check how many values above 255
  d[R > 255, .N]
  d[G > 255, .N]
  d[B > 255, .N]
  # nothing to exclude
  
  # make sure it's a table
  d = as.data.table(d)

# PREPARE means LAB and hex
  m = d[, .(R = mean(R,na.rm = TRUE), G = mean(G,na.rm = TRUE), B = mean(B,na.rm = TRUE)), 
        by = .(parts, mark, path)]
  m[, id := .I] 
  m = na.omit(m) # This should not be! malformed ROI-s ?
 
  m[, col := rgb(R,G,B, max=255), by = id]
  x = data.table(m[, as( hex2RGB(col), "LAB") ]@coords )
  setnames(x, c('L', 'a', 'b'))
  m = cbind(m, x)

# EXPORT
  fwrite(m, here('//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA/Lab_means.csv') )

  


