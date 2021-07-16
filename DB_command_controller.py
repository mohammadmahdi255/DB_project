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
        else:
            print('Object Exists')

    def __call_procedure(self, procedure_name, parameter):
        with connect(
                host=self.__host,
                user=self.__user,
                password=self.__password,
                database=self._database) as connection:
            answer = []
            cursor = connection.cursor()
            try:
                answer.extend(cursor.callproc(procedure_name, args=parameter))
                for result in cursor.stored_results():
                    answer.extend(result.fetchall())
            except Error as e:
                log = ''.join(list(str(e)))
                answer.append(log)
            finally:
                cursor.close()
                connection.commit()

            return answer

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

    def check_login(self):
        return self.__call_procedure('check_login', (0,))

    def follow_user(self, followed_user_name):
        return self.__call_procedure('follow_user', (followed_user_name, 0))

    def get_ava_comments(self, select_ava_id, select_user_id):
        return self.__call_procedure('get_ava_comments', (select_ava_id, select_user_id, 0))

    def get_login_user(self):
        return self.__call_procedure('get_login_user', (0, 0))

    def get_the_activity_of_the_followers(self):
        return self.__call_procedure('get_the_activity_of_the_followers', (0,))

    def get_user_activity(self, blocked_user_name):
        return self.__call_procedure('get_user_activity', (blocked_user_name, 0))

    def like_ava(self, ava_id, ava_user_name):
        return self.__call_procedure('like_ava', (ava_id, ava_user_name, 0))

    def list_message_senders(self):
        return self.__call_procedure('list_message_senders', (0,))

    def receive_ava(self):
        return self.__call_procedure('receive_Ava', (0,))

    def receive_ava_of_a_special_symbol(self, text):
        return self.__call_procedure('receive_ava_of_a_special_symbol', (text, 0))

    def receive_count_of_like(self, select_ava_id, select_user_name):
        return self.__call_procedure('receive_count_of_Like', (select_ava_id, select_user_name, 0))

    def receive_list_message_of_user(self):
        return self.__call_procedure('receive_list_message_of_user', (0,))

    def receive_list_of_like(self, select_ava_id, select_user_name):
        return self.__call_procedure('receive_list_of_Like', (select_ava_id, select_user_name, 0))

    def receive_popular_ava(self):
        return self.__call_procedure('receive_popular_ava', ())

    def send_ava(self, receiver_user_name, ava_id, post_datetime):
        return self.__call_procedure('send_ava', (receiver_user_name, ava_id, post_datetime, 0))

    def send_message(self, receiver_user_name, mes_content, post_datetime):
        return self.__call_procedure('send_message', (receiver_user_name, mes_content, post_datetime, 0))

    def stop_block(self, blocked_user_name):
        return self.__call_procedure('stop_block', (blocked_user_name, 0))

    def stop_following(self, followed_user_name):
        return self.__call_procedure('stop_following', (followed_user_name, 0))


# print(s1.user_log('USER4', 'USER0010', 1))
# print(s1.check_login())
# print(s1.add_hashtag('#ABCu0'))
# print(s1.add_hashtag_to_ava(3, '#ABCu3'))
# print(s1.add_user('FN3', 'LN3', 'USER3', 'USER0003',
#                   datetime.datetime(2000, 10, 13, 10, 0, 0), datetime.datetime.now(), 'i am FN3'))
#
# print(s1.ava_comments('USER1', 2, 'this ok!'))
# print(s1.block_user('USER4'))
# print(s1.follow_user('USER3'))
# print(s1.get_ava_comments(2, 'USER4'))
# print(s1.get_login_user())
# print(s1.get_the_activity_of_the_followers())
# print(s1.get_user_activity('USER4'))
# print(s1.like_ava(1, 'USER1'))
# print(s1.list_message_senders())
# print(s1.receive_Ava())
# print(s1.receive_ava_of_a_special_symbol('#ABCui'))
# print(s1.receive_count_of_Like(1, 'USER1'))
# print(s1.receive_list_message_of_user())
# print(s1.receive_list_of_Like(1, 'USER1'))
# print(s1.receive_popular_ava())
# print(s1.send_ava('USER1', 3, datetime.datetime.now()))
# print(s1.send_message('USER1', 'HELOO LSDGO', datetime.datetime.now()))
# print(s1.stop_block('USER3'))
# print(s1.stop_following('USER3'))
