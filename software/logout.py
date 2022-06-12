#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  logout.py                            (\(\
# Func:    Closing a user session               (^.^)                                                                                                                                                                  
# # ## ### ##### ######## ############# #####################

import sys

sys.path.append("modules")
from modules import status, httpreq, httpresp, auth, app


class LogoutApp(app.App):

    def process_request(self, http_req):

        resp = httpresp.HttpResponse()

        auth_agent = auth.Auth(self)

        session_uuid_str = http_req.get_cookie()
        status_code = auth_agent.close_session(session_uuid_str)
        
        if status_code != status.OK:
            resp.set_result_404()
        
        print(resp.serialize())


#
# Main
#

LogoutApp().process_request(httpreq.HttpRequest())        