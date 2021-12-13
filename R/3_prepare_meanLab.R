
# PACKAGES 
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 
          'foreach', 'colorspace', 'dplyr'),
          require, character.only = TRUE)

# COLLECT raw DATA 
  d = fread( here('//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA/RGB.csv') )

# PERFORM calibration

  # some values have R+G+B = 0 making calibration unfeasible (RGB/0=impossible)
  d = d[R!=0 | G!=0 | B!=0]
  
  #split the dataset in roi, grey and white
  wh<-d[mark=="standard_white"]
  roi<-d[mark!="standard_grey" & mark!="standard_white"]
  
  #calibrate RGBs in standard_white and merge the two datasets
  cal_patch <- wh %>% 
    group_by(path) %>%
    mutate(R=mean(R/((R+G+B)/3)), 
           G=mean(G/((R+G+B)/3)), 
           B=mean(B/((R+G+B)/3))) %>%
    filter (! duplicated(path)) %>% #keep one row for each picture
    select(-"mark") #keep relevant columns only 
  
  #perform calibration [(RGBroi/RGBgrey)/RGBwhite]
  d <- roi %>%
    left_join(cal_patch, by = c("path", "parts", "id"), suffix = c("", "_white")) %>%
    mutate(R=(R/R_white), G=(G/G_white), B=(B/ B_white)) %>%
    select(c("parts", "mark", "id", "path", "R", "G", "B")) #keep relevant columns only
  
  #check d
  head(d)
  summary(d)
  
  # check how many values above 255
  d[R > 255, .N] # 5297887
  d[G > 255, .N]
  d[B > 255, .N]
 
  # exclude above 255
  d = d[R <= 255]
  
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

  


