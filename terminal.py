import datetime
from DB_command_controller import DBHelper


def fix_input(array: list):
    return list(map(lambda x: str(x) if str(x) != '' else None, array))


if __name__ == '__main__':

    database = DBHelper(host="localhost",
                        user="root",
                        password="",
                        database="db_project")

    while True:

        in_put = input('Enter Command: ').split(' ')

        in_put = fix_input(in_put)

        if in_put[0] == 'user-log':
            database.user_log(str(in_put[1]), str(in_put[2]), int(in_put[3]))
        elif in_put[0] == 'check-login':
            database.check_login()
        elif in_put[0] == 'add-hashtag':
            database.add_hashtag(str(in_put[1]))
        elif in_put[0] == 'add-hashtag-to-ava':
            database.add_hashtag_to_ava(int(in_put[1]), str(in_put[2]))
        elif in_put[0] == 'add-user':
            database.add_user(str(in_put[1]), str(in_put[2]), str(in_put[3]), str(in_put[4]),
                              datetime.datetime.strptime(str(in_put[5]), '%Y-%m-%d %H:%M:%S'),
                              datetime.datetime.now(), str(in_put[6]))
        elif in_put[0] == 'ava-comments':
            database.ava_comments(str(in_put[1]), int(in_put[2]), str(in_put[3]))
        elif in_put[0] == 'block-user':
            database.block_user(str(in_put[1]))
        elif in_put[0] == 'follow-user':
            database.follow_user(str(in_put[1]))
        elif in_put[0] == 'get-ava-comments':
            database.get_ava_comments(int(in_put[1]), str(in_put[2]))
        elif in_put[0] == 'get-login-user':
            database.get_login_user()
        elif in_put[0] == 'get-the-activity-of-the-followers':
            database.get_the_activity_of_the_followers()
        elif in_put[0] == 'get-user-activity':
            database.get_user_activity(str(in_put[1]))
        elif in_put[0] == 'like-ava':
            database.like_ava(int(in_put[1]), str(in_put[2]))
        elif in_put[0] == 'list-message-senders':
            database.list_message_senders()
        elif in_put[0] == 'receive-Ava':
            database.receive_ava()
        elif in_put[0] == 'receive-ava_of-a-special-symbol':
            database.receive_ava_of_a_special_symbol(str(in_put[1]))
        elif in_put[0] == 'receive-count-of-Like':
            database.receive_count_of_like(int(in_put[1]), str(in_put[2]))
        elif in_put[0] == 'receive-list-message-of-user':
            database.receive_list_message_of_user()
        elif in_put[0] == 'receive-list-of-Like':
            database.receive_list_of_like(int(in_put[1]), str(in_put[2]))
        elif in_put[0] == 'receive-popular-ava':
            database.receive_popular_ava()
        elif in_put[0] == 'send-ava':
            database.send_ava(str(in_put[1]), int(in_put[2]), datetime.datetime.now())
        elif in_put[0] == 'send-message':
            database.send_message(str(in_put[1]), str(in_put[2]), datetime.datetime.now())
        elif in_put[0] == 'stop-block':
            database.stop_block(str(in_put[1]))
        elif in_put[0] == 'stop-following':
            database.stop_following(str(in_put[1]))
        elif in_put[0] == 'help':
            print('user_log(user_name, password, login)')
            print('add_ava(ava_content, post_datetime)')
            print('add_hashtag(text)')
            print('add_hashtag_to_ava(ava_id, text)')
            print('add_user(first_name, last_name, user_name, password, birthday, register_day, biography)')
            print('ava_comments(receiver_user_name, receiver_ava_id, content)')
            print('block_user(blocked_user_name)')
            print('check_login()')
            print('follow_user(followed_user_name)')
            print('get_ava_comments(select_ava_id, select_user_id)')
            print('get_login_user()')
            print('get_the_activity_of_the_followers()')
            print('get_user_activity(blocked_user_name)')
            print('like_ava(ava_id, ava_user_name)')
            print('list_message_senders()')
            print('receive_Ava()')
            print('receive_ava_of_a_special_symbol(TEXT)')
            print('receive_count_of_Like(select_ava_id, select_user_name)')
            print('receive_list_message_of_user()')
            print('receive_list_of_Like(select_ava_id, select_user_name)')
            print('receive_popular_ava()')
            print('send_ava(receiver_user_name, ava_id, post_datetime)')
            print('send_message(receiver_user_name, mes_content, post_datetime)')
            print('stop_block(blocked_user_name)')
            print('stop_following(followed_user_name)')
        else:
            print('command not found')
