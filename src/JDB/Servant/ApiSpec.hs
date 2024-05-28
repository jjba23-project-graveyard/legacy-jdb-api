{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Servant.ApiSpec
  ( JDBPublicAPI,
    JDBAPIServer,
    JDBAPIDocsServer,
  )
where

import Data.OpenApi qualified
import Data.Text
import Data.UUID hiding (fromString)
import JDB.Servant.JDBRoutes
import Servant as S
import Servant.Auth as SA
import Servant.Auth.Server as SAS

type JDBAPIServer =
  SwaggerAPI
    :<|> JDBPublicAPI

type JDBAPIDocsServer = JDBPublicAPI

type JDBHealthAPI =
  "health" :> Get '[JSON] Text

type JDBPublicAPI = JDBHealthAPI

type SwaggerAPI = "swagger.json" :> Get '[JSON] Data.OpenApi.OpenApi
