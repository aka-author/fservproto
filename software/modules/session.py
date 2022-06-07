# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  session.py                                  (\(\
# Func:    Impersonating user sessions                 (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

from datetime import datetime, timedelta

import utils
import model
import fservdb
import controller


class Session(model.Model): 

    def __init__(self, token, user, host, started_at, duration):

        super().__init__(None, token)

        expires_at = started_at + timedelta(seconds=duration)

        dto = {"token": token, "user": user, "host": host, 
               "startedAt": started_at, "duration": duration, "expiresAt": expires_at}

        self.import_dto(dto)  


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


