import json

class HttpResponse: 

    def __init__(self):

        self.result_code = 200
        self.result_wording = "OK"
        self.headers = {}
        self.set_content_type("application/json")
        self.body = {} 


    # Result 

    def set_result_code(self, code, wording):

        self.result_code = code
        self.result_wording = wording


    def serialize_result(self):

        return "HTTP/1.1 " + str(self.result_code) + " " + self.result_wording + "\n"


    # HTTP headers

    def get_header(self, name):

        if name in self.headers:
            return self.headers[name]    
        else:
            return None


    def set_header(self, name, content):

        self.headers[name] = content


    def serialize_header(self, name):

        if name in self.headers:
            return name + ": " + self.headers[name] + "\n"    
        else:
            return ""


    # Body

    def get_content_type(self):

        return self.get_header("Content-type")


    def set_content_type(self, content_type):
   
        self.set_header("Content-type", content_type) 


    def set_body(self, content):

        self.body = content


    def serialize_body(self):

        body_text = "\n"

        content_type = self.get_content_type()

        if content_type == 'application/json':
            body_text += json.dumps(self.body)
        
        return body_text


    # Entire response

    def serialize(self):

        response_text = ""

        for header_name in self.headers:
            response_text += self.serialize_header(header_name)

        response_text += self.serialize_body()    

        return response_text