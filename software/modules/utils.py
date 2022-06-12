# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  utils.py                               (\(\
# Func:    Service functions                      (^.^)
# # ## ### ##### ######## ############# #####################

import hashlib, uuid
from datetime import datetime


# Avoiding None-related errors 

def ravnone(primary_value, default_value):

    return primary_value if primary_value is not None else default_value


def davnone(dic, key):

    return dic[key] if key in dic else None


def govnone(func, val):

    return func(val) if val is not None else None


# Strings

def snake_to_camel(snake):

    camel = snake[0]
    for idx in range(1, len(snake)):
        if snake[idx] != '_':
            if snake[idx-1] == "_":
                camel += snake[idx].upper()
            else:
                camel += snake[idx]      

    return camel


def md5(str):

    return hashlib.md5(str.encode("utf-8")).hexdigest()


# UUID

def str2uuid(str):

    uuid_ = None

    try:
        uuid_ = uuid.UUID(str)
    except:
        uuid_ = None

    return uuid_ 


# Date & time

def get_default_timestamp_format():

    return "%Y-%m-%d %H:%M:%S.%f"


def timestamp2str(timestamp, custom_format=None):

    format = ravnone(custom_format, get_default_timestamp_format())

    return datetime.strftime(timestamp, format) if timestamp is not None else None


def strnow():

    return timestamp2str(datetime.now())