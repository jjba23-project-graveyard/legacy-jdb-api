module JDB.Servant.JDBRoutes where

import Free.AlaCarte
import JDB.Free.JDB
import JDB.Health ()
import Relude
import Servant

healthRoute :: Handler Text
healthRoute = liftIO (exec @HealthService $ health)
