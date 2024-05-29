module JDB.Servant.JDBRoutes (healthRoute, getActivitiesRoute, getActivityRoute) where

import Data.UUID (UUID)
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Health ()
import JDB.Interaction.JDB
import JDB.Model.JDB
import JDB.PostgreSQL.ActivityQuery ()
import JDB.Time.TimeRangeCalculator ()
import Relude
import Servant

healthRoute :: Handler Text
healthRoute = liftIO (exec @HealthService $ health)

getActivitiesRoute :: Env -> Handler GetActivitiesResponse
getActivitiesRoute env =
  liftIO (exec @(ActivityQuery :+: TimeRangeCalculator) $ getActivitiesAction env)

getActivityRoute :: UUID -> Handler ActivityResponse
getActivityRoute identifier = throwError err404
