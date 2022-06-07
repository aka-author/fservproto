# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  session.py                                  (\(\
# Func:    Impersonating user sessions                 (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

from datetime import timedelta
import uuid

import utils
import mfield
import model


class Session(model.Model): 

    def __init__(self, token_payload):

        super().__init__("session", None, self.assemble_token(token_payload))


    def setup_fields(self):
        
        self.append_field(mfield.StringModelField("uuid"))
        self.append_field(mfield.StringModelField("user"))
        self.append_field(mfield.StringModelField("host"))
        self.append_field(mfield.TimestampModelField("started_at"))
        self.append_field(mfield.DurationModelField("duration"))
        self.append_field(mfield.TimestampModelField("expires_at"))
        self.append_field(mfield.TimestampModelField("terminated_at"))


    def assemble_token(self, payload):

        token = str(uuid.uuid4())

        return token  


    def configure(self, user, host, started_at, duration):

        self.set_field_value("user", user)
        self.set_field_value("host", host) 
        self.set_field_value("startedAt", started_at), 
        self.set_field_value("duration", duration)
        self.set_field_value("expiresAt", started_at + timedelta(seconds=duration))


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


