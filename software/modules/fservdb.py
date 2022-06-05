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