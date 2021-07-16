from GUI.gui_class import *


database = DBHelper(host="localhost",
                    user="root",
                    password="",
                    database="db_project")

loginPage(database)
