# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  bureaucrat.py                               (\(\
# Func:    Giving a pattern for all the objects here   (^.^)
# # ## ### ##### ######## ############# ##################### 

import uuid


class Bureaucrat:

    def __init__(self, chief):

        self.chief = chief
        self.id = uuid.uuid4()
        self.app = None
        self.cfg = None
        self.db = None
        self.req = None


    def set_id(self, id):

        self.id = id

        return self


    def get_id(self):

        return self.id


    def get_chief(self):

        return self.chief 


    def get_app(self):

        return self.app if self.app is not None else self.get_chief().get_app()    


    def set_cfg(self, cfg):

        self.cfg = cfg 

        return self


    def get_cfg(self):

        return self.cfg if self.cfg is not None else self.get_chief().get_cfg() 


    def set_db(self, db):

        self.db = db

        return self    


    def get_db(self):

        return self.db if self.db is not None else self.get_chief().get_db()  

    
    def set_req(self, req):

        self.req = req

        return self


    def get_req(self):

        return self.req if self.req is not None else self.get_chief().get_req()