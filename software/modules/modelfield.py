# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  ModelField.py                             (\(\
# Func:    Processing model field values              (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import json, uuid

import utils 


class ModelField:

    def __init__(self, field_name, datatype_name="generic", rangetype_name="singular"):

        self.field_name = field_name
        self.key_mode = None
        self.datatype_name = datatype_name
        self.rangetype_name = rangetype_name
        self.serialize_format = ""
        self.parse_format = ""
        self.publish_format = ""


    # Core properties

    def get_field_name(self):

        return self.field_name


    def get_datatype_name(self):

        return self.datatype_name

    
    def get_rangetype_name(self):

        return self.datatype_name
        

    def get_empty_value(self):

        return None


    # Serializing and parsing values

    def set_serialize_format(self, format):

        self.serialize_format = format

    
    def get_serialize_format(self):

        return self.serialize_format


    def serialize(self, native_value, custom_format=None):

        return str(native_value)


    def set_parse_format(self, format):

        self.parse_format = format

    
    def get_parse_format(self):

        return self.parse_format


    def parse(self, serialized_value, custom_format=None):

        return serialized_value


    # Publishing values

    def set_publish_format(self, format):

        self.publish_format = format

    
    def get_publish_format(self):

        return self.publish_format


    def publish(self, native_value, custom_format=None):

        return self.serialize(native_value)


    # Exchanging data via DTOs

    def prepare_for_dto(self, native_value):

        return native_value


    def repair_from_dto(self, dto_value):

        return dto_value


class DTONotReadyModelField(ModelField):

    def repair_from_dto(self, dto_value):

        return self.parse(dto_value)


    def prepare_for_dto(self, native_value):

        return self.serialize(native_value)  

        
class RangeModelField(DTONotReadyModelField):

    def __init__(self, field_name, rangetype_name, base_field):

        datatype_name = base_field.get_datatype_name() + "_" + rangetype_name + "_range" 

        super().__init__(field_name, datatype_name)
        self.rangetype_name = rangetype_name
        self.base_field = base_field


    def get_rangetype_name(self):

        return self.rangetype_name


    def get_singular_field(self):

        return self.base_field


class BoundedRangeModelField(RangeModelField):

    def __init__(self, field_name, base_field):

        super().__init__(field_name, "bounded", base_field)


    def serialize(self, native_value):

        bf = self.get_base_field()

        serialized_min = bf.serialize(native_value["min"])
        serialized_max = bf.serialize(native_value["max"])

        serialized_value = {"min": serialized_min, "max": serialized_max}

        return serialized_value


    def prepare_for_dto(self, native_value):
        
        bf = self.get_base_field()

        dto_min_value = bf.prepare_for_dto(native_value["min"])
        dto_max_value = bf.prepare_for_dto(native_value["max"])

        dto_value = {"min": dto_min_value, "max": dto_max_value}

        return dto_value


    def repair_from_dto(self, dto_value):
        
        bf = self.get_base_field()

        native_min_value = bf.repair_from_dto(dto_value["min"])
        native_max_value = bf.repair_from_dto(dto_value["max"])

        native_value = {"min": native_min_value, "max": native_max_value}

        return native_value


class ListedRangeModelField(RangeModelField):

    def __init__(self, field_name, base_field):

        super().__init__(field_name, "listed", base_field)


    def serialize(self, native_value):
        
        serialized_value = []

        bf = self.get_base_field()

        for atomic_native_value in native_value:
            serialized_value.append(bf.serialized_value(atomic_native_value))

        return serialized_value


    def repair_from_dto(self, dto_value):
        
        native_value = []

        bf = self.get_base_field()

        for atomic_dto_value in dto_value:
            native_value.append(bf.repair_from_dto(atomic_dto_value))

        return native_value


    def prepare_for_dto(self, native_value):
        
        dto_value = []

        bf = self.get_base_field()

        for atomic_native_value in native_value:
            dto_value.append(bf.prepare_for_dto(atomic_native_value))

        return dto_value


class StringModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "string")


class StringRangeModelField(ListedRangeModelField):

    def __init__(self, field_name):

        super().__init__(field_name, StringModelField("template"))


    


class UuidModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "uuid") 


    def parse(self, serialized_value, custom_format=None):

        return uuid.UUID(serialized_value).hex


class IntModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "int")


    def parse(self, serialized_value, custom_format=None):

        return int(serialized_value)
    

class TimestampModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "timestamp")

        self.set_serialize_format(utils.get_default_timestamp_format())
        self.set_publish_format(utils.get_default_timestamp_format())


    def serialize(self, native_value, custom_format=None):

        return datetime.strftime(native_value, self.get_serialize_format())


    def publish(self, native_value, custom_format=None):

        return datetime.strftime(native_value, self.get_publish_format())


class JsonObjectModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "jsonObject")


    def serialize(self, native_value, custom_format=None):

        return json.dumps(native_value)


    def parse(self, serialized_value, custom_format=None):

        return json.load(serialized_value)


    def publish(self, native_value, custom_format=None):

        return self.serialize(native_value, custom_format)


    def repair_from_dto(self, dto_value):

        return dto_value


    def prepare_for_dto(self, native_value):

        return native_value


class ModelModelField(ModelField):

    def __init__(self, field_name, model_name=None, model_chief=None):

        super().__init__(field_name, utils.ravnone(model_name, "model"))

        self.set_model_chief(model_chief)


    def set_model_chief(self, model_chief):

        self.model_chief = model_chief

    
    def get_model_chief(self):

        return self.model_chief


    def serialize(self, native_value, custom_format=None):

        return native_value.serialize(custom_format)


    def parse(self, serialized_value, custom_format=None):

        return self.get_empty_value().parse(serialized_value, custom_format)


    def publish(self, native_value, custom_format=None):

        return native_value.publish(custom_format)


    def repair_from_dto(self, dto_value):

        return self.get_empty_value().import_dto(dto_value)


    def prepare_for_dto(self, native_value):

        return native_value.export_dto()


