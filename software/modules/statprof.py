# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  statprof.py                               (\(\
# Func:    Parsing statistical profiles              (^.^)
# # ## ### ##### ######## ############# #####################

import sys

import utils, modelfield, model


# Profile scopes

class ProfileScope(model.Model):

    def get_profile_dto(self):

        return self.get_chief().dto


    def get_range_dto(self):

        return self.get_chief().dto[self.get_model_name()]["range"]


    def define_fields(self):
        
        self.define_field(modelfield.StringModelField("varName"))
        self.define_field(modelfield.CreateRangeModelField(self, "range", self.get_range_dto()))


    def get_sql_conditions(self, col_name):

        return super().get_sql_conditions("range", col_name)


# Content scopes

class ContentScope(ProfileScope):

    def __init__(self, chief):

        super().__init__(chief, "contentScope")


class ContentScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):
        
        return ContentScope(self.get_model_chief())


# Language scopes

class LangScope(ProfileScope):

    def __init__(self, chief):

        super().__init__(chief, "langScope")


class LangScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):
        
        return LangScope(self.get_model_chief())


# Time scopes

class TimeScope(ProfileScope):

    def __init__(self, chief):
        print("::: time", file=sys.stderr)
        super().__init__(chief, "timeScope")


class TimeScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):

        return TimeScope(self.get_model_chief()) 


# Argument

class Argument(model.Model):

    def __init__(self, chief):
        
        super().__init__(chief, "argument")


    def define_fields(self):

        self.define_field(modelfield.JsonObjectModelField("varNames"))


    def get_sql_group_by(self):

        return ",".join(self.get_field_value("varNames"))


class ArgumentModelField(modelfield.ModelModelField):

    def get_empty_value(self):

        return Argument(self.get_model_chief()) 


# Profile

class Profile(model.Model):

    def __init__(self, chief, dto):

        self.dto = dto

        super().__init__(chief, "profile")

        self.import_dto(dto)


    def define_fields(self):

        self.define_field(ContentScopeModelField("contentScope", "contentScope", self))
        self.define_field(LangScopeModelField("langScope", "langScope", self))
        self.define_field(TimeScopeModelField("timeScope", "timeScope", self))
        self.define_field(ArgumentModelField("argument", "argument", self))


    def get_sql_conditions(self):

        cond_content = self.get_field_value("contentScope").get_sql_conditions("topic_code")
        cond_lang = self.get_field_value("langScope").get_sql_conditions("online_doc_lang_code")
        cond_time = self.get_field_value("timeScope").get_sql_conditions("accepted_at")

        return " and ".join([utils.pars(cond_content), utils.pars(cond_lang), utils.pars(cond_time)])


    def get_sql_group_by(self):

        return self.get_field_value("argument").get_sql_group_by()



