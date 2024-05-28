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
import Network.Wai
import Relude
import Network.Wai.Middleware.Cors
import Network.Wai.RateLimit
import Network.Wai.RateLimit.Strategy
import Servant
import Servant.Auth.Server as SAS
import Servant.OpenApi
import JDB.Servant.ApiSpec
import JDB.Interaction.JDB
import JDB.Servant.JDBRoutes
import JDB.Model.Config

swagger :: Servant.Handler Data.OpenApi.OpenApi
swagger = pure $ toOpenApi docsProxy

apiProxy :: Proxy JDBAPIServer
apiProxy = Proxy

docsProxy :: Proxy JDBAPIDocsServer
docsProxy = Proxy

mkApp :: AppConfig ->  IO Application
mkApp cfg = do
  let apiItself =         swagger                   :<|> wiredUpPublicServer
               

  pure $ serve apiProxy apiItself

wiredUpPublicServer :: Server JDBPublicAPI
wiredUpPublicServer =
  healthRoute

