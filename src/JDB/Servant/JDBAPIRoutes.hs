module JDB.Servant.JDBRoutes where    

import Relude
import Servant
import JDB.Free.JDB
import JDB.Health ()
import Free.AlaCarte

healthRoute :: Handler Text
healthRoute = liftIO (exec @HealthService $ health)

