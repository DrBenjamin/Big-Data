# Week 3 - Dummy coding
# A demonstration of dummy coding for a regression model. We create a (completely meaningless!) dataset, fruit_df
fruit_df <- data.frame(y = runif(12),
                       fruit = rep(c('apple', 'banana', 'orange')))

# We can create dummy variables manually like this (NB: this is not a recommended approach - what if you had 20 categories… or 100… or…?)
fruit_df <- mutate(fruit_df,
                   apple = ifelse(fruit == 'apple', 1, 0),
                   banana = ifelse(fruit == 'banana', 1, 0),
                   orange = ifelse(fruit == 'orange', 1, 0))

# We can model our “response”, y, as a function of our categorical variable… (Remember from the video, 1 is the intercept, included mostly for clarity.)
# Using the original `fruit` variable
lm1 <- lm(y ~ 1 + fruit, fruit_df)

# Using our dummy coded variables - note that we have chosen to omit `apple`
lm2 <- lm(y ~ 1 + banana + orange, fruit_df)
# and see that both models give the same coefficients

# Model coefficients
# for `fruit`
coef(lm1)
# (Intercept) fruitbanana fruitorange
# 0.5388288   0.3556774  -0.1740031
# for dummies
coef(lm2)
# (Intercept)      banana      orange
# 0.5388288   0.3556774  -0.1740031
# identical 🙌

# How do we interpret these numbers?
# Well, more about that later, but start by consider the averages for each fruit…
summarize(fruit_df, mean(y), .by = fruit)
# fruit   mean(y)
# 1  apple 0.5388288
# 2 banana 0.8945062
# 3 orange 0.3648256

# then see if you can reconcile these means, with the coeficients from the model…
coef(lm1)
# (Intercept) fruitbanana fruitorange
# 0.5388288   0.3556774  -0.1740031