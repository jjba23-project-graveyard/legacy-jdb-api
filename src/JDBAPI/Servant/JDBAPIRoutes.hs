module JDBAPI.Servant.JDBAPIRoutes where    

import Relude
import Servant
import JDBAPI.Free.JDBAPI

healthRoute :: Handler ()
healthRoute = liftIO (exec @(HealthService) $ health)

