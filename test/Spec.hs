{-# OPTIONS_GHC -fplugin=MonoidComprehensions #-}
{-# LANGUAGE MonadComprehensions #-}

import Control.Exception
import Data.Foldable
import Data.Monoid

-- TODO: Write comprehensive test suite
main :: IO ()
main = assert (sumListComp == sumMonoidComp) $ putStrLn "\nAll Good!"

sumListComp, sumMonoidComp :: Int
sumListComp = sum [ x * y | x <- [1..3], y <- [1..3] ]
sumMonoidComp = getSum ([ Sum (x * y) | x <- [1..3], y <- [1..3] ])
