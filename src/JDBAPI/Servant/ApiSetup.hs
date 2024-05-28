{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDBAPI.Servant.ApiSetup where    
  ( mkApp,
    JDBAPIPublicAPI,
    JDBAPIAPIServer,
    wiredUpPublicServer,
  )
where

import Data.ByteString.Char8 qualified as C8
import Data.OpenApi qualified
import Data.Proxy
import Database.Redis qualified as Redis
import Hasql.Pool qualified
import Network.Wai
import Network.Wai.Middleware.Cors
import Network.Wai.RateLimit
import Network.Wai.RateLimit.Redis
import Network.Wai.RateLimit.Strategy
import Servant
import Servant.Auth.Server as SAS
import Servant.OpenApi

swagger :: Servant.Handler Data.OpenApi.OpenApi
swagger = pure $ toOpenApi docsProxy

apiProxy :: Proxy WikiMusicAPIServer
apiProxy = Proxy

docsProxy :: Proxy WikiMusicAPIDocsServer
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

wiredUpPublicServer :: Env -> Server WikiMusicPublicAPI
wiredUpPublicServer env =
  healthRoute

