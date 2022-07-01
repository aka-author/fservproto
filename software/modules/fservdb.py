# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  FservDB.py                                   (\(\
# Func:    Accessing a feedback database                (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime
import psycopg2

import  status, bureaucrat, utils


class FservDB(bureaucrat.Bureaucrat):

    def __init__(self, connection_params):

        self.connection_params = connection_params
        self.query_templates = {}
        self.define_dbnames()


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
        db_connection = None
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


    # Providing database object names

    def define_dbnames (self):

        self.dbnames = {

            "topicCode": "topic_code",
            "langCode": "online_doc_lang_code",
            "acceptedAt": "accepted_at"
        }


    def get_dbname(self, prop_name):

        return self.dbnames[prop_name]


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

        status_code, db_connection, db_cursor = self.connect()

        if status_code == status.OK:
            
            try:
                db_cursor.execute(query)
                self.close_expired_sessions(db_cursor)
                db_connection.commit()
            except:
                status_code = status.ERR_DB_QUERY_FAILED

            db_connection.close()

        return status_code


    def check_session(self, uuid):

        status_code = status.OK
        is_session_active = False

        query_template = self.get_query_template("check_session.sql")
        query = query_template.format(str(uuid), utils.timestamp2str(datetime.now()))

        connect_status_code, db_connection, db_cursor = self.connect()
        
        if connect_status_code == status.OK:
            
            try:
                db_cursor.execute(query)
                records = db_cursor.fetchall()
                is_session_active = len(records) > 0
            except:
                status_code = status.ERR_DB_QUERY_FAILED
            
            db_connection.close()
        else:
            status_code = connect_status_code

        return status_code, is_session_active


    def close_session(self, uuid):

        status_code = status.OK

        status_code, db_connection, db_cursor = self.connect()
        
        if status_code == status.OK:

            query_template = self.get_query_template("close_session.sql")
            query = query_template.format(str(uuid), utils.strnow())

            try:
                db_cursor.execute(query)
                if db_cursor.rowcount != 0:
                    db_connection.commit()    
                else:
                    status_code = status.ERR_NOT_FOUND    
            except:
                status_code = status.ERR_DB_QUERY_FAILED

            db_connection.close()

        return status_code


class FservDBQuery(bureaucrat.Bureaucrat):

    def __init__(self, chief):

        super().__init__(chief)

        self.reset_result()
        self.setup()
        self.db_cursor = None


    def set_db_cursor(self, db_cursor):

        self.db_cursor = db_cursor


    def get_db_cursor(self):

        return self.db_cursor


    def assemble_empty_result(self):

        return []


    def reset_result(self):

        self.result = self.assemble_empty_result()

        return self


    def setup(self):

        return self


    def fetch(self):

        pass


    def set_result(self, result):

        self.result = result


    def get_result(self):

        return self.result


    def execute(self, db_cursor):

        self.set_status_code(status.OK)
        self.set_db_cursor(db_cursor)

        self.set_result(self.fetch())

        return self



class TopicSummariesQuery(FservDBQuery):

    def __init__(self, chief, prof):

        self.prof = prof

        super().__init__(chief)


    def assemble_empty_result(self):
        
        return {"countries": [], "langs": [], "oss": [], "browsers": []}

        
    def assemble_topic_summaries_select_cols(self):

        return self.prof.get_field_value("argument").get_sql_select()

    
    def assemble_topic_summaries_where_conds(self):

        cond_content = self.prof.get_field_value("contentScope").get_sql_conditions("topic_code")
        cond_lang = self.prof.get_field_value("langScope").get_sql_conditions("online_doc_lang_code")
        cond_time = self.prof.get_field_value("timeScope").get_sql_conditions("accepted_at")

        return " and ".join([utils.pars(cond_content), utils.pars(cond_lang), utils.pars(cond_time)])


    def assemble_topic_summaries_group_by_cols(self):

        return self.prof.get_field_value("argument").get_sql_group_by()


    def assemble_topic_summaries_final_where_cons(self):

        return self.prof.get_argument().get_final_where_cons()

    
    def setup(self):

        self.query_template = self.get_db().get_query_template("topic_summaries.sql")        

        self.select_cols = self.assemble_topic_summaries_select_cols().format("a")
        self.where_conds = self.assemble_topic_summaries_where_conds().format("a")
        self.group_by_cols = self.assemble_topic_summaries_group_by_cols().format("a")
        self.final_where_conds = self.assemble_topic_summaries_final_where_cons().format("a", "trl")


    def fetch_partial(self, attrname):

        partial_result = []
        
        self.query_text = self.query_template.format(attrname, self.select_cols, self.where_conds, \
                            self.group_by_cols, self.final_where_conds)

        db_cursor = self.get_db_cursor()

        try:
            db_cursor.execute(self.query_text)
            if db_cursor.rowcount != 0:
                partial_result = db_cursor.fetchall()
            else:
                self.set_status_code(status.ERR_NOT_FOUND)
        except:
            self.set_status_code(status.ERR_DB_QUERY_FAILED)

        return partial_result


    def fetch(self):

        self.result["countries"] = self.fetch_partial("reader_country_code")

        self.result["langs"] = self.fetch_partial("reader_lang_code")
        self.result["oss"] = self.fetch_partial("reader_os_code")
        self.result["browsers"] = self.fetch_partial("reader_browser_code")

        entries = {}
        
        arglen = self.prof.get_field_value("argument").count_variables()
        argnames = self.prof.get_argument().get_varnames()

        for row in self.result["countries"]:

            hash = "#".join([row[i] for i in range(0, arglen)])
            
            entries[hash] = {}

            entries[hash]["argument"] = {} 
            entries[hash]["argument"]["variables"] = []

            for i in range(0, arglen):
                entries[hash]["argument"]["variables"].append({"varName": argnames[i], "range": {"dataTypeName": "string", "rangeTypeName": "list", "values": [row[i]]}})
                
            entries[hash]["values"] = {}

            for key in ["countries", "langs", "oss", "browsers"]:
                entries[hash]["values"][key] = [] 

            entries[hash]["values"]["goodness"] = 1 - row[arglen+4]
            entries[hash]["values"]["badness"] = row[arglen+4]
            entries[hash]["values"]["painFactor"] = 0.1

        for key in ["countries", "langs", "oss", "browsers"]:
            for row in self.result[key]:
                hash = "#".join([row[i] for i in range(0, arglen)])
                entries[hash]["values"][key].append({"code": row[arglen], 
                "count": row[arglen+1], "share": row[arglen+3]})

        summaries = []
        for hash in entries:
            summaries.append(entries[hash])

        return summaries


class TopicMessagesQuery(FservDBQuery):

    def __init__(self, chief, topic_code):

        self.topic_code = topic_code

        super().__init__(chief)


    def setup(self):

        self.query_template = self.get_db().get_query_template("topic_messages.sql")


    def fetch(self):
       
        result = []

        self.query_text = self.query_template.format(self.topic_code)

        db_cursor = self.get_db_cursor()
        rows=[]
        try:
            db_cursor.execute(self.query_text)
            if db_cursor.rowcount != 0:
                rows = db_cursor.fetchall()
            else:
                self.set_status_code(status.ERR_NOT_FOUND)
        except:
            self.set_status_code(status.ERR_DB_QUERY_FAILED)

        timestamp_format = utils.get_default_timestamp_format()

        for row in rows:
            result.append({
                "uuid": row[0], 
                "onlineDocCode": row[1], 
                "onlineDocLangCode": row[2], 
                "onlineDocVerNo": row[3],
                "topicCode": row[4], 
                "topicVerNo": row[5],
                "readerCountryCode": row[6], 
                "readerLangCode": row[7], 
                "readerOsCode": row[8], 
                "readerBrowserCode": row[9],
                "acceptedAt": datetime.strftime(row[10], timestamp_format),
                "messageTypeCode": row[11], 
                "messageText": row[12]
            })


        return result