
import bureaucrat


class Controller(bureaucrat.Bureaucrat):

    def __init__(self, chief, id=None):

        super().__init__(chief, id)