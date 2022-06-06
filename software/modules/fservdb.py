# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  FservDB.py                                   (\(\
# Func:    Accessing a feedback database                (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import psycopg2


class FservDB:

    def __init__(self, connection_params):

        self.connection_params = connection_params


    def get_connection_params(self):

        return self.connection_params


    def connect(self):

        dcp = self.get_connection_params()

        db_connection = psycopg2.connect(
            dbname=dcp["database"],
            host=dcp["host"],
            user=dcp["user"],
            password=dcp["password"])

        db_cursor = db_connection.cursor()

        return db_connection, db_cursor 


    def insert_session(self, session):

        session_fields = ["token", "user", "host", "started_at", "expires_at"]
        
        session_record = session.export_db_record(session_fields)

        db_connecton, db_cursor = self.connect()

        query_template = """insert into auth.sessions  
                    (token, login, host, started_at, expires_at) 
                    values ('{0}', '{1}', '{2}', '{3}', '{4}');"""
        
        query = query_template.format(\
                    session_record["token"], session_record["user"], session_record["host"], \
                    datetime.strftime(session_record["started_at"], "%Y-%m-%d %H:%M:%S.%f"), \
                    datetime.strftime(session_record["expires_at"], "%Y-%m-%d %H:%M:%S.%f"))

        db_cursor.execute(query)

        db_connecton.commit()
        db_connecton.close()