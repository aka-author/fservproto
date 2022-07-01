# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  topic-messages-report.py                  (\(\
# Func:    Reporting messages related to a topic     (^.^)
# # ## ### ##### ######## ############# #####################

import status, controller, fservdb, statprof


class TopicMessagesReporter(controller.Controller):

    def assemble_topsum(self, dto):

        return dto


    def build_report(self, topic_code):

        status_code = status.OK
        topic_messages_dto = {}

        status_code, db_connect, db_cursor = self.get_db().connect()
        
        if status_code == status.OK:

            query = fservdb.TopicMessagesQuery(self, topic_code)
            query.execute(db_cursor)
       
            if query.isOK():
                topic_messages_dto = self.assemble_topsum(query.get_result())
            else:
                status_code = status.ERR_NOT_FOUND
            
            db_connect.close()
        else:
            status_code = status.ERR_DB_CONNECTION_FAILED

        return status_code, self.export_result_dto(status_code, "topicMessages", topic_messages_dto)