################################
####  Introduction  to R  ######
################################


# If you are using R, try copying and pasting these lines one at a time to your console and then press enter
# If you are using R-studio, put the cursor in any line and press CTL+ENTER or highlight the line (or multiple lines)
# and click the Run button(on the top-right of this pan)

# R doesn't read or execute any line that starts with "#".



#######################
#R as simple calculator
#######################

#Division, multiplication, addition, subtraction
6/2
6*2
6+2
6-2

#Natural log
log(12)

#Base 10 log
log10(100)

#exponentiate
exp(log(12))

#exponent
4^2
4**2

9^(3+4)

#quotient
7%/%2

#remainder
7%%2




######################
# Creating scalar
######################

# Creating a scalar called "a" and assigning a value of 2
a=2

# Creating a scalar called "b" and assigning a value of 3
b=3

# Adding "a" and "b" and saving under "d"
d=a+b

# Printing the vaue of "d"
d

# Updating the value of a scalar
# Adds 5 to the old value of "a" and saves it again under the name "a".
# Old value=2, New value = 7
a=a+5 
a


# Computation using scalar objects

(a-b)^3 + log(d)






#############################################
#### Logic check and basic if statement #####
#############################################

x=4   # assigning 4 to x


x<5   # checks if x is less than 5 or not
x>5   # checks if x is greater than 5 or not
x<=5  # less or equal
x>=5  # greater or equal


x==4   #( == stands for euqal)
x!=4   #( != stands for not equal)




# basic if structure

# if(condition to check){things to do if the condition is true}


x=3
if(x==3){print("x is 3")}

x=4
if(x==3){print("x is 3")}   # this will print nothing





# if(condition A){
#
# things to do if condition A is true
#
# }elseif(condition B){
#
# things to do if condition A is false and condition B is true
#
# }else{ 
#
# things to do if both conditions are false
#
# }
x        # current value of x

if(x==3){
  
  print("x is 3")
  
}else if(x>3){
  
  print("x is greater than 3")
  
}else{
  print("x is less than 3")
}



####################
# for loops in R ###
####################

# basic structure of a for-loop in R
# for (a counter keeping track of the iterations) { some task that we want to repeat }

# Example: 
# for (counter in starting value:end value){
#    things we want to do repeatedly
# }


#The following loop will execute the lines between the curly brackets 10 times, 
#the counter will start at 1, after the first iteration the counter becomes 2, then 3 then 4....Finally 10

for (i in 1:10){
  print("Hello")
}

# Printing the counter (also called index)
for (i in 1:10){
  print(i)
}

# Example of the use of if statement within a for-loop
# Printing the even numbers only
for (i in 1:10){
  if(i%%2==0){print(i)}
}



####################
# while loop     ###
####################

# Printing 1 to 10 using while loop

k=1           # setting an initial value              
while(k<=10){
  print(k)
  k=k+1       # increasing the counter by 1 in each iteration
}






####################
# A simple example #
####################

# 1+2+3+4+...+100 = ?   Calculate the value using a for loop


s=0                   # the initial value of the sum =0 
for (i in 1:100){     # a loop where the index/counter will go from 1 to 100 sequentially
  s=s+i               # updating the sum in every iteration
}
print(s)              # finally printing the sum







#############
#Home work (try to solve these questions using loop and if statements)
#############

#a) 1*2*3*4*.....*100 = ?
#b) 1-2+3-4+5-....-100 =?
#c) 110+120+130+...+500 = ?
#d) 1^2+2^3+3^2+4^3+...+100^3 = ?
#e) Find the maximum value of N for which 1+2+3+...+N < 4000