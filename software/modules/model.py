# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  model.py                                    (\(\
# Func:    Impersonating the subject area entities     (^.^)
# # ## ### ##### ######## ############# #####################

import utils

import bureaucrat


class Model(bureaucrat.Bureaucrat):

    def __init__(self, model_name, chief, id=None):

        super().__init__(chief, id)

        self.model_name = model_name
        self.fields = []
        self.key_names = []

        self.setup_fields()
        self.reset_field_values()


    def append_field(self, field, key_mode=None):

        field_name = field.get_field_name() 
        self.fields[field_name] = field

        if key_mode is not None:
            field.set_key_mode(key_mode)
            self.key_names.append(field_name)


    def get_key_names(self):

        return self.key_names


    def is_key(self, field_name):

        return field_name in self.key_names


    def setup_fields(self):

        pass


    def reset_field_values(self):

        for field_name in self.fields:
            empty_value = self.fields[field_name].get_empty_value()
            self.set_field_value(field_name, empty_value) 


    def get_model_name(self):

        return self.model_name
        

    def is_valid(self):

        return True


    def configure(self):

        pass


    def insert_to_db(self):

        self.get_db().insert_entity(self)


    def update_in_db(self):

        self.get_db().update_entity(self)    


    def select_from_db(self):

        data = self.get_db().select_entity(self)


    def import_dto(self, dto):

        self.field_values = dto


    def assemble_empty_dto(self):

        return {}


    def assemble_dto(self):

        return self.field_values


    def export_dto(self):

        return assemble_dto if self.is_valid() else assemble_empty_dto(self)


    def field_name(self, db_field_name):

        return utils.snake_to_camel(db_field_name)


    def get_field_value(self, field_name):

        return utils.davnone(self.field_values, field_name)


    def serialize_field_value(self, field_name):

        val = self.get_field_value(field_name)

        return utils.govnone(self.fields[field_name].serialize, val) 

    
    def publish_field_value(self, field_name):

        val = self.get_field_value(field_name)

        return utils.govnone(self.fields[field_name].publish, val)


    def assemble_db_field_value(self, field_name):

        return self.get_field_value(field_name)


    def export_db_record(self, db_field_names):

        db_record = {}    

        for db_field_name in db_field_names:
            field_name = self.field_name(db_field_name)
            db_field_value = self.assemble_db_field_value(field_name)
            db_record[db_field_name] = db_field_value

        return db_record