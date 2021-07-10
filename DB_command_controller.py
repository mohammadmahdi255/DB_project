from mysql.connector import connect, Error


class DBHelper:
    __instance = None

    def __init__(self, host, user, password, database=None, overwrite=False):

        if DBHelper.__instance is None or overwrite:
            DBHelper.__instance = self
            self.__host = host
            self.__user = user
            self.__password = password
            self._database = database
            self.__connection = None
            self.connect_to_database()
        else:
            print('Object Exists')

    def connect_to_database(self):

        try:
            self.__connection = connect(
                host=self.__host,
                user=self.__user,
                password=self.__password,
                database=self._database)
        except Error as e:
            print(e)

    def check_login(self):
        try:
            cursor = self.__connection.cursor()
            check_login = """SELECT * FROM USER_DATA; SELECT * FROM USER_DATA; """
            cursor.execute(check_login, multi=True)
            res = cursor.fetchall()
            for row in res:
                print(row)
            cursor.close()
            self.__connection.commit()
        except Error as e:
            print(e)


s1 = DBHelper(host="localhost",
              user="root",
              password="",
              database="db_project")

s1.check_login()
