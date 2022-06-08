# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  ModelField.py                             (\(\
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
        self.dto_ready = True
        self.serialize_format = ""
        self.publish_format = ""

    # Core properties

    def get_field_name(self):

        return self.field_name


    def get_datatype_name(self):

        return self.datatype_name

    
    def is_dto_ready(self):

        return self.dto_ready
        

    def get_empty_value(self):

        return None

    # Serializing and parsing values

    def set_serialize_format(self, format):

        self.serialize_format = format

    
    def get_serialize_format(self):

        return self.serialize_format


    def serialize(self, native_value):

        return str(native_value)


    def parse(self, serialized_value):

        return serialized_value

    # Publishing values

    def set_publish_format(self, format):

        self.publish_format = format

    
    def get_publish_format(self):

        return self.publish_format


    def publish(self, value):

        return str(value)    

    # Exchanging data via DTOs

    def repair_from_dto(self, dto_value):

        return dto_value


    def prepare_for_dto(self, native_value):

        return native_value


class StringModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "string")


class DTONotReadyModelField(ModelField):

    def __init__(self, field_name, datatype_name="dtoNotReady"):

        super().__init__(field_name, datatype_name)

        self.dto_ready = False


    def repair_from_dto(self, dto_value):

        return self.parse(dto_value)


    def prepare_for_dto(self, native_value):

        return self.serialize(native_value)      


class UuidModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "uuid") 


    def parse(self, serialized_value):

        return uuid.UUID(serialized_value).hex


class IntModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "int")


    def parse(self, serialized_value):

        return int(serialized_value)
    

class TimestampModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "timestamp")

        self.set_serialize_format(utils.get_default_timestamp_format())
        self.set_publish_format(utils.get_default_timestamp_format())


    def serialize(self, native_value):

        return datetime.strftime(native_value, self.get_serialize_format())


    def publish(self, native_value):

        return datetime.strftime(native_value, self.get_publish_format())
