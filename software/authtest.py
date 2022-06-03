#!C:/Program Files/Python37/python
#encoding: utf-8

import cgi
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

def check_access_permissions():

    if "HTTP_USER_AGENT" in os.environ: 
        print("USER AGENT:",  os.environ["HTTP_USER_AGENT"])
             
    if "HTTP_PRAGMA" in os.environ: 
        print("AUTH:",  os.environ["HTTP_PRAGMA"])   

    #request = Request()     

    #header = request.environ.get('HTTP_AUTHORIZATION')
    
    #print(header)

    print(os.environ)    


def process_request():


    print("Content-type: application/json\n")

    check_access_permissions()


process_request()