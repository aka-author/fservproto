# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  httpreq.py                                  (\(\
# Func:    Accessing HTTP request data                 (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

import os
import sys
import cgi
import json


class HttpRequest:

    def __init__(self, data=None):

        self.data = data
    

    def get_header_value(self, header_name):

        envname = ("http_" + header_name).upper()

        return os.environ[envname] if envname in os.environ else None  


    def get_cookie(self):

        return self.get_header_value("Cookie")


    def get_host(self):

        return self.get_header_value("Host")


    def get_field_value(self, field_name):

        args = cgi.FieldStorage()

        return args[field_name].value if field_name in args else None


    def get_credentials(self):

        login = self.get_field_value("user") 
        passw = self.get_field_value("password")

        return login, passw


    def get_url_param_value(self, param_name):

        param_value = ""

        params = os.environ["REQUEST_URI"].split("/")

        probable_param_name = ""

        for clause in params:

            if probable_param_name == param_name:
                param_value = clause
                break

            probable_param_name = clause

        return param_value


    def get_report_name(self):

        return self.get_url_param_value("reports")


    def parse_json_body(self):

        content_len = os.environ.get('CONTENT_LENGTH', '0')

        return json.loads(sys.stdin.read(int(content_len)))            