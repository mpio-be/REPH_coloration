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

# define 1 point per image
CZdefine(points = 1)

# check status
CZshowStatus()




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