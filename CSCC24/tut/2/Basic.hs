module Basic where
import Control.Arrow (ArrowChoice(left, right))

{-
Split a list into two, more or less equal length.  Linear time.

Since lists are sequential, we want to "uninterleave", e.g.,

split [3,1,2,9] = ([3,2], [1,9])
split [3,1,2,9,7] = ([3,2,7], [1,9])
split [3] = ([3], [])

You may like to know: the tuple syntax "(foo, bar)" can be used in pattern
matching.

The given template guides thinking about base cases and recursive cases (and
shows "yes you can do that"), but you can change it to your liking after you
understand.

If you can't solve some parts, please leave them as error "TODO" so the whole
file still compiles and I can still test other questions.
-}
split :: [a] -> ([a], [a])
split [] = ([], [])
split [x] = ([x], [])
split (x1 : x2 : xt) = let (firstList, secondList) = split xt in (x1:firstList, x2:secondList)


{-
Take two lists of integers.  Precondition: Each is already sorted
(non-decreasing).  Merge them in non-decreasing order.  Linear time.

Example:
merge [2, 3, 5] [1, 3, 4, 4, 7, 7] = [1, 2, 3, 3, 4, 4, 5, 7, 7]

The given template guides thinking about base cases and recursive cases, but
you can change it to your liking after you understand.

If you can't solve some parts, please leave them as error "TODO" so the whole
file still compiles and I can still test other questions.
-}
merge :: [Integer] -> [Integer] -> [Integer]
merge [] ys = ys
merge xs [] = xs
merge (x : xt) (y : yt)
  | x <= y    = x : merge xt (y:yt)
  | otherwise = y : merge (x:xt) yt


{-
It may occur to you that split and merge above are the two main ingredients of
merge sort. Let's do it in Haskell! Also a small exercise in writing a
higher-order function for the purpose of dependency injection.

1st argument (splitter) is a function for splitting, like split above.
2nd argument (merger) is a function for merging, like merge above.
3rd argument (xs) is the list to be sorted.

Brief idea of merge sort: It's a divide-and-conquer approach.
1. Use splitter to split the input into roughly two halves.
2. Use recursion to sort each of the two halves. (Except for a base case.)
3. Use merger to merge them.

The sample tests use your version of split and merge from above. During
automarking, my correct version will be used, so you can still get marks in this
question in case you can't solve split or merge.

The given template guides thinking about base cases and recursive cases, but
you can change it to your liking after you understand.

If you can't solve some parts, please leave them as error "TODO" so the whole
file still compiles and I can still test other questions.
-}
mergeSort :: ([Integer] -> ([Integer], [Integer]))
          -> ([Integer] -> [Integer] -> [Integer])
          -> [Integer] -> [Integer]
mergeSort splitter merger xs = case splitter xs of
  (ys, []) -> ys
  (ys, zs) -> merger (mergeSort splitter merger ys) (mergeSort splitter merger zs)


{-
A binary tree storing integers. Implement inorder below to output a list
consisting of the integers in the input tree in in-order order. The sample test
clarifies the order.

The standard library has ++ for concatenating two lists.

This time no template is provided. Go ahead modify the code to add your own
pattern matching.
-}

data ITree = IEmpty | INode ITree Integer ITree
    deriving Show

inorder :: ITree -> [Integer]
inorder IEmpty = []
inorder (INode left value right) = inorder left ++ [value] ++ inorder right
