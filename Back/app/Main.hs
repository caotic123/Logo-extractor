{-# LANGUAGE OverloadedStrings #-}
module Main (main) where
import Lib
import ParserHtml

main :: IO ()
main = startApp
--    print (parseHTML  "<!DOCTYPE html><html lang=\"pt\"><link rel=\"alternate\" hreflang=\"ms-MY\" href=\"https://my.linkedin.com/\">")