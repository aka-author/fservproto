# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  topsumrep.py                             (\(\
# Func:    Reporting topic summaries                (^.^)
# # ## ### ##### ######## ############# #####################

import status, controller, fservdb, statprof, pickle


class TopicSummaryReporter(controller.Controller):

    def build_report(self, profile_dto):

        prof = statprof.Profile(self, profile_dto)
        prof.import_dto(profile_dto)

        status_code = status.OK

        db = self.get_db()
        conditions_for_activities = prof.get_sql_conditions()
        #status_code, report = db.fetch_topic_summaries(conditions_for_activities)
        report = conditions_for_activities #str(prof.field_values["timeScope"].field_values)

        return status_code, report