import os
import sys
import hashlib
import json
import uuid
from datetime import datetime, timedelta

import fservdb


class FservAuth:

    def __init__(self, cfg):

        self.cfg = cfg


    def password_hash(self, password):

        return hashlib.md5(password.encode("utf-8")).hexdigest()


    def get_cms_credentials(self):

        cms_user = self.cfg.get_param_value("CMS_USER", "user")
        cms_password = self.cfg.get_param_value("CMS_USER", "password")

        return cms_user, cms_password 


    def get_cms_session_duration(self):

        return self.cfg.get_cms_session_duration() 


    def check_credentials(self, req_user, req_password):

        cms_user, cms_password_hash = self.get_cms_credentials()

        req_password_hash = self.password_hash(req_password)

        return req_user == cms_user and req_password_hash == cms_password_hash


    def get_http_header(self, header_name):

        envname = ("http_" + header_name).upper()

        return os.environ[envname] if envname in os.environ else None  


    def assemble_token(self, data):

        token = str(uuid.uuid4())

        return token


    def register_session(self, session):

        db = fservdb.FservDB(self.cfg.get_db_connection_params())
            
        db_connecton, db_cursor = db.connect()

        query_template = """insert into auth.sessions  
                    (token, login, host, started_at, expires_at) 
                    values ('{0}', '{1}', '{2}', '{3}', '{4}');"""

        query = query_template.format(\
                    session["token"], session["user"], session["host"], \
                    datetime.strftime(session["started_at"], "%Y-%m-%d %H:%M:%S.%f"), \
                    datetime.strftime(session["expires_at"], "%Y-%m-%d %H:%M:%S.%f"))

        db_cursor.execute(query)

        db_connecton.commit()
        db_connecton.close()


    def assemble_session_info(self, session):

        if session["token"] is not None:
            session_info = {
                "status_code": 0, 
                "token": session["token"], 
                "duration": session["duration"], 
                "message": "Accepted"}
        else:
            session_info = {
                "status_code": 1, 
                "token": None, 
                "duration": None, 
                "message": "Rejected"}

        return session_info


    def init_session(self, req_user, req_password):

        if self.check_credentials(req_user, req_password):
        
            started_at = datetime.now()
            duration = self.get_cms_session_duration()
            expires_at = started_at + timedelta(seconds=duration)

            session = {
                "token":  self.assemble_token(None),
                "user": req_user,
                "host": self.get_http_header("Host"),  
                "started_at": started_at,
                "duration": duration,
                "expires_at": expires_at}

            self.register_session(session)

        else:
            session = {"token":  None}                   
            
        return self.assemble_session_info(session)


    def check_session(self, token):

        pass



