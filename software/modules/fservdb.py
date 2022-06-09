# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  FservDB.py                                   (\(\
# Func:    Accessing a feedback database                (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import uuid
import psycopg2

import status
import utils


class FservDB:

    def __init__(self, connection_params):

        self.connection_params = connection_params
        self.query_templates = {}


    # Dealing with the DB itself 

    def get_connection_params(self):

        return self.connection_params


    def get_query_template(self, name):

        if not name in self.query_templates:
            query_name = "sql/" + name
            query_file = open(query_name, "r")
            self.query_templates[name] = query_file.read()
            query_file.close()

        return self.query_templates[name]


    def connect(self):

        status_code = status.OK
        db_cursor = None
        db_cursor = None

        dcp = self.get_connection_params()

        try:
            db_connection = psycopg2.connect(
                dbname=dcp["database"],
                host=dcp["host"],
                user=dcp["user"],
                password=dcp["password"])

            db_cursor = db_connection.cursor()
        except:
            status_code = status.ERR_DB_CONNECTION_FAILED

        return status_code, db_connection, db_cursor 


    # Working with entities

    def close_expired_sessions(self, db_cursor):

        status_code = status.OK

        query_template = self.get_query_template("close_expired_sessions.sql")
        query = query_template.format(utils.timestamp2str(datetime.now()))

        try:
            db_cursor.execute(query)
        except:
            status_code = status.ERR_DB_QUERY_FAILED

        return status_code 


    def open_session(self, user_session):

        status_code = status.OK

        query_template = self.get_query_template("open_session.sql")
        
        query = query_template.format(\
                    user_session.serialize_field_value("uuid"),
                    user_session.get_field_value("login"),
                    user_session.get_field_value("host"),
                    user_session.serialize_field_value("openedAt"),
                    user_session.serialize_field_value("expireAt"))

        connect_status_code, db_connecton, db_cursor = self.connect()

        if connect_status_code == status.OK:
            
            try:
                db_cursor.execute(query)
                self.close_expired_sessions(db_cursor)
                db_connecton.commit()
                db_connecton.close()
            except:
                status_code = status.ERR_DB_QUERY_FAILED

        return status_code


    def check_session(self, uuid):

        status_code = status.OK
        is_session_active = False

        query_template = self.get_query_template("check_session.sql")
        query = query_template.format(str(uuid), utils.timestamp2str(datetime.now()))

        connect_status_code, db_connecton, db_cursor = self.connect()
        
        if connect_status_code == status.OK:
            
            try:
                db_cursor.execute(query)
                result = db_cursor.fetchall()
                is_session_active = len(result) > 0
            except:
                status_code = status.ERR_DB_QUERY_FAILED
            
            db_connecton.close()
        else:
            status_code = connect_status_code

        return status_code, is_session_active


    def close_session(self, uuid):

        status_code = status.OK

        query_template = self.get_query_template("close_session.sql")
        query = query_template.format(str(uuid), utils.strnow())

        connect_status_code, db_connection, db_cursor = self.connect()
        
        if connect_status_code == status.OK:

            try:
                db_cursor.execute(query)
                db_connection.commit()
            except:
                status_code = status.ERR_DB_QUERY_FAILED

            db_connection.close()

        return status_code