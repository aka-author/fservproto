#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  login.py
# Func:    Authorizing a CMS as a feedback serv. user  (\(\                                                                                                            
#                                                      (^.^)
# # ## ### ##### ######## ############# #####################

import cgi
import json
import sys

sys.path.append("modules")
from modules import fservcfg
from modules import fservauth


#
# Processing a request
#

def get_req_credencials():

    args = cgi.FieldStorage()

    req_user = args["user"].value if "user" in args else ""
    req_password = args["password"].value if "password" in args else ""

    return req_user, req_password


def format_body(session_info):

    return json.dumps(session_info)


def process_request():

    cfg = fservcfg.FservCfg("config/fserv.ini")
    req_user, req_password = get_req_credencials()
    auth = fservauth.FservAuth(cfg)
    session_info = auth.init_session(req_user, req_password)

    print("Content-type: application/json")
    print("\n")
    print(format_body(session_info))    
    

#
# Main
#

process_request()