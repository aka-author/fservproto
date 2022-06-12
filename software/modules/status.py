# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  status.py                                  (\(\
# Func:    Defining status and error codes            (^.^)
# # ## ### ##### ######## ############# #####################

# Constants

# Status and error codes

OK = 0
ERR_DB_CONNECTION_FAILED = 1
ERR_DB_QUERY_FAILED = 2
ERR_NOT_FOUND = 3
ERR_LOGIN_FAILED = 4


# Messages

MSG_LOGIN_OK = "Logged into the system."
MSG_LOGIN_FAILED = "Failed to login into the system."