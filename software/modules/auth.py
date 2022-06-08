# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  auth.py                                  (\(\
# Func:    Managing user sessions                   (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

import hashlib
from datetime import datetime

import controller
import session


class Auth(controller.Controller):

    def __init__(self, chief, id=None):

        super().__init__(chief, id)


    def password_hash(self, password):

        return hashlib.md5(password.encode("utf-8")).hexdigest() if password is not None else None


    def get_cms_session_duration(self):

        return self.get_cfg().get_cms_session_duration() 


    def check_credentials(self, req_user, req_password):

        cms_user, cms_password_hash = self.get_cfg().get_cms_credentials()

        req_password_hash = self.password_hash(req_password)

        return req_user == cms_user and req_password_hash == cms_password_hash


    def init_session(self, req_user, req_pass):

        user_session = session.Session(self) 

        if self.check_credentials(req_user, req_pass):

            user_session.set_uuid()
            user_session.set_field_value("user", req_user)
            user_session.set_field_value("host", self.get_http_request().get_header_value("Host"))
            user_session.set_field_value("openedAt", datetime.now())
            user_session.set_expire_at(self.get_cms_session_duration())
        
            # user_session.insert_to_db()
            
        return self.assemble_session_info(user_session)


    def assemble_session_info(self, user_session):

        if user_session.is_valid():
            status_code = 0
            message = "The credentials are accepted; the session is available."
        else:       
            status_code = 1
            message = "The credentials are rejected; no sessions are available."

        session_info = {
            "statusCode": status_code, 
            "message": message,
            "session": user_session.export_dto()}

        return session_info


    def check_session(self, session_uuid):

        # user_session = session.Session(self, session_uuid)

        # user_session.select_from_db()

        # return session.is_active()

        pass