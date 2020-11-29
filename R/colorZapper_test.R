#========================================================================================================================
# Test colorZapper with REPH data
#========================================================================================================================

# Packages
sapply( c('data.table', 'magrittr', 'colorZapper'),
        require, character.only = TRUE)

dir = './DATA/example_files/head_t/'


# open/create a colorZapper file
cz_file = tempfile(fileext = '.sqlite')
CZopen(path = cz_file)
# associate files with the opened file
CZaddFiles(dir)

#define ROIs  
CZdefine(polygons = 1, marks = c('bill', 'crown', 'standard_grey', 'standard_white'))

#extract RGB values from the ROI 
CZextractROI()

# fetch the extracted data from the SQLITE file 
fetched_data = CZdata(what = 'ROI')  

# check status
CZshowStatus()

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


#------------------------------------------------------------------------------------------------------------------------
# Working example from the package
#------------------------------------------------------------------------------------------------------------------------

require(colorZapper)
# path to image directory
dir = system.file(package = "colorZapper", "sample")
# open/create a colorZapper file
cz_file = tempfile(fileext = '.sqlite')
CZopen(path = cz_file)
# associate files with the opened file
CZaddFiles(dir)


# define 1 point per image
CZdefine(points = 1)

# check status
CZshowStatus()

# over-write points defined for Falco_peregrinus (id = 2)
CZdefine(points = 1, what  = 2)
CZshowStatus()
# define points using marks
# 2 points per mark = 4 points per image
# 'what' is set so only particular images are going to be loaded
CZdefine(points = 1, marks = c("wing", "tail") , what = 4)
CZshowStatus()

#define polygons: 1 polygon per mark
# see help(locator) for info on how to draw on an R graphic. 
CZdefine(polygons = 1, marks = c("wing", "tail"), what = 3 )
