# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  topsumrep.py                             (\(\
# Func:    Reporting topic summaries                (^.^)
# # ## ### ##### ######## ############# #####################

import status, controller, fservdb, statprof


class TopicSummaryReporter(controller.Controller):

    def build_report(self, profile_dto):

        prof = statprof.Profile(self)
        prof.import_dto(profile_dto)


        # status_code, report_recs = self.get_db().fetch_topic_summary(topic_code)

        status_code = status.OK

        #report = self.export_result_dto(status_code, "report", prof)

        # report = self.export_result_dto(status_code, "report", prof.export_dto())

        report = prof.get_sql_conditions()

        return status_code, report