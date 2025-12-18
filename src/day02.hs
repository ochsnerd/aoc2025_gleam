#!/usr/bin/env nix-shell
#!nix-shell --pure -i runghc -p "haskellPackages.ghcWithPackages (pkgs: [ pkgs.split ])"

import Data.List (unfoldr, nub)
import Data.List.Split (splitOn)

main :: IO ()
main = interact solve

solve :: String -> String
solve = show . sum . invalidIdsPart2 . parse

parse :: String -> [Int]
parse = map read . splitOn "-"

invalidIdsPart2 :: [Int] -> [Int]
invalidIdsPart2 [start, stop] = nub $ concatMap (\repeats -> invalidIds repeats start stop) [2..digitsStop]
  where
    digitsStop = length (digits stop)

invalidIds :: Int -> Int -> Int -> [Int]
invalidIds repeats start stop = dropWhile (< start) $ takeWhile (<= stop) $ unfoldr (Just . nextInvalidId repeats)  1

nextInvalidId :: Int -> Int -> (Int, Int)
nextInvalidId repeats chunk = (makeId repeats chunk, chunk + 1)

makeId :: Int -> Int -> Int
makeId repeats = undigits . concat . replicate repeats . digits

digits :: Int -> [Int]
digits = reverse . unfoldr step
  where
    step 0 = Nothing
    step x = Just (x `mod` 10, x `div` 10)

undigits :: [Int] -> Int
undigits = foldl (\acc d -> acc * 10 + d) 0
