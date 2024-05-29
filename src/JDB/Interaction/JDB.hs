{-# LANGUAGE OverloadedLabels #-}

module JDB.Interaction.JDB (getActivitiesAction) where

import Data.Map qualified as Map
import Data.UUID
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Model.JDB
import Optics
import Relude

getActivitiesAction :: (ActivityQuery :<: f, TimeRangeCalculator :<: f) => Env -> Free f GetActivitiesResponse
getActivitiesAction env = do
  activities <- Map.assocs <$> getActivities env
  activities' <- mapM activityToResponse activities
  pure $
    GetActivitiesResponse
      { activities = Map.fromList activities',
        sortOrder = map fst activities'
      }

activityToResponse :: (TimeRangeCalculator :<: f) => (UUID, Activity) -> Free f (UUID, ActivityResponse)
activityToResponse (uid, activity) = do
  availabilities <- rangesFromMode (activity ^. #timeslotGenMode)
  pure (uid, ActivityResponse {..})
