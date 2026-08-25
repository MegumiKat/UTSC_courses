-- module HaskellEval where

-- doITerminate = take 2 (from 0)
--   where
--     from i = i : from (i + 1)

-- doIEvenMakeSense = take 2 zs
--   where
--     zs = 0 : zs
--     -- At low level this is one node pointing back to itself. O(1)-space.

-- s :: String -> (String, String)
-- s "" = ("", "")  -- 处理空字符串的情况
-- s s = 
--     let (first, rest) = break (== ':') s 
--         in case rest of 
--             "" -> (first, "")
--             _:xs -> (first, xs)


-- splitOnce :: String -> (String, String)
-- splitOnce "" = ("", "")  -- 处理空字符串的情况
-- splitOnce (':':xs) = ("", xs)  -- 处理字符串以冒号开头的情况
-- splitOnce xs = go xs ""  -- 对于一般情况，使用一个辅助函数进行递归处理
--   where
--     go "" acc = (acc, "")  -- 当递归到字符串结尾时，返回累积的结果和空字符串
--     go (':':ys) acc = (acc, ys)  -- 当遇到第一个冒号时，返回累积的结果和冒号后的部分
--     go (y:ys) acc = go ys (acc ++ [y])  -- 继续处理剩余的字符串，将当前字符添加到累积结果中

-- split :: String -> [String]
-- split "" = []
-- split str = case splitOnce str of
--     (first, "") -> [first]
--     (first, rest) -> first : split rest

-- glue :: [String] -> String
-- glue [] = ""
-- glue [x] = x
-- glue (x : xs) = x ++ ":" ++ glue xs


-- tL1: N / O /
-- tR1: N / I /

-- tL2 = N (N / O /) O (N / I /)
-- tR2 = N (N / O /) I (N / I /)
-- tL3 = N ((N / O /) O (N / I /)) O 


-- [a, a+b, a+b+c]
-- [a, a+b, a+b+c]


-- Base case: f a [] = a : h a [] = [a]
--            g a [] = a : [] = [a]
--            base case hold

-- IH: 


-- hd (f 0 (s 1))
-- = hd (f 0 (s 1))
-- = hd (0 : h 0 (s 1))
-- = 0

-- hd (g 0 (s 1))
-- = hd (g 0 (1 : s(1+1)))
-- = hd (0 : g (0+1) s (1+1))
-- = 0

-- fps0 = \
-- gps0 = \

-- fps1 = f 1 \ = 1 : h 1 [] = [1]
-- gps1 = g 1 \ = [1]

-- fps2 = f 1 [1] = 1 : h 1 [1] = 1 : f 2 [] = 1 : 2 :[]
-- gps2 = g 1 [1] = 1 : g 2 [] = 1 : 2 : []


-- foldr op [] "a, b, c"
-- = 


--  lookup _ [] = Nothing
--         lookup x ((k,v) : kvs) | x == k = Just v
--                                | otherwise = lookup x kvs
--         lookup x = foldr op z  where
--             z = Nothing
--             op (k,v) acc = if x == k then Just v else acc


splitOnce :: String -> (String, String)
splitOnce "" = ("", "")
splitOnce xs = go xs ""
    where
        go "" acc = (acc, "")
        go (':':ys) acc = (acc, ys)
        go (y:ys) acc = go ys (acc ++ [y])

split :: String -> [String]
split "" = []
split xs = first : split rest where (first, rest) = splitOnce xs 