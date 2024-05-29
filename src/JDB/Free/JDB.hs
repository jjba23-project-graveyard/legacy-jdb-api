module JDB.Free.JDB
  ( health,
    HealthService (..),
    ActivityQuery (..),
    getActivities,
  )
where

import Data.UUID
import Free.AlaCarte
import JDB.Model.JDB
import Relude

type HealthService :: Type -> Type
data HealthService a
  = Health (Text -> a)
  deriving (Functor)

health :: (HealthService :<: f) => Free f Text
health = injectFree (Health Pure)

type ActivityQuery :: Type -> Type
data ActivityQuery a
  = GetActivities Env (GetActivitiesResponse -> a)
  deriving (Functor)

getActivities :: (ActivityQuery :<: f) => Env -> Free f GetActivitiesResponse
getActivities env = injectFree (GetActivities env Pure)
