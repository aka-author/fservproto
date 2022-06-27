# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  topsumrep.py                             (\(\
# Func:    Reporting topic summaries                (^.^)
# # ## ### ##### ######## ############# #####################

import status, controller, fservdb, statprof, pickle


class TopicSummaryReporter(controller.Controller):

    def assemble_topsum(self, dto):

        return dto


    def build_report(self, profile_dto):

        status_code = status.OK
        topic_summaries_dto = {}

        prof = statprof.Profile(self, profile_dto)

        status_code, db_connect, db_cursor = self.get_db().connect()
        
        if status_code == status.OK:

            query = fservdb.TopicSummariesQuery(self, prof)
            query.execute(db_cursor)
       
            if query.isOK():
                topic_summaries_dto = self.assemble_topsum(query.get_result())
            else:
                status_code = status.ERR_NOT_FOUND
            
            db_connect.close()
        else:
            status_code = status.ERR_DB_CONNECTION_FAILED

        return status_code, topic_summaries_dto