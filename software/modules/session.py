# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  session.py                                  (\(\
# Func:    Impersonating user sessions                 (^.^)                                                                                                                                            
# # ## ### ##### ######## ############# #####################

from datetime import timedelta
import uuid

import modelfield, model


class Session(model.Model): 

    def __init__(self, chief, uuid=None):

        super().__init__("session", chief)
        
        if uuid is not None:
            self.set_id(uuid)


    def define_fields(self):
        
        self.define_field(modelfield.UuidModelField("uuid"))
        self.define_field(modelfield.StringModelField("login"))
        self.define_field(modelfield.StringModelField("host"))
        self.define_field(modelfield.TimestampModelField("openedAt"))
        self.define_field(modelfield.TimestampModelField("expireAt"))
        self.define_field(modelfield.IntModelField("duration"))
        self.define_field(modelfield.TimestampModelField("closedAt"))


    def set_uuid(self):

        self.set_field_value("uuid", uuid.uuid4())


    def set_expire_at(self, duration):

        expire_at = self.get_field_value("openedAt") + timedelta(seconds=duration)

        self.set_field_value("expireAt", expire_at)


    def is_valid(self):
        
        return self.get_field_value("uuid") is not None