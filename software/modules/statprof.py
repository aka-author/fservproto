# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  statprof.py                               (\(\
# Func:    Parsing statistical profiles              (^.^)
# # ## ### ##### ######## ############# #####################

import modelfield, model


# Profile scopes

class ProfileScope(model.Model):

    def __init__(self, chief, scope_name, dto):

        self.dto = dto

        super().__init__(chief, scope_name)


    def define_fields(self):
        
        self.define_field(modelfield.StringModelField("varName"))
        self.define_field(modelfield.CreateRangeModelField(self, "range", self.dto))


    def get_sql_conditions(self, col_name):

        return super().get_sql_conditions("range", col_name)


class ProfileScopeModelField(modelfield.ModelModelField):

    def __init__(self, field_name, model_name, model_chief, dto):

        self.dto = dto

        super().__init__(field_name, model_name, model_chief)


# Content scopes

class ContentScope(ProfileScope):

    def __init__(self, chief, dto):

        super().__init__(chief, "contentScope", dto)


class ContentScopeModelField(ProfileScopeModelField):

    def get_empty_value(self):
        
        return ContentScope(self.get_model_chief(), self.dto)


# Language scopes

class LangScope(ProfileScope):

    def __init__(self, chief, dto):

        super().__init__(chief, "langScope")


class LangScopeModelField(ProfileScopeModelField):

    def get_empty_value(self):
        
        return LangScope(self.get_model_chief(), self.dto)


# Time scopes

class TimeScope(ProfileScope):

    def __init__(self, chief, dto):

        super().__init__(chief, "timeScope", dto)


class TimeScopeModelField(ProfileScopeModelField):

    def get_empty_value(self):

        return TimeScope(self.get_model_chief(), self.dto) 


# Argument

class ArgumentModelField(modelfield.JsonObjectModelField):

    def repair_from_dto(self, dto_value):

        return dto_value


# Profile

class Profile(model.Model):

    def __init__(self, chief, dto):

        self.dto = dto

        super().__init__(chief, "profile")


    def define_fields(self):

        self.define_field(ContentScopeModelField("contentScope", "contentScope", self, self.dto["contentScope"]["range"]))
        self.define_field(ContentScopeModelField("langScope", "langScope", self, self.dto["langScope"]["range"]))
        self.define_field(TimeScopeModelField("timeScope", "timeScope", self, self.dto["timeScope"]["range"]))
        self.define_field(ArgumentModelField("argument"))


    def import_dto(self, dto):
        
        super().import_dto(dto)


    def get_sql_conditions(self):

        cond_content = self.get_field_value("contentScope").get_sql_conditions("topic_code")
        cond_lang = self.get_field_value("langScope").get_sql_conditions("online_doc_lang_code")
        cond_time = self.get_field_value("timeScope").get_sql_conditions("accepted_at")

        return "(" + cond_content + ") and (" + cond_lang + ") and (" + cond_time + ")"


