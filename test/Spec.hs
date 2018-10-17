{-# OPTIONS_GHC -fplugin=MonoidComprehensions #-}
{-# LANGUAGE MonadComprehensions #-}

import Data.Foldable
import Data.Monoid
import Test.HUnit

-- TODO: Write comprehensive test suite
main :: IO Counts
main = runTestTT $ test
  [ "Sum"
    ~:  sum [x*y | x <- [1..3], y <- [1..3::Int]]
    ~=? getSum ([Sum (x*y) | x <- [1..3], y <- [1..3::Int]])
  ]
