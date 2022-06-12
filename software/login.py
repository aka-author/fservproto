#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  login.py                                    (\(\
# Func:    Authorizing a CMS as a feedback serv. user  (^.^)                                                                                                                                                                  
# # ## ### ##### ######## ############# #####################

import sys

sys.path.append("modules")
from modules import httpreq, httpresp, auth, app


#
# Processing a request
#

class LoginApp(app.App):

    def process_request(self, http_req):

        resp = httpresp.HttpResponse()

        auth_agent = auth.Auth(self, http_req)
        session_info = auth_agent.open_session()
        
        resp.set_body(session_info)

        print(resp.serialize())


#
# Main
#

LoginApp().process_request(httpreq.HttpRequest())