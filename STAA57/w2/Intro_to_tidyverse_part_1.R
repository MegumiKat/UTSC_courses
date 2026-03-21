# Visit https://open.toronto.ca/ and download the "Apartment Building Evaluation" data.

###################
# Reading dataset
###################

ABE <- read.csv("/Users/mark/Desktop/course/staa57/Apartment Building Evaluation.csv")

#dimensions of the dataset
dim(ABE)

# Install tidyverse
install.packages("tidyverse")
# loading the required library
library(tidyverse)


# a summary of the dataset
glimpse(ABE)


#view dataset
view(ABE)


# Some old school codes
names(ABE)
summary(ABE)

ABE$CONFIRMED_UNITS




################
# piping example
################
sum(ABE$CONFIRMED_UNITS   [  ABE$WARD==14  ] )

x = count(ABE$CONFIRMED_UNITS   [  ABE$WARD==14  ])
x
mean( ABE$CONFIRMED_UNITS   [  ABE$WARD==14  ]   )




#alternative coding (easier to read)
ABE %>% filter(WARD==14)  %>% summarise( avg = mean(CONFIRMED_UNITS))



ABE %>% filter(WARD==14)  %>% summarise( avg = mean(CONFIRMED_UNITS),
                                         avg_score= mean(SCORE))


################################
# Filtering data(selecting rows)
################################

ABE=ABE %>% filter(WARD==14)


ABE=ABE %>% filter(WARD %in% c(13,14))


ABE=ABE %>% filter(WARD %in% c(13,14) & YEAR_BUILT>1990)


ABE=ABE %>% filter(WARD & YEAR_BUILT)
View(ABE)
#not in



##########
#sorting
##########
ABE= ABE %>% arrange(WARD)

ABE= ABE %>% arrange(WARD,YEAR_EVALUATED)

ABE = ABE %>% arrange(desc(WARD))




######################
#Selecting variables (columns)
######################
ABE3= ABE %>% select(WARD, YEAR_BUILT, CONFIRMED_UNITS,)

ABE3 =ABE %>% select(starts_with("WARD"))

ABE3 =ABE %>% select(!starts_with("WARD"))

ABE3 =ABE %>% select(ends_with("SCORE"))

ABE3 =ABE %>% select(contains("YEAR"))

ABE3 =ABE %>% select(!where(is.numeric))

ABE3 =ABE %>% select(starts_with("WARD") & where(is.numeric))




#######################
# Summary by Group
#######################


ABE %>% group_by(WARDNAME) %>% summarise(N=n(),AVG=mean(CONFIRMED_UNITS)) 

ABE %>% group_by(WARDNAME) %>% summarise(N=n(),AVG=sum(CONFIRMED_UNITS)/n())

ABE4=ABE %>% group_by(WARDNAME) %>% summarise(N=n(),AVG=mean(CONFIRMED_UNITS)) 
class(ABE4)

ABE5 = ABE %>% 
  group_by(WARDNAME) %>% 
  summarise(N=n(),AVG=mean(CONFIRMED_UNITS)) %>% 
  as.data.frame()

class(ABE5)

print(ABE4)

print(ABE5)



#######################
# Renaming variable
#######################

# rename(new name = old name)

ABE2= ABE %>% rename(WARD_NUM = WARD)

ABE2 = ABE %>% rename_with(tolower)

ABE2 = ABE %>% rename_with(toupper)
