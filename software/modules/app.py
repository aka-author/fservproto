# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  app.py                                    (\(\
# Func:    The main program behavior                 (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

import fservcfg, fservdb, controller


class App(controller.Controller):

    def __init__(self):

        super().__init__(None)

        self.set_cfg(fservcfg.FservCfg(self.get_cfg_file_path()))

        db_connection_params = self.get_cfg().get_db_connection_params()
        self.set_db(fservdb.FservDB(db_connection_params))

    
    def get_cfg_file_path(self):

        return "config/fserv.ini"


    def get_app(self):

        return self