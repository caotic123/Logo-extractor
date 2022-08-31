{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

module Search where

import Data.ByteString.Lazy (ByteString)
import Data.Char (toLower)
import Data.List (find, isSubsequenceOf, isSuffixOf, sortBy)
import Debug.Trace (trace)
import ParserHtml
  ( Candidate (tagInfos, tagName),
    TagsInfo (content, lowered_content, name),
    parseHTML,
    parseUrlName,
  )
import Text.Parsec (ParseError, parse)

hotWords :: [(String, Double)]
hotWords = [("logo", 25), ("brand", 15), ("asset", 10), ("banner", 5)]

tagHotWords :: [(String, Double)]
tagHotWords = [("img", 4)]

calculateStringHeuristic :: [(String, Double)] -> String -> Double
calculateStringHeuristic vars str = go vars
  where
    go ((word, point) : xs) = if isSubsequenceOf word str then go xs + point else go xs
    go [] = 0

generateExtensionNames :: String -> [String]
generateExtensionNames name = [name ++ ".png", name ++ ".jpeg", name ++ "svg", name ++ ".jpg"]

selectCandidates :: String -> [Candidate] -> [(Double, [Candidate])]
selectCandidates serviceName = do
  go 1.0
  where
    calcContentHeuristic = calculateStringHeuristic ((serviceName, 1) : Prelude.map (,10) (generateExtensionNames serviceName) ++ hotWords)
    calcTagNameHeuristic = calculateStringHeuristic tagHotWords
    go acc (x : xs) = do
      let point_tag = calcTagNameHeuristic (tagName x)
      let points_on_tag_info = Prelude.foldr (\taginfo points -> points + calcContentHeuristic (name taginfo) + calcContentHeuristic (lowered_content taginfo)) 0 (tagInfos x)
      let total_points = point_tag + points_on_tag_info
      if total_points >= 4
        then
          (total_points + (total_points * acc), [x]) :
          go (acc + (total_points / 20)) xs
        else go (acc * 0.9) xs
    go _ [] = []

isUrl :: String -> Bool
isUrl str = do
  let suffix = flip Data.List.isSuffixOf str
  suffix ".png" || suffix ".jpeg" || suffix ".svg" || suffix ".jpg"

extractAssets :: [(Double, [Candidate])] -> [(Double, String)]
extractAssets ((i, candidate : _) : xs) = do
  let found_src = Data.List.find (isUrl . content) (tagInfos candidate)
  case found_src of
    Just x -> (i, content x) : extractAssets xs
    Nothing -> extractAssets xs
extractAssets ((_, []) : _) = undefined
extractAssets [] = []

run :: ByteString -> ByteString -> Either ParseError [(Double, String)]
run addressName x = do
  candidates <- parseHTML x
  let nameService = case parse parseUrlName "" addressName of
        Right y -> Prelude.map toLower y
        Left msg -> show msg
  let sorted = Data.List.sortBy (\(i, _) (i', _) -> compare i i') (selectCandidates nameService candidates)
  Right $ extractAssets sorted