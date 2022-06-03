#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Online Docs Feedback Server
# Letting a CMS to access ODFS reports
#                                                     
#                                              (\(\          
#                                              (^.^)
# # ## ### ##### ######## ############# #####################

import cgi
from distutils.command.config import config
import io
import os
import sys
import math
import json
import uuid
import hashlib
import configparser
import psycopg2
import time
from datetime import datetime, date, time, timedelta



#
# Accessing configuration params
#

def pick_config():

    config = configparser.ConfigParser()
    config.read("fserv.ini")

    return config 


def get_cms_credencials():

    config = pick_config()

    return config["CMSUSER"]["user"], config["CMSUSER"]["password"]


def get_db_connection_params():

    config = pick_config()

    db_connection_params = {
        "host": config["DATABASE"]["host"],
        "port": config["DATABASE"]["port"],
        "database": config["DATABASE"]["database"],
        "user": config["DATABASE"]["user"],
        "password": config["DATABASE"]["password"]
    }    

    return db_connection_params


#
# Accessing a database
#

def connect_db():

    dcp = get_db_connection_params()

    db_connection = psycopg2.connect(
        dbname=dcp["database"],
        port=dcp["port"], 
        host=dcp["host"],
        user=dcp["user"],
        password=dcp["password"])
    
    db_cursor = db_connection.cursor()

    return db_connection, db_cursor 


#
# Unpacking request params
#

def get_req_credencials():

    args = cgi.FieldStorage()

    req_user = args["user"].value if "user" in args else ""
    req_password = args["password"].value if "password" in args else ""

    return req_user, req_password


#
# Security features
#

def hash_trivial(password):

    return password


def hash_poly(password):

  hash = 0
  base = 7879
  power = 1
  
  for c in password:
    hash += ord(c)*power % 1267650600228229401496703205377
    power *= base

  return hex(hash)[2:]     


def hash_sha256(password):

    hash = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), 
                "cherezzopukuvyrkom".encode(encoding='utf-8'), 100000, dklen=128) 

    return hash    


def password_hash(password):

    hash = hash_poly(password)

    return hash


def assemble_token():

    return uuid.uuid4()


def check_credentials(req_user, req_password):

    cms_user, cms_password_hash = get_cms_credencials()

    return req_user == cms_user and password_hash(req_password) == cms_password_hash


#
# Processing a request
#

def format_body(status_code, message, token):

    body = {"status_code": str(status_code), "message": message, "token": token}

    return json.dumps(body)


def process_request():

    print("Content-type: application/json")
    print("\n")
    
    req_user, req_password = get_req_credencials()
    
    if check_credentials(req_user, req_password):
        
        db_connecton, db_cursor = connect_db()

        session_uuid = str(assemble_token())
        host = os.environ["HTTP_HOST"] if "HTTP_HOST" in os.environ else ""  
        timestamp = datetime.now()
        timeout = get_cms_session_timeout()
        timeout = timestamp + timedelta(seconds=60)

        query = "insert into auth.sessions " \
                + "(uuid, user_name, user_host, started_at, expires_at) values ("\
                + "'" + session_uuid + "', "  \
                + "'" + req_user + "', "  \
                + "'" + host + "', "  \
                + "'" + datetime.strftime(timestamp, "%Y-%m-%d %H:%M:%S.%f") + "', "\
                + "'" + datetime.strftime(timeout, "%Y-%m-%d %H:%M:%S.%f") + "'" \
                + ");"

        db_cursor.execute(query)

        db_connecton.commit()
        db_connecton.close()

        print(format_body(0, "Access is allowed", session_uuid))

    else:
        print(format_body(1, "Access is denied", ""))
    

#
# Main
#

process_request()