main :: IO()
main = putStrLn "Hello, Haskell!"
diff, diffSqV3b :: Integer -> Integer -> Integer
diff x y =
    let minus = x - y
        plus = x + y
    in minus * plus

diffSqV3b x y = minus * plus
  where
    minus = x - y
    plus = x + y 
