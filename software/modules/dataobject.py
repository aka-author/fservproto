# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  DataObject.py                            (\(\
# Func:    Managing data objects                    (^.^)
# # ## ### ##### ######## ############# #####################

import utils

class DataObject:

    def __init__(self, dto):

        self.dto = dto
        self.import_dto(dto)
        

    def import_dto(self, dto):

        self.field_values = dto


    def export_dto(self):

        return self.field_values


    def dto_field_name(self, db_field_name):

        return utils.snake_to_camel(db_field_name)


    def get_field_value(self, field_name):

        return self.field_values[field_name] if field_name in self.field_values else None


    def assemble_db_field_value(self, dto_field_name):

        return self.get_field_value(dto_field_name)


    def export_db_record(self, db_field_names):

        db_record = {}    

        for db_field_name in db_field_names:
            dto_field_name = self.dto_field_name(db_field_name)
            db_field_value = self.assemble_db_field_value(dto_field_name)
            db_record[db_field_name] = db_field_value

        return db_record