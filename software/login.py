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
from modules import fservcfg
from modules import fservauth
from modules import fservresp


#
# Processing a request
#

def get_req_credencials():

    args = cgi.FieldStorage()

    req_user = args["user"].value if "user" in args else ""
    req_password = args["password"].value if "password" in args else ""

    return req_user, req_password


def process_request():

    cfg = fservcfg.FservCfg("config/fserv.ini")
    req_user, req_password = "ditatoo", "verniteBibi" #get_req_credencials()

    auth = fservauth.FservAuth(cfg)
    session_info = auth.init_session(req_user, req_password)
    
    resp = fservresp.FservHttpResponse()
    resp.set_body(session_info)

    print(resp.serialize())


#
# Main
#

process_request()