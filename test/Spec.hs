{-# OPTIONS_GHC -fplugin=MonoidComprehensions #-}
{-# LANGUAGE MonadComprehensions #-}
{-# LANGUAGE ParallelListComp #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TransformListComp #-}

import Data.Foldable
import Data.Monoid
import GHC.Exts
import Test.HUnit

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------

-- TODO: Write a more comprehensive test suite
main :: IO Counts
main = runTestTT $ test
  [ "Sum"
    ~:  sum [x*y | x <- [1..3], y <- [1..3::Int]]
    ~=? getSum ([Sum (x*y) | x <- [1..3], y <- [1..3::Int]])
  , "ParallelListComp"
    ~:  sum [x*y | x <- [1..3] | y <- [1..3::Int]]
    ~=? getSum ([Sum (x*y) | x <- [1..3] | y <- [1..3::Int]])
  , "TranformListComp"
    ~:  [(the category, average price) | Prod{..} <- inventory,
         then group by category using groupWith]
    ~=? ([[(the category, average price)] | Prod{..} <- inventory,
          then group by category using groupWith])
  , "MonadComprehensions"
    ~:  getSum (foldMap Sum [x*y | x <- Just 2, y <- Just (3::Int)])
    ~=? getSum ([Sum (x*y) | x <- Just 2, y <- Just (3::Int)])
  ]

--------------------------------------------------------------------------------
-- Test data
--------------------------------------------------------------------------------

data Prod = Prod { name :: String, category :: ProdCategory, price :: Int }
  deriving (Eq, Ord, Show)

data ProdCategory = Produce | Pastry | Deli
  deriving (Eq, Ord, Show)

inventory :: [Prod]
inventory =
  [ Prod { name = "Apple"   , category = Produce , price = 200 }
  , Prod { name = "Strudel" , category = Pastry  , price = 150 }
  , Prod { name = "Letuce"  , category = Produce , price = 170 }
  , Prod { name = "Chicken" , category = Deli    , price = 230 }
  , Prod { name = "Donut"   , category = Pastry  , price = 120 }
  , Prod { name = "Swiss"   , category = Deli    , price = 210 }
  , Prod { name = "Ham"     , category = Deli    , price = 240 }
  , Prod { name = "Grapes"  , category = Produce , price = 120 }
  , Prod { name = "Turky"   , category = Deli    , price = 300 }
  , Prod { name = "Cake"    , category = Pastry  , price = 320 }
  , Prod { name = "Cheddar" , category = Deli    , price = 180 }
  , Prod { name = "Cookie"  , category = Pastry  , price = 100 }
  ]

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

average :: [Int] -> Int
average ns = sum ns `div` length ns
