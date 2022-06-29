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
    
        super().__init__(chief, "timeScope")


class TimeScopeModelField(modelfield.ModelModelField):

    def get_empty_value(self):

        return TimeScope(self.get_model_chief()) 


# Argument

class Argument(model.Model):

    def __init__(self, chief):
        
        super().__init__(chief, "argument")


    def define_fields(self):

        self.define_field(modelfield.JsonObjectModelField("variables"))


    def get_variables(self):

        return self.get_field_value("variables")


    def count_variables(self):

        return len(self.get_variables())


    def get_varnames(self):

        return [variable["varName"] for variable in self.get_variables()]


    def get_sql_select(self):

        variables = self.get_variables()

        varnames = ["{0}." + utils.camel_to_snake(variable["varName"]) for variable in variables]

        return ", ".join(varnames)


    def get_sql_group_by(self):

        variables = self.get_variables()

        varnames = ["{0}." + utils.camel_to_snake(variable["varName"]) for variable in variables]

        return ", ".join(varnames)


    def get_final_where_cons(self):

        variables = self.get_variables()

        varnames = [utils.camel_to_snake(variable["varName"]) for variable in variables]

        conds = []

        for varname in varnames:
            conds.append("{0}." + varname + "=" + "{1}." + varname)

        return " and ".join(conds)


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


    def get_content_scope(self):

        return self.get_field_value("contentScope")


    def get_lang_scope(self):

        return self.get_field_value("langScope")


    def get_time_scope(self):

        return self.get_field_value("timeScope")


    def get_argument(self):

        return self.get_field_value("argument")



