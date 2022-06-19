# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  ModelField.py                              (\(\
# Func:    Processing model field values              (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import json, uuid

import utils 


class ModelField:

    def __init__(self, field_name, data_type_name="generic", range_type_name="singular"):

        self.field_name = field_name
        self.key_mode = None

        self.data_type_name = data_type_name
        self.range_type_name = range_type_name

        self.serialize_format = ""
        self.parse_format = ""
        self.publish_format = ""


    # Core properties

    def get_field_name(self):

        return self.field_name


    def get_data_type_name(self):

        return self.data_type_name

    
    def get_range_type_name(self):

        return self.data_type_name
        

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


    # Formatting for SQL

    def sql(self, native_value):

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


# Ranges
        
class RangeModelField(DTONotReadyModelField):

    def __init__(self, field_name, range_type_name, base_field):

        data_type_name = base_field.get_data_type_name() + "_" + range_type_name + "_range" 

        super().__init__(field_name, data_type_name)

        self.range_type_name = range_type_name
        self.base_field = base_field


    def get_base_field(self):

        return self.base_field


    def get_sql_conditions(colName):

        return ""


class SegmentRangeModelField(RangeModelField):

    def __init__(self, field_name, base_field):

        super().__init__(field_name, "segment", base_field)


    def assemble_value(self, min, max):

        return {"rangeTypeName": "segment", "values": {"min": min, "max": max}}


    def get_empty_value(self):
        
        return self.assemble_value(None, None)


    def get_min(self, native_value):

        return native_value["values"]["min"]

    
    def get_max(self, native_value):

        return native_value["values"]["max"]


    def serialize(self, native_value):

        bf = self.get_base_field()

        serialized_min = bf.serialize(native_value["values"]["min"])
        serialized_max = bf.serialize(native_value["values"]["max"])

        serialized_value = self.assemble_value(serialized_min, serialized_max)

        return serialized_value


    def sql(self, native_value):

        bf = self.get_base_field()

        sql_min = bf.serialize(native_value["values"]["min"])
        sql_max = bf.serialize(native_value["values"]["max"])

        sql_value = self.assemble_value(sql_min, sql_max)

        return sql_value


    def prepare_for_dto(self, native_value):
        
        bf = self.get_base_field()

        dto_min_value = bf.prepare_for_dto(native_value["values"]["min"])
        dto_max_value = bf.prepare_for_dto(native_value["values"]["max"])

        dto_value = self.assemble_value(dto_min_value, dto_max_value)

        return dto_value


    def repair_from_dto(self, dto_value):
        
        bf = self.get_base_field()

        native_min_value = bf.repair_from_dto(dto_value["values"]["min"])
        native_max_value = bf.repair_from_dto(dto_value["values"]["max"])

        native_value = self.assemble_value(native_min_value, native_max_value)

        return native_value


    def get_sql_conditions(self, native_value, colName):
        
        cond = ""

        sql_value = self.sql(native_value)
        min = sql_value["values"]["min"]
        max = sql_value["values"]["max"]

        if self.isOpenToRight():
            cond = min + "<=" + colName
        elif self.isOpenToLeft():
            cond = colName + " <= " + max
        elif self.isClosed():
            cond = min + "<=" + colName + " and " + colName + "<=" + max

        return cond 


class ListRangeModelField(RangeModelField):

    def __init__(self, field_name, base_field):

        super().__init__(field_name, "list", base_field)


    def assemble_value(self, list):

        return {"rangeTypeName": "list", "values": list}


    def serialize(self, native_value):

        bf = self.get_base_field()

        serialized_values = [bf.serialize(atomic_native_value) for atomic_native_value in native_value["values"]]

        return self.assemble_value(serialized_values)


    def sql(self, native_value):

        bf = self.get_base_field()

        sql_values = [bf.sql(atomic_native_value) for atomic_native_value in native_value["values"]]

        return self.assemble_value(sql_values)


    def prepare_for_dto(self, native_value):

        bf = self.get_base_field()

        dto_values = [bf.prepare_for_dto(atomic_native_value) for atomic_native_value in native_value["values"]]

        return self.assemble_value(dto_values)


    def repair_from_dto(self, dto_value):
        
        bf = self.get_base_field()

        native_values = [bf.repair_from_dto(atomic_dto_value) for atomic_dto_value in dto_value["values"]]

        return self.assemble_value(native_values)


    def get_sql_conditions(self, native_value, col_name):
        
        cond = ""
        
        value_list = ""

        for sql_value in self.sql(native_value):
            value_list += sql_value + ","

        value_list = value_list[:-1]

        cond = col_name + " in (" + value_list + ")"  
        
        return cond


# Strings

class StringModelField(ModelField):

    def __init__(self, field_name="noname"):

        super().__init__(field_name, "string")


    def sql(self, native_value):

        return "'" + native_value + "'"


class StringListModelField(ListRangeModelField):

    def __init__(self, field_name):

        super().__init__(field_name, StringModelField(field_name))


# UUIDs

class UuidModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "uuid") 


    def parse(self, serialized_value, custom_format=None):

        return uuid.UUID(serialized_value).hex


    def sql(self, native_value):

        return "'" + self.serialize(native_value) + "'"


# Numerics

class IntModelField(ModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "int")


    def parse(self, serialized_value, custom_format=None):

        return int(serialized_value)
    

# Date & time

class TimestampModelField(DTONotReadyModelField):

    def __init__(self, field_name):

        super().__init__(field_name, "timestamp")

        self.set_serialize_format(utils.get_default_timestamp_format())
        self.set_publish_format(utils.get_default_timestamp_format())


    def serialize(self, native_value, custom_format=None):

        return datetime.strftime(native_value, self.get_serialize_format())


    def publish(self, native_value, custom_format=None):

        return datetime.strftime(native_value, self.get_publish_format())


    def sql(self, native_value):

        return "'" + self.setialize(native_value) + "'"


    def repair_from_dto(self, dto_value):
        
        timestamp_format = utils.detect_timestamp_fromat(dto_value)

        return datetime.strptime(dto_value, timestamp_format)


class TimestampSegmentModelField(SegmentRangeModelField):

    def __init__(self, field_name):

        super().__init__(field_name, TimestampModelField(field_name))


# Complex values

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


    def prepare_for_dto(self, native_value):

        return native_value.export_dto()


    def repair_from_dto(self, dto_value):

        return self.get_empty_value().import_dto(dto_value)


    


