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
  = GetActivities Env (Map UUID ActivityResponse -> a)
  deriving (Functor)

getActivities :: (ActivityQuery :<: f) => Env -> Free f (Map UUID ActivityResponse)
getActivities env = injectFree (GetActivities env Pure)
