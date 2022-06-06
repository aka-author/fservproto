# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  FservCfg.py                                  (\(\
# Func:    Retrieving a feedback server configuration   (^.^)                                                                                                                                                                        
# # ## ### ##### ######## ############# #####################

import configparser


class FservCfg:

    def __init__(self, fserv_ini_file_path):
        self.set_fserv_ini_file_path(fserv_ini_file_path)
        self.config = configparser.ConfigParser()
        self.config.read(self.get_fserv_ini_file_path())
         

    def get_fserv_ini_file_path(self):

        return self.fserv_ini_file_path


    def set_fserv_ini_file_path(self, fserv_ini_file_path): 
        self.fserv_ini_file_path = fserv_ini_file_path    


    def get_param_value(self, sect_name, param_name):

        param_value = None

        if sect_name in self.config:
            if param_name in self.config[sect_name]:
                param_value = self.config[sect_name][param_name]

        return param_value


    def get_db_connection_params(self):

        db_connection_params = { 
            "host":     self.get_param_value("DATABASE", "host"),
            "port":     self.get_param_value("DATABASE", "port"),
            "database": self.get_param_value("DATABASE", "database"),
            "user":     self.get_param_value("DATABASE", "user"),
            "password": self.get_param_value("DATABASE", "password")
        }    

        return db_connection_params


    def get_cms_session_duration(self):

        duration = self.get_param_value("CMS_SESSION", "duration")

        return int(duration) if duration is not None else 60     


    def get_cms_credentials(self):

        cms_user = self.get_param_value("CMS_USER", "user")
        cms_password = self.get_param_value("CMS_USER", "password")    

        return cms_user, cms_password