module JDBAPI.Servant.JDBAPIRoutes where    

import Relude
import Servant
import JDBAPI.Free.JDBAPI
import JDBAPI.Health

healthRoute :: Handler ()
healthRoute = liftIO (exec @HealthService $ health)

