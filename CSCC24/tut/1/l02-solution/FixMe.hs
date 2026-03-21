module FixMe where

{-
powmod m b e computes b^e mod m (b to the power e, then mod m). We assume these
preconditions:
* e >= 0
* m >= 2

Algorithm explanation: Strong induction on e:

e is even or odd, i.e., let
  q = e div 2
  r = e mod 2
then e = 2q+r, and r is 0 or 1.

In Haskell this can be done with one single "(q, r) = divMod e 2" so the bugs
are elsewhere!

* If e is even:

    b^(2q) = (b^q) * (b^q)

  so use recursion to get b^q (y in the code), then multiply it by itself.

* If e is odd:

    b^(2q+1) = b^(2q) * b = (b^q) * (b^q) * b

  so use recursion to get b^q (y in the code), then multiply by itself and an
  extra b.

* We also need a base case: b^0 = 1.

It would be stupid to exponentiate before doing mod m because big numbers mean
slow. Instead, every time I said "multiply" above, do mod m right away to keep
numbers small and fast; likewise y is b^q mod m.

My code below contains syntax errors, typos, and bugs.  Fix my code!  But please
don't fix what's right.
-}

powmod :: Integer -> Integer -> Integer -> Integer -- :: instead of :
powmod m b e
  | e == 0 = 1         -- test for base case first; also the correct answer is 1
  | r == 0 = y2        -- also equality comparison is ==
  | r == 1 = mod (y2 * b) m    -- y2 rather than y
  where
    (q, r) = divMod e 2
    y = powmod m b q          -- parameter order!
    y2 = mod (y * y) m

