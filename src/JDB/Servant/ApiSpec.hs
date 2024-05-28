module JDB.Servant.ApiSpec 
  ( 
    JDBPublicAPI,
    JDBAPIServer,
    JDBAPIDocsServer,
  )
where

{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}



import Data.OpenApi qualified
import Data.UUID hiding (fromString)
import Servant as S
import Servant.Auth as SA
import Servant.Auth.Server as SAS
import JDB.Servant.JDBRoutes
import Data.Text

type JDBAPIServer =
  SwaggerAPI
    :<|> JDBPublicAPI

type JDBAPIDocsServer = JDBPublicAPI 

type JDBHealthAPI =
  "health" :> Get '[JSON] Text

type JDBPublicAPI = JDBHealthAPI

type SwaggerAPI = "swagger.json" :> Get '[JSON] Data.OpenApi.OpenApi
