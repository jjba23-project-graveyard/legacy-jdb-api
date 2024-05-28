{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDBAPI.Servant.ApiSetup 
  ( mkApp,
    JDBAPIPublicAPI,
    JDBAPIAPIServer,
    wiredUpPublicServer,
  )
where

import Data.ByteString.Char8 qualified as C8
import Data.OpenApi qualified
import Data.Proxy
import Network.Wai
import Network.Wai.Middleware.Cors
import Network.Wai.RateLimit
import Network.Wai.RateLimit.Strategy
import Servant
import Servant.Auth.Server as SAS
import Servant.OpenApi
import JDBAPI.Servant.ApiSpec

swagger :: Servant.Handler Data.OpenApi.OpenApi
swagger = pure $ toOpenApi docsProxy

apiProxy :: Proxy JDBAPIAPIServer
apiProxy = Proxy

docsProxy :: Proxy JDBAPIAPIDocsServer
docsProxy = Proxy

mkApp :: AppConfig -> Hasql.Pool.Pool -> Redis.Connection -> IO Application
mkApp cfg pool redisConn = do
  now <- getCurrentTime
  myKey <- generateKey

  let env = Env {pool = pool, cfg = cfg, processStartedAt = now}
      authCfg = authCheckIO env
      apiCfg = authCfg :. cookieSettings (cfg ^. #cookie) :. defaultJWTSettings myKey :. EmptyContext
      apiItself =         swagger                   :<|> wiredUpPublicServer
               

  pure
    . myCors (cfg ^. #cors)
    . rateLimitingMiddleware redisConn
    $ serveWithContext apiProxy apiCfg apiItself

wiredUpPublicServer :: Server JDBAPIPublicAPI
wiredUpPublicServer =
  healthRoute

