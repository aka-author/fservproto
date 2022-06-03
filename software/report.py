#!C:/Program Files/Python37/python
#encoding: utf-8

import cgi
import io
import os
import sys
import time
import math
import json
from unittest import result
import uuid
import configparser
import psycopg2
from datetime import datetime


#
# Retrieving configuration params
#

def get_db_connection_params():

    config = configparser.ConfigParser()
    config.read("fserv.ini")

    db_connection_params = {
        "host": config["host"],
        "port": config["port"],
        "database": config["database"],
        "user": config["user"],
        "password": config["password"]
    }    

    return db_connection_params


#
# Accessing a database
#

def connect_db():

    dcp = get_db_connection_params()

    db_connection = psycopg2.connect(
        dbname=dcp["database"],
        host=dcp["host"],
        user=dcp["user"],
        password=dcp["password"])

    db_cursor = db_connection.cursor()

    return db_connection, db_cursor 


#
# Managing data structures
#


#
# Analyzing request
#

class Profile: 

    def __init__(self, json_object):

        pass


    def get_status_code(self):

        pass    


    def assemble_sql(self):

        pass    


    def fetch_samples(self, db_connection):

        pass 


    def get_sample_metrics_report(self):

        pass    



class RepRequest:

    def __init__(self, content):

        self.content = content

    def get_request_type(self):

        return self.content["requestType"]





#
# Assembling reports
#

# Comparing two samples

# Calculating the key metrics for samples by a profile

# Assembling summary for a set of topic versions

def topic_simple_summaries(request):

    db_connection, db_cursor = connect_db()



    query = \
        """select count(uuid)
    from testdata.reader_activities
    where online_doc_lang_code='en' and topic_code in """ + \
        + code_list \
        + " group by topic_code; "

    db_cursor.execute(query)

    query_outcome = db_cursor.fetchall()


    return {"topic_summaries": query_outcome}        


#
# Processing requests
#

class ReporterHttpResponse: 

    def __init__(self):

        self.result_code = 200
        self.result_wording = "OK"
        self.headers = {}
        self.set_content_type("application/json")
        self.body = {} 


    # Result 

    def set_result_code(self, code, wording):

        self.result_code = code
        self.result_wording = wording


    def serialize_result(self):

        return "HTTP/1.1 " + str(self.result_code) + " " + self.result_wording + "\n"


    # HTTP headers

    def get_header(self, name):

        if name in self.headers:
            return self.headers[name]    
        else:
            return None


    def set_header(self, name, content):

        self.headers[name] = content


    def serialize_header(self, name):

        if name in self.headers:
            return name + ": " + self.headers[name] + "\n"    
        else:
            return ""


    # Body

    def get_content_type(self):

        return self.get_header("Content-type")


    def set_content_type(self, content_type):
   
        self.set_header("Content-type", content_type) 


    def set_body(self, content):

        self.body = content


    def serialize_body(self):

        body_text = "\n"

        content_type = self.get_content_type()

        if content_type == 'application/json':
            body_text += json.dumps(self.body)
        
        return body_text


    # Entire response

    def serialize(self):

        response_text = ""

        for header_name in self.headers:
            response_text += self.serialize_header(header_name)

        response_text += self.serialize_body()    

        return response_text


#
# Checking access permissions
#

def check_token(token):

    is_valid = False

    _, db_cursor = connect_db()

    query = "select * from auth.sessions where "  \
            + "uuid='" + token + "'" \
            + " and " \
            + "timeout < '" + time.time() + "'" \
            + " and " \
            + "terminated_at is null;"

    db_cursor.execute(query)

    result = db_cursor.fetchall()

    is_valid = len(result) > 0

    return is_valid


def check_access_permissions():

    is_allowed = False

    header_name = "HTTP_PRAGMA"

    if header_name in os.environ:
        token = os.environ[header_name]
        is_allowed = check_token(token)

    return is_allowed

    
#
# Processing requests
#

def process_request():

    report = {}

    # Unpacking a request from a response
    content_len = os.environ.get('CONTENT_LENGTH', '0')
    request = json.loads(sys.stdin.read(int(content_len)))

    # Deteching and fulfilling the request 
    if request["queryType"] == "TOPIC_SIMPLE_SUMMARIES":
        report = topic_simple_summaries(request)


    # Assembling an HTTP response
    response = ReporterHttpResponse()
    response.set_body(report)     
    
    # Sending an HTTP request
    print(response.serialize())


#
# Main
#

process_request()