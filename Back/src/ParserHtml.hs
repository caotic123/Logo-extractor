{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module ParserHtml where

import Data.ByteString.Lazy
import Data.Char
import Data.Functor
import Data.Maybe (isJust)
import Text.Parsec
import Text.Parsec.ByteString.Lazy (Parser)

data TagsInfo = TagsInfo
  { name :: String,
    content :: String,
    lowered_content :: String
  }
  deriving (Show)

data Candidate = Candidate
  { tagName :: String,
    tagInfos :: [TagsInfo],
    isClosing :: Bool
  }
  deriving (Show)

toLowerStr :: [Char] -> [Char]
toLowerStr = Prelude.map toLower

unit :: Monad m => m ()
unit = return ()

withSpaces :: Parser a -> Parser a
withSpaces k = char_ignorable >> k >>= (\a -> char_ignorable >> return a)
  where
    char_ignorable = do
      let tryC a b = (a <|> b) <|> (b <|> a)
      tryC spaces (void (try $ many (char '\n')))

parseTagName :: Parser String
parseTagName = many $ satisfy (`Prelude.notElem` [' ', '>'])

parseAttr :: Parser TagsInfo
parseAttr = try parseWithContent <|> try parseWithoutContent
  where
    parseWithContent = do
      void space >> withSpaces unit
      name <- many1 $ satisfy (`Prelude.notElem` ['=', '>', '/', ' '])
      void $ char '='
      void $ char '\"'
      content <- many $ satisfy (/= '\"')
      void $ char '\"'
      return (TagsInfo name content (toLowerStr content))
    parseWithoutContent = do
      void space >> withSpaces unit
      name <- many1 $ satisfy (`Prelude.notElem` ['=', '>', '/', ' '])
      notFollowedBy (char '=')
      return (TagsInfo name "" "")

parseTag :: Parser Candidate
parseTag = do
  void $ char '<'
  v <- parseTagName
  infos <- many parseAttr
  spaces
  closing <- optionMaybe $ char '/'
  void $ char '>'
  return (Candidate v infos (isJust closing))

brute :: Parser [Candidate]
brute = do
  v <- optionMaybe eof
  if isJust v
    then return []
    else do
      consume <- try (parseTag <&> Just) <|> (anyChar $> Nothing)
      case consume of
        Just x -> (x :) <$> brute
        Nothing -> brute

parseUrlName :: Parser String
parseUrlName = do
  void $ string "http"
  void $ optionMaybe (char 's')
  void $ string "://"
  many $ satisfy (/= '.')

parseHTML :: ByteString -> Either ParseError [Candidate]
parseHTML = parse brute ""