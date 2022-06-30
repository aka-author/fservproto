#!C:/Program Files/Python37/python
#encoding: utf-8

# # ## ### ##### ######## ############# #####################
# Product: Online Docs Feedback Server
# Stage:   Prototype
# Module:  report.py                                  (\(\
# Func:    Fetching statistis from database           (^.^)
# # ## ### ##### ######## ############# #####################

import sys

sys.path.append("modules")
from modules import status, httpreq, httpresp, auth, topsumrep, app


class ReportApp(app.App):

    def detect_report_name(self, http_req):

        report_names = ["topic-summaries"]

        report_name = http_req.get_report_name() 

        return report_name if report_name in report_names else None 


    def process_request(self, http_req):

        resp = httpresp.HttpResponse()

        if auth.Auth(self, http_req).check_session(http_req.get_cookie()):

            status_code = status.OK

            if self.detect_report_name(http_req) == "topic-summaries": 
                reporter = topsumrep.TopicSummaryReporter(self)
                status_code, report = reporter.build_report(http_req.parse_json_body())
            else:
                status_code = status.ERR_REPORT_NOT_SUPPORTED

            if status_code == status.OK:
                resp.set_body(report)
            else:
                resp.set_result_404()
        else:
            resp.set_result_401()

        print(resp.serialize())


#
# Main
#

ReportApp().process_request(httpreq.HttpRequest())