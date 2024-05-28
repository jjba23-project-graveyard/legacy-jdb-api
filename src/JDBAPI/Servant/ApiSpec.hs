module JDBAPI.Servant.ApiSpec 
  ( JDBAPIPrivateAPI,
    JDBAPIPublicAPI,
    JDBAPIAPIServer,
    JDBAPIAPIDocsServer,
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
import JDBAPI.Servant.JDBAPIRoutes

type JDBAPIAPIServer =
  SwaggerAPI
    :<|> JDBAPIPublicAPI

type JDBAPIAPIDocsServer = JDBAPIPublicAPI 

type JDBAPIHealthAPI =
  "health" :> Get '[JSON] Text

type JDBAPIPublicAPI = JDBAPIHealthAPI

type SwaggerAPI = "swagger.json" :> Get '[JSON] Data.OpenApi.OpenApi
