# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  bureaucrat.py                               (\(\
# Func:    Giving a pattern for all the objects here   (^.^)
# # ## ### ##### ######## ############# ##################### 

import uuid


class Bureaucrat:

    def __init__(self, chief, id=None):

        self.chief = chief
        self.id = id if id is not None else uuid.uuid4()
        self.app = None
        self.cfg = None
        self.db = None
        self.req = None


    def get_id(self):

        return self.id


    def get_chief(self):

        return self.chief 


    def get_app(self):

        return self.app if self.app is not None else self.get_chief().get_app()    


    def set_cfg(self, cfg):

        self.cfg = cfg    


    def get_cfg(self):

        return self.cfg if self.cfg is not None else self.get_chief().get_cfg() 


    def set_db(self, db):

        self.db = db    


    def get_db(self):

        return self.db if self.db is not None else self.get_chief().get_db()   

    
    def set_http_request(self, http_request):

        self.req = http_request


    def get_http_request(self):

        return self.req if self.req is not None else self.get_chief().get_http_req()