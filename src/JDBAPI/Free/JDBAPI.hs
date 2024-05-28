module JDBAPI.Free.JDBAPI where      
  ( health
    HealthService (..),
  )
where

import Free.AlaCarte
import Relude

type HealthService :: Type -> Type
data HealthService a
  = Health (Text -> a)
  deriving (Functor)

health :: (Logger :<: f) => Free f Text
health = injectFree (Health message Pure)
