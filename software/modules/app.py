
import fservcfg
import fservdb
import controller

class App(controller.Controller):

    def __init__(self):

        super().__init__(None, "app")

        self.set_cfg(fservcfg.FservCfg("config/fserv.ini"))

        db_connection_params = self.get_cfg().get_db_connection_params()
        self.set_db(fservdb.FservDB(db_connection_params))

    
    def get_app(self):

        return self