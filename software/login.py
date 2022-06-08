#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  login.py                                     (\(\
# Func:    Authorizing a CMS as a feedback serv. user   (^.^)                                                                                                                                                                  
# # ## ### ##### ######## ############# #####################

import cgi
import sys

sys.path.append("modules")
from modules import auth
from modules import httpresp
from modules import app


#
# Processing a request
#

class LoginApp(app.App):

    def __init__(self):

        super().__init__()


    def get_req_credencials(self):

        req = self.get_http_request()

        req_login = req.get_field_value("user") 
        req_passw = req.get_field_value("password")

        return req_login, req_passw


    def process_request(self):

        req_login, req_passw = self.get_req_credencials()

        auth_agent = auth.Auth(self)
        session_info = auth_agent.init_session(req_login, req_passw)
        
        resp = httpresp.HttpResponse()
        resp.set_body(session_info)

        print(resp.serialize())


#
# Main
#

LoginApp().process_request()