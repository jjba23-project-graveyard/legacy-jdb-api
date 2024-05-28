{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Servant.ApiSetup
  ( mkApp,
    JDBPublicAPI,
    JDBAPIServer,
    wiredUpPublicServer,
  )
where

import Data.ByteString.Char8 qualified as C8
import Data.OpenApi qualified
import Data.Proxy
import JDB.Interaction.JDB
import JDB.Model.Config
import JDB.Servant.ApiSpec
import JDB.Servant.JDBRoutes
import Network.Wai
import Network.Wai.Middleware.Cors
import Network.Wai.RateLimit
import Network.Wai.RateLimit.Strategy
import Relude
import Servant
import Servant.Auth.Server as SAS
import Servant.OpenApi

swagger :: Servant.Handler Data.OpenApi.OpenApi
swagger = pure $ toOpenApi docsProxy

apiProxy :: Proxy JDBAPIServer
apiProxy = Proxy

docsProxy :: Proxy JDBAPIDocsServer
docsProxy = Proxy

mkApp :: AppConfig -> IO Application
mkApp cfg = do
  let apiItself = swagger :<|> wiredUpPublicServer

  pure $ serve apiProxy apiItself

wiredUpPublicServer :: Server JDBPublicAPI
wiredUpPublicServer =
  healthRoute
