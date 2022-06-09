#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  logout.py                            (\(\
# Func:    Closing a user session               (^.^)                                                                                                                                                                  
# # ## ### ##### ######## ############# #####################

import cgi
import sys

sys.path.append("modules")
from modules import auth
from modules import httpresp
from modules import app


class LogoutApp(app.App):

    def __init__(self):

        super().__init__()


    def process_request(self):

            auth_agent = auth.Auth(self)
            session_info = auth_agent.close_session(self.get_http_request().get_header_value("Cookie"))
            
            resp = httpresp.HttpResponse()
            resp.set_body(session_info)

            print(resp.serialize())
            print(self.get_http_request().get_header_value("Cookie"))

#
# Main
#

LogoutApp().process_request()        