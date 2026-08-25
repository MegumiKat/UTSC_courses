# Visit https://open.toronto.ca/ and download the Apartment Building Evaluation data.

setwd("/Users/mark/Desktop/course/staa57")

ABE <- read.csv("Apartment Building Evaluation.csv")


library(tidyverse)

##################
#codes from week-3
##################

ggplot(ABE, aes(x=CONFIRMED_UNITS,y=SCORE))      +   geom_point()

set.seed(57)
ABE2 = ABE %>% slice_sample(n=300)

ggplot(ABE2, aes(x=CONFIRMED_UNITS,y=SCORE,color=PROPERTY_TYPE)) + geom_point()


ggplot(ABE2, aes(x=CONFIRMED_UNITS,y=SCORE,shape=PROPERTY_TYPE)) + geom_point()

ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point()

ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")



ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")+
  theme(legend.position = "bottom")



ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")+
  theme(legend.position = c(0.8,0.2))+
  labs(shape="Property type", color="Property type")


ggplot(ABE2, aes(x=SCORE)) + geom_histogram()

ggplot(ABE2, aes(x=SCORE)) + geom_histogram(bins=10)

ggplot(ABE2, aes(y=SCORE)) + geom_boxplot()






##############################################################################
# These following codes are taken from r-statistics.co by Selva Pravakaran
# http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html
##############################################################################

data(mpg, package="ggplot2")

# ref: https://ggplot2.tidyverse.org/reference/mpg.html




################################################
#example 1 (Scatter plots with regression line)
################################################
g <- ggplot(mpg, aes(cty, hwy))

g + geom_point() + 
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Scatterplot with overlapping points", 
       caption="Source: midwest")


g + geom_point() + geom_smooth(method="lm", se=T) +
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Scatterplot with overlapping points", 
       caption="Source: midwest")




#############################
#example 2 (jitter vs count)
#############################
g <- ggplot(mpg, aes(cty, hwy))
g + geom_jitter(width = .5, size=1) +
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Jittered Points")


# Ref: https://ggplot2.tidyverse.org/reference/geom_jitter.html



g <- ggplot(mpg, aes(cty, hwy))
g + geom_count(col="red", show.legend=F) + #use alpha
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Counts Plot")



g <- ggplot(mpg, aes(cty, hwy,col=manufacturer))
g + geom_count(show.legend=T) + #use alpha
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Counts Plot")


# Ref : https://ggplot2.tidyverse.org/reference/geom_count.html




###########################################
#example 3 (marginal plots on the margins)
###########################################
library(ggplot2)
library(ggExtra)  # needed for ggMarginal()

g <- ggplot(mpg, aes(cty, hwy)) + 
  geom_count(col="tomato3",alpha=0.5,show.legend = F) + 
  geom_smooth(method="lm", se=F)

g


my_plot = ggMarginal(g, type = "histogram", fill="transparent")

my_plot

?ggMarginal   # help file




# saving any plot to use in other reports
ggsave(my_plot, file="marginal_plot_2.png", width=20, height=10, units = "cm")


getwd()   # to locate where the file was saved




###########
#example 4 
###########
my_plot = ggplot(mpg, aes(cty)) + 
              geom_density(aes(fill=factor(cyl)), alpha=0.5) + 
       labs(title="Density plot", 
       subtitle="City Mileage Grouped by Number of cylinders",
       caption="Source: mpg",
       x="City Mileage",
       fill="# Cylinders")

my_plot
?ggplot()
ggsave(my_plot,file="my_1st_plot.png")

getwd()






#########################################################
#example 5 ( face_wrap [a group_by equivalent of graph])
#########################################################

# producing scatter plot of cty and hwy for different values
# of cyl.

g <- ggplot(mpg, aes(cty, hwy,col=manufacturer))
g + geom_count(show.legend=F) + #use alpha
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Counts Plot")+
  facet_wrap(~cyl,ncol=4)



g + geom_count(show.legend=F) + #use alpha
  labs(subtitle="mpg: city vs highway mileage", 
       y="hwy", 
       x="cty", 
       title="Counts Plot")+
  facet_wrap(~cyl+drv)

  




################
# grid.arrange
################  

#ref: https://cran.r-project.org/web/packages/egg/vignettes/Ecosystem.html






###########
#example 6
###########

library(gapminder)
data(gapminder)
view(gapminder)


library(gganimate)
library(png)
library(gifski)

g <- ggplot(gapminder, aes(gdpPercap, lifeExp, size = pop,col=continent)) +
  geom_point() +
  transition_states(year)+
  labs(title = "Year: {closest_state}")

g


anim_save("first_anim.gif", animation = g)


# Helpful resources:

# https://cran.r-project.org/web/packages/egg/vignettes/Ecosystem.html
  
# http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html

# https://www.littlemissdata.com/blog/maps






################################################
# Extra: measuring the execution time of a code
################################################

library(tictoc)

tic()
solve(matrix(c(2,3,4,5),ncol=2))
Sys.sleep(1)
toc()

# https://www.r-bloggers.com/2017/05/5-ways-to-measure-running-time-of-r-code/