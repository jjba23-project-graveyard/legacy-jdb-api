module JDB.Servant.JDBRoutes (healthRoute, getActivitiesRoute, getActivityRoute) where

import Data.UUID (UUID)
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Health ()
import JDB.Model.JDB
import JDB.PostgreSQL.ActivityQuery ()
import Relude
import Servant

healthRoute :: Handler Text
healthRoute = liftIO (exec @HealthService $ health)

getActivitiesRoute :: Env -> Handler (Map UUID ActivityResponse)
getActivitiesRoute env =
  liftIO (exec @ActivityQuery $ getActivities env)

getActivityRoute :: UUID -> Handler ActivityResponse
getActivityRoute identifier = throwError err404
