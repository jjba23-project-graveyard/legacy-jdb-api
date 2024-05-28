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
import JDB.Model.JDB
import Servant as S

type JDBAPIServer =
  SwaggerAPI
    :<|> JDBPublicAPI

type JDBAPIDocsServer = JDBPublicAPI

type JDBHealthAPI =
  "health" :> Get '[JSON] Text

type JDBActivitiesAPI =
  "activities" :> Get '[JSON] [ActivityResponse]
    :<|> "activities" :> Capture "identifier" UUID :> Get '[JSON] ActivityResponse

type JDBPublicAPI = JDBHealthAPI :<|> JDBActivitiesAPI

type SwaggerAPI = "swagger.json" :> Get '[JSON] Data.OpenApi.OpenApi
