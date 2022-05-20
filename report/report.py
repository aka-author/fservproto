#!/usr/bin/python3

# Feedback reporter proto

# Immediate
import cgi
import io
import os
import sys
import math
import json
import uuid
from datetime import datetime

# To be installed 
import psycopg2

def fetch_samples():

    pass

def detect_requested_operation():

    return "SAMPLES"

def assemble_http_response()

def process_request():

    reqop = detect_requested_operation()

    if reqop == "SAMPLES":
        body = fetch_samples()

    print(assemble_http_response(body))


# Main
process_request()