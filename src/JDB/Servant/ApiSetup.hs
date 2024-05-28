{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Servant.ApiSetup
  ( mkApp,
    JDBPublicAPI,
    JDBAPIServer,
    wiredUpPublicServer,
  )
where

import Data.OpenApi qualified
import Data.Proxy
import JDB.Model.Config
import JDB.Servant.ApiSpec
import JDB.Servant.JDBRoutes
import Network.Wai
import Relude
import Servant
import Servant.OpenApi

swagger :: Servant.Handler Data.OpenApi.OpenApi
swagger = pure $ toOpenApi docsProxy

apiProxy :: Proxy JDBAPIServer
apiProxy = Proxy

docsProxy :: Proxy JDBAPIDocsServer
docsProxy = Proxy

mkApp :: AppConfig -> IO Application
mkApp _ = do
  let apiItself = swagger :<|> wiredUpPublicServer

  pure $ serve apiProxy apiItself

wiredUpPublicServer :: Server JDBPublicAPI
wiredUpPublicServer =
  healthRoute
