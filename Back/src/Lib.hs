{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Lib
  ( startApp,
    app,
  )
where

import Control.Monad.IO.Class
import Data.Aeson
import Data.String
import GHC.Generics
import Network.HTTP.Client
import Network.HTTP.Client.TLS (tlsManagerSettings)
import Network.Wai (Application)
import Network.Wai.Handler.Warp
import Search
import Servant
  ( Get,
    JSON,
    Proxy (..),
    QueryParam,
    Server,
    ServerError (errBody),
    err400,
    serve,
    throwError,
    type (:>),
  )

port :: Port
port = 8080

data Res = Res
  { success :: Bool,
    assets :: [Assets],
    status :: String
  }
  deriving (Show, Generic, Eq)

data Assets = Assets
  { -- |
    url :: String,
    rate :: Double
  }
  deriving (Show, Generic, Eq)

instance FromJSON Assets
instance ToJSON Assets
instance FromJSON Res
instance ToJSON Res

type API = QueryParam "url" String :> Get '[JSON] Res

api :: Servant.Proxy API
api = Servant.Proxy

startApp :: IO ()
startApp = do
  putStrLn ("Running server at " ++ show Lib.port)
  Network.Wai.Handler.Warp.run Lib.port app

app :: Application
app = serve api server

server :: Server API
server (Just x) = do
  liftIO $ fetch x
server Nothing = throwError (err400 {errBody = "Invalid Url"})

fetch :: String -> IO Res
fetch address = do
  managerClient <- newManager tlsManagerSettings
  request <- parseRequest address
  let req =
        request
          { requestHeaders = [("hUserAgent", "Mozilla / 5.0(Windows; U; WindowsNT 5.1; en - US; rv1.8.1.6) Gecko / 20070725 Firefox / 2.0.0.6"), ("hReferer", "http://www.google.com")]
          }
  response <- httpLbs req managerClient
  let content = responseBody response
  let res = case Search.run (fromString address) content of
        Right xs -> Res {success = True, assets = map (uncurry . flip $ Assets) xs, status = ""}
        Left err-> Res {success = False, assets = [], status = show err}
  return res