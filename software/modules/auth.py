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

import utils
import dataobj
import fservdb


class Session(dataobj.DataObject): 

    def __init__(self, token, user, host, started_at, duration):

        expires_at = started_at + timedelta(seconds=duration)

        dto = {"token": token, "user": user, "host": host, 
               "startedAt": started_at, "duration": duration, "expiresAt": expires_at}

        super().__init__(dto)  


    def is_valid(self):
        
        return self.get_field_value("token") is not None


    def export_dto(self):
        
        dto = {
            "token": self.get_field_value("token"),
            "user": self.get_field_value("user"),
            "host": self.get_field_value("host"),
            "startedAt": utils.timestamp2str(self.get_field_value("startedAt")),
            "duration": self.get_field_value("duration"),
            "expiresAt": utils.timestamp2str(self.get_field_value("expiresAt"))}

        return dto


class Auth:

    def __init__(self, cfg):

        self.cfg = cfg
        self.db = fservdb.FservDB(self.cfg.get_db_connection_params())


    def get_cfg(self):

        return self.cfg


    def get_db(self):

        return self.db


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
            
        session = Session(
                    token, req_user, self.get_http_header("Host"),  
                    datetime.now(), self.get_cms_session_duration())
        
        if session.is_valid():
            self.get_db().insert_session(session)
            
        return self.assemble_session_info(session)


    def check_session(self, token):

        query_template = """select count(uuid) from auth.sessions where """

        pass



