# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  ModelFields.py                             (\(\
# Func:    Processing model field values              (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import uuid

import utils 


class ModelField:

    def __init__(self, field_name, datatype_name="generic"):

        self.field_name = field_name
        self.key_mode = None
        self.datatype_name = datatype_name
        self.serialize_format = ""
        self.publish_format = ""


    def get_field_name(self):

        return self.field_name


    def get_datatype_name(self):

        return self.datatype_name


    def get_empty_value(self):

        return None
        

    def set_serialize_format(self, format):

        self.serialize_format = format

    
    def get_serialize_format(self):

        return self.serialize_format


    def serialize(self, value):

        return str(value)


    def parse(self, serialized_value):

        return serialized_value


    def set_publish_format(self, format):

        self.publish_format = format

    
    def get_publish_format(self):

        return self.publish_format


    def publish(self, value):

        return str(value)    


class StringModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "string")


class UuidModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "uuid") 


    def serialize(self, value):

        return str(value)


    def parse(self, serialized_value):

        return uuid.UUID(serialized_value).hex      


class IntModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "int")


    def parse(self, serialized_value):

        return int(serialized_value)
    

class TimstampField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "timestamp")

        self.set_serialize_format(utils.get_default_timestamp_format())
        self.set_publish_format(utils.get_default_timestamp_format())


    def serialize(self, value):

        return datetime.strftime(value, self.get_serialize_format())


    def publish(self, value):

        return datetime.strftime(value, self.get_publish_format())


class DurationSecField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "duration")

        self.set_serialize_format(utils.get_default_timestamp_format())
        self.set_publish_format(utils.get_default_timestamp_format())


    def before_set_value(value):

        return value.total_seconds()


    def serialize(self, value):

        return int(value) + "second"


    def publish(self, value):

        return int(value) + "second"