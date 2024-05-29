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
import Data.Time
import Database.Redis qualified as Redis
import Hasql.Pool qualified
import JDB.Model.Config
import JDB.Model.JDB
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

mkApp :: AppConfig -> Hasql.Pool.Pool -> Redis.Connection -> IO Application
mkApp cfg pool _ = do
  now <- getZonedTime

  let env = Env {pool = pool, cfg = cfg, processStartedAt = now}
      apiItself = swagger :<|> wiredUpPublicServer env

  pure $ serve apiProxy apiItself

wiredUpPublicServer :: Env -> Server JDBPublicAPI
wiredUpPublicServer env =
  healthRoute :<|> getActivitiesRoute env :<|> getActivityRoute
