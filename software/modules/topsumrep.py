# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  topsumrep.py                             (\(\
# Func:    Reporting topic summaries                (^.^)
# # ## ### ##### ######## ############# #####################

import status, controller, fservdb


class TopicSummaryReporter(controller.Controller):


    def build_report(self, topic_code):

        status_code, report_recs = self.get_db().fetch_topic_summary(topic_code)

        report = self.export_result_dto(status_code, "report", report_recs)

        return status_code, report