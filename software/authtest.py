#!C:/Program Files/Python37/python
#encoding: utf-8

import cgi
from distutils.command.config import config
#from requests import request
import io
import os
import sys
import math
import json
from telnetlib import AUTHENTICATION
import uuid
import configparser
import psycopg2
from datetime import datetime

sys.path.append("modules")
from modules import fservconfig
from modules import fservdb


def check_access_permissions():

    print(os.environ)

    fc = fservconfig.FservConfig("config/fserv.ini")

    _, db_cursor = fservdb.FservDB(fc.get_db_connection_params())

    
def process_request():

    print("Content-type: application/json\n")

    check_access_permissions()


process_request()