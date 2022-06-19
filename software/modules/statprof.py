# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  statprof.py                               (\(\
# Func:    Parsing statistical profiles              (^.^)
# # ## ### ##### ######## ############# #####################

import modelfield, model

# Content scopes

class ContentScope(model.Model):

    def __init__(self, chief):

        super().__init__(chief, "contentScope")


    def define_fields(self):
        
        self.define_field(modelfield.StringModelField("varName"))
        self.define_field(modelfield.StringListModelField("range"))


    def get_sql_conditions(self, col_name):

        return self.get_sql_conditions("range", col_name)


class ContentScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):
        
        return ContentScope(self.get_model_chief())


# Time scopes

class TimeScope(model.Model):

    def __init__(self, chief):

        super().__init__(chief, "timeScope")


    def define_fields(self):

        self.define_field(modelfield.StringModelField("varName"))
        self.define_field(modelfield.TimestampSegmentModelField("range"))    


class TimeScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):

        return TimeScope(self.get_model_chief()) 


# Argument

class ArgumentModelField(modelfield.JsonObjectModelField):

    def repair_from_dto(self, dto_value):

        return dto_value


class Profile(model.Model):

    def __init__(self, chief):

        super().__init__(chief, "profile")


    def define_fields(self):

        self.define_field(ContentScopeModelField("contentScope", "contentScope", self))
        self.define_field(TimeScopeModelField("timeScope", "timeScope", self))
        self.define_field(ArgumentModelField("argument"))


    def import_dto(self, dto):
        
        super().import_dto(dto)


    def get_sql_conditions(self):

        c1 = self.get_field_value("contentScope").get_sql_conditions("topic_code")

        c2 = ""

        # c1 = self.fields["contentScope"]["field_values"]["range"].get_sql_conditions(self.get_field_value("contentScope"), "topic_code")
        # c2 = self.fields["timeScope"]["field_values"]["range"].get_sql_conditions(self.get_field_value("timeScope"), "accepted_at")

        return "(" + c1 + ") and (" + c2 + ")"



    

