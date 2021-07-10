import datetime

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

    def __call_procedure(self, procedure_name, parameter):
        answer = []
        cursor = self.__connection.cursor()
        try:
            answer.extend(cursor.callproc(procedure_name, args=parameter))
            for result in cursor.stored_results():
                answer.extend(result.fetchall())
        except Error as e:
            print(e)
        finally:
            cursor.close()
            self.__connection.commit()

        return answer

    def check_login(self):
        return self.__call_procedure('check_login', (0,))

    def user_log(self, user_name, password, login=1):
        return self.__call_procedure('user_log', (user_name, password, login, 0))

    def add_ava(self, ava_content, post_datetime):
        return self.__call_procedure('add_ava', (ava_content, post_datetime, 0))

    def add_hashtag(self, text):
        return self.__call_procedure('add_hashtag', (text, 0))

    def add_hashtag_to_ava(self, ava_id, text):
        return self.__call_procedure('add_hashtag_to_ava', (ava_id, text, 0))

    def add_user(self, first_name, last_name, user_name,
                 password, birthday, register_day, biography):
        return self.__call_procedure('add_user', (first_name, last_name, user_name,
                                                  password, birthday, register_day, biography))

    def ava_comments(self, receiver_user_name, receiver_ava_id, content):
        return self.__call_procedure('ava_comments', (receiver_user_name, receiver_ava_id, content, 0))

    def block_user(self, blocked_user_name):
        return self.__call_procedure('block_user', (blocked_user_name, 0))


s1 = DBHelper(host="localhost",
              user="root",
              password="",
              database="db_project")

print(s1.user_log('USER4', 'USER0002', 1))
print(s1.check_login())
print(s1.add_hashtag('#ABCu0'))
print(s1.add_hashtag_to_ava(3, '#ABCu3'))
print(s1.add_user('FN3', 'LN3', 'USER3', 'USER0003',
                  datetime.datetime(2000, 10, 13, 10, 0, 0), datetime.datetime.now(), 'i am FN3'))

print(s1.ava_comments('USER1', 2, 'this ok!'))
print(s1.block_user('USER4'))
