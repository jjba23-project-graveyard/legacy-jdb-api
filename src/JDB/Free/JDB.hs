module JDB.Free.JDB
  ( health,
    HealthService (..),
    ActivityQuery (..),
    getActivities
  )
where

import Free.AlaCarte
import Relude
import JDB.Model.JDB
import Data.UUID

type HealthService :: Type -> Type
data HealthService a
  = Health (Text -> a)
  deriving (Functor)

health :: (HealthService :<: f) => Free f Text
health = injectFree (Health Pure)

type ActivityQuery :: Type -> Type
data ActivityQuery a
  = GetActivities Env (Map UUID ActivityResponse -> a)

getActivities env = injectFree (GetActivities env Pure)
