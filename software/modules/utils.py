# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  utils.py                               (\(\
# Func:    Service functions                      (^.^)
# # ## ### ##### ######## ############# #####################

from datetime import datetime


def davnone(dic, key):

    return dic[key] if key in dic else None


def govnone(func, val):

    return func(val) if val is not None else None


def get_default_timestamp_format():

    return "%Y-%m-%d %H:%M:%S.%f"


def timestamp2str(timestamp):

    format = get_default_timestamp_format()

    return datetime.strftime(timestamp, format) if timestamp is not None else None


def snake_to_camel(snake):

    camel = snake[0]
    for idx in range(1, len(snake)):
        if snake[idx] != '_':
            if snake[idx-1] == "_":
                camel += snake[idx].upper()
            else:
                camel += snake[idx]      

    return camel