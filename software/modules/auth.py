# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  auth.py                                  (\(\
# Func:    Managing user sessions                   (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

import os
import hashlib
import uuid
from datetime import datetime, timedelta

import controller
import session


class Auth(controller.Controller):

    def __init__(self, chief, id=None):

        super().__init__(chief, id)


    def password_hash(self, password):

        return hashlib.md5(password.encode("utf-8")).hexdigest()


    def get_cms_session_duration(self):

        return self.get_cfg().get_cms_session_duration() 


    def check_credentials(self, req_user, req_password):

        cms_user, cms_password_hash = self.get_cfg().get_cms_credentials()

        req_password_hash = self.password_hash(req_password)

        return req_user == cms_user and req_password_hash == cms_password_hash


    def get_http_header(self, header_name):

        envname = ("http_" + header_name).upper()

        return os.environ[envname] if envname in os.environ else None  


    def assemble_token(self, data):

        token = str(uuid.uuid4())

        return token  


    def assemble_session_info(self, session):

        if session.get_field_value("token") is not None:
            status_code = 0
            message = "The credentials are accepted; the session is available."
        else:       
            status_code = 1
            message = "The credentials are rejected; no sessions are available."

        session_info = {
            "statusCode": status_code, 
            "message": message,
            "session": session.export_dto()}

        return session_info


    def init_session(self, req_user, req_password):

        access_allowed = self.check_credentials(req_user, req_password)
        token = self.assemble_token(None) if access_allowed else None
            
        user_session = session.Session(
                        token, req_user, self.get_http_header("Host"),  
                        datetime.now(), self.get_cms_session_duration())
        
        if user_session.is_valid():
            self.get_db().insert_session(user_session)
            
        return self.assemble_session_info(user_session)


    def check_session(self, token):

        return self.get_db().check_session(token)