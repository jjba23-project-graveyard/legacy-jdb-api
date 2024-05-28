module JDB.Free.JDB 
  ( health,
    HealthService(..),
  )
where

import Free.AlaCarte
import Relude

type HealthService :: Type -> Type
data HealthService a
  = Health (Text -> a)
  deriving (Functor)

health :: (HealthService :<: f) => Free f Text
health = injectFree (Health Pure)
