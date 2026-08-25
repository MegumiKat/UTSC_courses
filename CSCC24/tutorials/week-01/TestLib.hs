-- This file is just my unit-testing library.

{-# language BlockArguments #-}
{-# language DeriveDataTypeable #-}
{-# language ScopedTypeVariables #-}

module TestLib(
    Test(..),
    (~:),
    Cond(..),
    checkCond,
    Rel(..),
    checkRel,
    checkEq,
    (~?=),
    (~=?),
    (~&&),
    (~||),
    testlibMain
    ) where

import Control.Exception (Exception, SomeException, evaluate, throwIO, try)
import Control.Monad (unless)
import Data.List
import Data.Typeable (Typeable, cast)
import GHC.Stack (HasCallStack)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import Text.Read (readMaybe)

-- | The in-house exception type when a test case fails.
data CheckException = CheckFailed String deriving Typeable
instance Exception CheckException
instance Show CheckException where
    show (CheckFailed msg) = msg

data Test = ToRun (IO ())
          | Named String Test
          | And Test Test

(~:) :: HasCallStack => String -> Test -> Test
(~:) = Named
infix 4 ~:

runTestForMachine (ToRun p) = p
runTestForMachine (Named name t) = runTestForMachine t
runTestForMachine (And t1 t2) = do
    runTestForMachine t1
    runTestForMachine t2

-- | A record type packing up a predicate and its name.
data Cond a = MkCond{cond :: a -> Bool, condName :: String}

-- | Test with a predicate.
checkCond :: (HasCallStack, Show a)
          => Cond a     -- ^ predicate
          -> a          -- ^ testee value
          -> Test
checkCond MkCond{cond=p, condName=name} x = ToRun do
    b <- evaluate (p x)
    unless b (throwIO (CheckFailed msg))
  where
    msg = "Predicate \"" ++ name ++ "\" fails.\nProblematic value: "
          ++
          show x

-- | A record type packing up both a relation and its name.  Note that the
-- testers in this library work best when the relation is symmetric.
data Rel a = MkRel{rel :: a -> a -> Bool, relName :: String}

-- | The @==@ relation.
eq :: Eq a => Rel a
eq = MkRel{rel = (==), relName = "=="}

-- | Test with a relation against an expected value.
checkRel :: (HasCallStack, Show a)
         => Rel a  -- ^ relation
         -> a      -- ^ received value
         -> a      -- ^ expected value
         -> Test
checkRel MkRel{rel=r, relName=name} received expected = ToRun do
    b <- evaluate (r received expected)
    unless b (throwIO (CheckFailed msg))
  where
    msg = "Relation \"" ++ name ++ "\" fails:\n"
          ++
          "expected: " ++ show expected ++ "\n"
          ++
          "received: " ++ show received

-- | Equality test. 2nd argument is the expected answer.
checkEq :: (HasCallStack, Eq a, Show a) => a -> a -> Test
checkEq = checkRel eq

-- | Equality test. 2nd argument is the expected answer.
(~?=) :: (HasCallStack, Eq a, Show a) => a -> a -> Test
(~?=) = checkEq
infix 5 ~?=

-- | Equality test. 1st argument is the expected answer.
(~=?) :: (HasCallStack, Eq a, Show a) => a -> a -> Test
(~=?) = flip checkEq
infix 5 ~=?

-- | Require passing both tests. Stop upon 1st failure.
(~&&) :: HasCallStack => Test -> Test -> Test
(~&&) = And
infixr 3 ~&&

-- | Require passing one of two tests. Stop upon 1st success.
(~||) :: HasCallStack => Test -> Test -> Test
pa ~|| pb = ToRun do
    e <- try (runTestForMachine pa)
    case e of
      Right _ -> return ()
      Left (_ :: SomeException) -> runTestForMachine pb
infixr 2 ~||

runTestForHuman :: Test -> IO Bool
runTestForHuman (And t1 t2) = (&&) <$> runTestForHuman t1 <*> runTestForHuman t2
runTestForHuman t = do
    case t of
      Named name _ -> putStr ("Test \"" ++ name ++ "\": ")
      ToRun _ -> putStr ("Unnamed test: ")
    e <- try (runTestForMachine t)
    case e of
      Left (exc :: SomeException) -> do
          print exc
          putStrLn ""
          return False
      Right _ -> do
          putStrLn "passed"
          putStrLn ""
          return True

-- | Use this for main.
testlibMain :: [Test] -> IO ()
testlibMain tests = do
    arg <- fmap (parseArgs (length tests)) getArgs
    case arg of
      Arg Human Nothing -> mapM_ runTestForHuman tests
      Arg Human (Just i) -> do
          b <- runTestForHuman (tests !! i)
          unless b exitFailure
      Arg Machine (Just i) -> runTestForMachine (tests !! i)
      ArgError -> error "No valid test number."

data Args = Arg Mode (Maybe Int) | ArgError
data Mode = Human | Machine

parseArgs n args = go (Arg Human Nothing) args
  where
    go a [] = a
    go a@(Arg mode intMay) (x : xs)
      | x == "-q" = go (Arg Machine intMay) xs
      | Just i <- readMaybe x, 0 <= i, i < n = go (Arg mode (Just i)) xs
      | otherwise = ArgError
