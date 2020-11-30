#=======================================================================================================
# Test colorZapper with REPH data
#=========================================================================================================

# NOTES:
    # this script should run in plain R not in Rstudio
    # the working directory should be set with setwd("your_local_path/REPH_coloration")  
    # ⚠ CZdefine can be interrupted and resumed any time. The data is saved after each image. 

# Packages
    sapply( c('colorZapper', 'here'), require, character.only = TRUE)


### STEP 1

# Setup: only run once!
    cz_file = '~/Desktop/REPH.sqlite' 
    CZopen(path = cz_file) 

### STEP 2

# Process front
    CZaddFiles('DATA/example_files/head_t') # run once  

    # interactively define ROI-s: 
    # for standard_white and standard_grey one triangle is enough
    CZdefine(polygons = 1, marks = c('head_top','bill', 'standard_white', 'standard_grey') )


# Process head_l
    CZaddFiles('DATA/example_files/head_l') 
    CZdefine(polygons = 1, marks = c('head_left', 'standard_white', 'standard_grey') )

### STEP 3
    # extract color from the ROI-s    
    CZextractROI()

    # fetch the extracted data from the SQLITE file. 
    d = CZdata(what = 'ROI')

    # opens a pdf with photos and marks for review. 
    CZcheck()   



#define ROIs  
CZdefine(polygons = 1, marks = c('bill', 'crown', 'standard_grey', 'standard_white'))

#extract RGB values from the ROI 
CZextractROI()

# fetch the extracted data from the SQLITE file 
fetched_data = CZdata(what = 'ROI')  



#now, for each ID, each RGB value for mark=='bill' & == 'crown' needs to be converted using the RGB value with mark=='standard_grey' for that same ID  

#vectorise grey regions 
grey=subset(fetched_data, fetched_data$mark=='standard_grey') 

#vectorise bill 
bill=subset(fetched_data, fetched_data$mark=='bill') 

#vectorise crown 
crown=subset(fetched_data, fetched_data$mark=='crown') 

#colour calibration
for(i in length(fetched_data$id)) 
{ 
  bill$R=bill$R/(mean(grey$R/((grey$R+grey$G+grey$B)/3))) 
  bill$G=bill$G/(mean(grey$G/((grey$R+grey$G+grey$B)/3))) 
  bill$B=bill$B/(mean(grey$B/((grey$R+grey$G+grey$B)/3)))   

  crown$R=crown$R/(mean(grey$R/((grey$R+grey$G+grey$B)/3))) 
  crown$G=crown$G/(mean(grey$G/((grey$R+grey$G+grey$B)/3))) 
  crown$B=crown$B/(mean(grey$B/((grey$R+grey$G+grey$B)/3))) 
 
} 
  
#check outputs 
summary(bill) 
summary(crown)





#define polygons: 1 polygon per mark
# see help(locator) for info on how to draw on an R graphic. 
CZdefine(polygons = 1, marks = c("wing", "tail"), what = 3 )

