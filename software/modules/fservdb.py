# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  FservDB.py                                   (\(\
# Func:    Accessing a feedback database                (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import uuid
import psycopg2

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

        dcp = self.get_connection_params()

        db_connection = psycopg2.connect(
            dbname=dcp["database"],
            host=dcp["host"],
            user=dcp["user"],
            password=dcp["password"])

        db_cursor = db_connection.cursor()

        return db_connection, db_cursor 


    # Working with entities

    def terminate_expired_sessions(self, db_cursor):

        query_template = self.get_query_template("terminate-session.sql")
        query = query_template.format(utils.timestamp2str(datetime.now()))
        db_cursor.execute(query)


    def insert_session(self, user_session):
        
        db_connecton, db_cursor = self.connect()

        query_template = self.get_query_template("insert-session.sql")
        
        query = query_template.format(\
                    user_session.serialize_field_value("uuid"),
                    user_session.get_field_value("login"),
                    user_session.get_field_value("host"),
                    user_session.serialize_field_value("openedAt"),
                    user_session.serialize_field_value("expireAt"))

        db_cursor.execute(query)

        self.terminate_expired_sessions(db_cursor)

        db_connecton.commit()
        db_connecton.close()


    def check_session(self, uuid):

        query_template = self.get_query_template("check-session.sql")
        query = query_template.format(str(uuid), utils.timestamp2str(datetime.now()))

        db_connecton, db_cursor = self.connect()
        db_cursor.execute(query)

        result = db_cursor.fetchall()

        db_connecton.close()

        return len(result) > 0