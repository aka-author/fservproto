


import modelfield, model

"""
class Range(model.Model):

    def __init__(self, chief, rangetype_name, datatype_name="generic"):

        super().__init__(chief, "range")

        self.set_field_value("rangetypeName", rangetype_name)
        self.set_field_value("datatypeName", datatype_name) 


    def define_fields(self):

        self.define_field(modelfield.StringModelField("rangetypeName"))


    def get_range_type(self):

        return self.get_field_value("rangetypeName")


class ListedRange(Range):

    def __init__(self, chief, datatype_name, values):

        super().__init__(chief, "listed", datatype_name)



        



class BoundedRage(Range):

    def __init__(self, chief, datatype_name, min, max):

        super().__init__(chief, "bounded")

        self.set_field_value("datatypeName", datatype_name)
        self.set_min(min)
        self.set_max(max) 


    def set_min(self, min):

        self.set_field_value("min", min)


    def get_min(self):

        return self.get_field_value("min") 


    def set_max(self, max):

        self.set_field_value("max", max)


    def get_max(self):

        return self.get_field_value("max")    


class TimestampBoundedRange(BoundedRage):

    def __init__(self, chief, min, max):

        super().__init__(chief, "timestamp", min, max)


    def define_fields(self):

        super().__define_fields__()

        self.define_field(modelfield.TimestampModelField("min"))
        self.define_field(modelfield.TimestampModelField("max"))



class RangeModelField(modelfield.ModelModelField):


    def get_empty_value(self):
        




class VariableRange(model.Model):

    def __init__(self, chief, var_name, range):

        super().__init__("variable_name", chief)


    def define_fields(self):
        
        self.define_field(modelfield.StringModelField("varName"))
        self.define_field(RangeModelField("range"))
"""


class ContentRangeModelField(modelfield.JsonObjectModelField):

    def repair_from_dto(self, dto_value):

        return dto_value


class TimestampRangeModelField(modelfield.ModelModelField):

    def define_fields(self):

        super().define_fields()


    def get_empty_value(self):

        mod = model.Model(self.get_model_chief(), "contrntRange")

        mod.define_field(modelfield.StringModelField("varName"))
        mod.define_field(modelfield.JsonObjectModelField("range"))

        return mod 


class ArgumentModelField(modelfield.JsonObjectModelField):

    def repair_from_dto(self, dto_value):

        return dto_value


class Profile(model.Model):

    def __init__(self, chief):

        super().__init__(chief, "profile")


    def define_fields(self):

        self.define_field(ContentRangeModelField("contentScope", "contentRange", self))
        self.define_field(TimestampRangeModelField("timeScope"))
        self.define_field(ArgumentModelField("argument"))

