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