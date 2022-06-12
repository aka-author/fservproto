# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  controller.py                               (\(\
# Func:    Defining common behavior of controllers     (^.^)
# # ## ### ##### ######## ############# #####################

import bureaucrat


class Controller(bureaucrat.Bureaucrat):

    def __init__(self, chief):

        super().__init__(chief)


    def get_result_format_ver(self, payload_name):

        return 1


    def export_result_dto(self, status_code, payload_name=None, payload_dto=None):

        dto = {
            "ver": self.get_result_format_ver(payload_name),
            "statusCode": status_code,
        }
        
        if payload_name is not None:
            dto[payload_name] = payload_dto
        
        return dto