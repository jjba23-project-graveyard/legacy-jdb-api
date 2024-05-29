module JDB.Free.JDB
  ( health,
    HealthService (..),
    ActivityQuery (..),
    getActivities,
    TimeRangeCalculator (..),
    rangesFromMode,
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
  = GetActivities Env (Map UUID Activity -> a)
  deriving (Functor)

getActivities :: (ActivityQuery :<: f) => Env -> Free f (Map UUID Activity)
getActivities env = injectFree (GetActivities env Pure)

type TimeRangeCalculator :: Type -> Type
data TimeRangeCalculator a
  = RangesFromMode TimeslotGenMode ([TimeRange] -> a)
  deriving (Functor)

rangesFromMode :: (TimeRangeCalculator :<: f) => TimeslotGenMode -> Free f [TimeRange]
rangesFromMode mode = injectFree (RangesFromMode mode Pure)
