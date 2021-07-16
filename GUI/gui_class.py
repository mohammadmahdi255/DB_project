import datetime
import tkinter
from tkinter import *
from tkinter import font, messagebox

from DB_command_controller import DBHelper
from terminal import fix_input

login_user_name = ''
login_password = ''
last_call_method = ''

dict_args = {
    'add_ava': [['ava_content', 'post_datetime'], ['str', 'datetime.datetime.strptime']],
    'add_hashtag': [['text'], ['str']],
    'add_hashtag_to_ava': [['ava_id', 'text'], ['int', 'str']],
    'ava_comments': [['receiver_user_name', 'receiver_ava_id', 'content'], ['str', 'int', 'str']],
    'block_user': [['blocked_user_name'], ['str']],
    'check_login': [[], []],
    'follow_user': [['followed_user_name'], ['str']],
    'get_ava_comments': [['select_ava_id', 'select_user_id'], ['int', 'int']],
    'get_login_user': [[], []],
    'get_the_activity_of_the_followers': [[], []],
    'get_user_activity': [['blocked_user_name'], ['str']],
    'like_ava': [['ava_id', 'ava_user_name'], ['int', 'str']],
    'list_message_senders': [[], []],
    'receive_ava': [[], []],
    'receive_ava_of_a_special_symbol': [['text'], ['str']],
    'receive_count_of_like': [['select_ava_id', 'select_user_name'], ['int', 'str']],
    'receive_list_message_of_user': [[], []],
    'receive_list_of_like': [['select_ava_id', 'select_user_name'], ['int', 'str']],
    'receive_popular_ava': [[], []],
    'send_ava': [['receiver_user_name', 'ava_id', 'post_datetime'], ['str', 'int', 'datetime.datetime.strptime']],
    'send_message': [['receiver_user_name', 'mes_content', 'post_datetime'],
                     ['str', 'str', 'datetime.datetime.strptime']],
    'stop_block': [['blocked_user_name'], ['str']],
    'stop_following': [['followed_user_name'], ['str']],
}


def center_window(root, width=300, height=200):
    # get screen width and height
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()

    # calculate position x and y coordinates
    x = (screen_width / 2) - (width / 2)
    y = (screen_height / 2) - (height / 2)
    root.geometry('%dx%d+%d+%d' % (width, height, x, y))
    root.resizable(0, 0)


class loginPage:

    def __init__(self, database: DBHelper):
        self.__database = database
        self.__root = Tk()
        self.__root.title('db connector graphic interface')
        self.__frame_entry = tkinter.Frame(self.__root, bg='#A6A9D2')
        self.__frame_button = tkinter.Frame(self.__root, bg='#A6A9D2')
        title_font = font.Font(family="Comic Sans MS",
                               size=20,
                               weight="bold")
        label_font = font.Font(family="Comic Sans MS",
                               size=12,
                               weight="normal")
        self.__label_list = [Label(self.__frame_entry, text='User Name:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame_entry, text='Password:', font=label_font, bg='#A6A9D2'),
                             Label(self.__root, text='Welcome!\n to Mysql Connector\n Graphic Interface',
                                   font=title_font, bg='#A6A9D2')]
        self.__entry_list = [Entry(self.__frame_entry, font=label_font, width=30),
                             Entry(self.__frame_entry, font=label_font, width=30)]
        self.__button_list = [Button(self.__frame_button, font=label_font, text='Quit', padx=90, command=self.__quit),
                              Button(self.__frame_button, font=label_font, text='Login', padx=30, command=self.__login),
                              Button(self.__frame_button, font=label_font, text='Sign', padx=30, command=self.__sign)]

        self.__root.protocol("WM_DELETE_WINDOW", self.__quit)
        self.__set_layout()
        self.__run_gui()

    def __set_layout(self):
        center_window(self.__root, 500, 500)
        self.__root.config(bg='#A6A9D2')

        self.__label_list[2].place(relx=0.5, rely=0.15, anchor=CENTER)
        self.__frame_entry.place(relx=.5, rely=.4, anchor=CENTER)
        self.__frame_button.place(relx=.6, rely=.6, anchor=CENTER)

        self.__label_list[0].grid(row=0, column=0, padx=5, pady=5)
        self.__label_list[1].grid(row=1, column=0, padx=5, pady=5)

        self.__entry_list[0].grid(row=0, column=1, padx=5, pady=5)
        self.__entry_list[1].grid(row=1, column=1, padx=5, pady=5)

        self.__button_list[0].pack(padx=5, pady=5, side=tkinter.BOTTOM, anchor=CENTER)
        self.__button_list[1].pack(padx=5, pady=5, side=tkinter.LEFT, anchor=CENTER)
        self.__button_list[2].pack(padx=5, pady=5, side=tkinter.RIGHT, anchor=CENTER)

    def __run_gui(self):
        self.__root.mainloop()

    def __quit(self):
        if messagebox.askokcancel("Quit", "Do you want to quit?"):
            self.__root.destroy()
            self.__root.quit()

    def __login(self):
        list_entry = [i.get() for i in self.__entry_list]
        list_entry = fix_input(list_entry)
        global login_password, login_user_name
        log_message = self.__database.user_log(list_entry[0], list_entry[1], login=1)
        print(log_message)

        if log_message[3] is None:
            _logShow("message: User can not be None")
        elif 'FAILED' in log_message[3]:
            _logShow("message: User {}".format(log_message[3]))
        else:
            login_user_name = list_entry[0]
            login_password = list_entry[1]
            self.__root.destroy()
            _mainPanel(self.__database)
            self.__init__(self.__database)

    def __sign(self):
        self.__root.destroy()
        _signup(self.__database)
        self.__init__(self.__database)


class _signup:

    def __init__(self, database: DBHelper):
        self.__database = database
        self.__root = Tk()
        self.__frame = tkinter.Frame(self.__root, bg='#A6A9D2')
        self.__frame_button = tkinter.Frame(self.__root, bg='#A6A9D2')
        label_font = font.Font(family="Comic Sans MS",
                               size=12,
                               weight="normal")
        self.__label_list = [Label(self.__frame, text='First Name:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame, text='Last Name:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame, text='User Name:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame, text='Password:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame, text='birthday:', font=label_font, bg='#A6A9D2'),
                             Label(self.__frame, text='biography:', font=label_font, bg='#A6A9D2'),
                             Label(self.__root, text='', font=label_font, bg='#A6A9D2', wraplength=400)]
        self.__entry_list = [Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30)]
        self.__button_list = [Button(self.__frame_button, text='Quit', padx=50, command=self.__quit),
                              Button(self.__frame_button, text='Add', padx=50, command=self.__add)]

        self.__root.protocol("WM_DELETE_WINDOW", self.__quit)
        self.__set_layout()
        self.__run_gui()

    def __set_layout(self):
        center_window(self.__root, 500, 500)
        self.__root.config(bg='#A6A9D2')

        self.__label_list[6].place(relx=.5, rely=.1, anchor=CENTER)
        self.__frame.place(relx=.5, rely=.4, anchor=CENTER)
        self.__frame_button.place(relx=.5, rely=.8, anchor=CENTER)

        for i in range(len(self.__entry_list)):
            self.__label_list[i].grid(row=i, column=0, padx=5, pady=5)
            self.__entry_list[i].grid(row=i, column=1, padx=5, pady=5)

        self.__button_list[0].pack(padx=5, pady=5, side=LEFT)
        self.__button_list[1].pack(padx=5, pady=5, side=LEFT)

    def __run_gui(self):
        self.__root.mainloop()

    def __quit(self):
        self.__root.destroy()
        self.__root.quit()

    def __add(self):
        list_entry = [i.get() for i in self.__entry_list]
        list_entry = fix_input(list_entry)
        log_message = self.__database.add_user(list_entry[0], list_entry[1], list_entry[2], list_entry[3],
                                               datetime.datetime.strptime(list_entry[4], '%Y-%m-%d %H:%M:%S')
                                               if list_entry[4] is not None
                                               else None,
                                               datetime.datetime.now(), list_entry[5])
        self.__label_list[6].config(text=' '.join(log_message))
        print(log_message)


class _mainPanel:

    def __init__(self, database: DBHelper):
        self.__database = database
        self.__root = Tk()
        self.__root.title('db connector graphic interface')
        self.__frame_listbox = tkinter.Frame(self.__root, bg='#A6A9D2')
        self.__frame_button = tkinter.Frame(self.__root, bg='#A6A9D2')
        self.__frame = tkinter.Frame(self.__root, bg='#A6A9D2')
        label_font = font.Font(family="Comic Sans MS",
                               size=10,
                               weight="normal")
        self.__listbox = Listbox(self.__frame_listbox, font=label_font)
        self.__listbox.insert(END, 'add_ava')
        self.__listbox.insert(END, 'add_hashtag')
        self.__listbox.insert(END, 'add_hashtag_to_ava')
        self.__listbox.insert(END, 'ava_comments')
        self.__listbox.insert(END, 'block_user')
        self.__listbox.insert(END, 'check_login')
        self.__listbox.insert(END, 'follow_user')
        self.__listbox.insert(END, 'get_ava_comments')
        self.__listbox.insert(END, 'get_login_user')
        self.__listbox.insert(END, 'get_the_activity_of_the_followers')
        self.__listbox.insert(END, 'get_user_activity')
        self.__listbox.insert(END, 'like_ava')
        self.__listbox.insert(END, 'list_message_senders')
        self.__listbox.insert(END, 'receive_ava')
        self.__listbox.insert(END, 'receive_ava_of_a_special_symbol')
        self.__listbox.insert(END, 'receive_count_of_like')
        self.__listbox.insert(END, 'receive_list_message_of_user')
        self.__listbox.insert(END, 'receive_list_of_like')
        self.__listbox.insert(END, 'receive_popular_ava')
        self.__listbox.insert(END, 'send_ava')
        self.__listbox.insert(END, 'send_message')
        self.__listbox.insert(END, 'stop_block')
        self.__listbox.insert(END, 'stop_following')

        self.__entry_list = [Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30),
                             Entry(self.__frame, font=label_font, width=30)]

        self.__label_list = [Label(self.__frame, font=label_font, bg='#A6A9D2', width=15),
                             Label(self.__frame, font=label_font, bg='#A6A9D2', width=15),
                             Label(self.__frame, font=label_font, bg='#A6A9D2', width=15)]

        self.__listbox.bind('<<ListboxSelect>>', self.__update)

        self.__button_list = [Button(self.__frame_button, font=label_font, text='Quit', padx=30, command=self.__quit),
                              Button(self.__frame_button, font=label_font, text='Result', padx=30,
                                     command=self.__result)]

        self.__root.protocol("WM_DELETE_WINDOW", self.__quit)
        self.__set_layout()
        self.__run_gui()

    def __set_layout(self):
        center_window(self.__root, 500, 700)
        self.__root.config(bg='#A6A9D2')

        self.__frame_listbox.pack(padx=10, pady=10, side=TOP, anchor=CENTER)
        self.__frame.pack(padx=10, pady=10, side=TOP, anchor=CENTER)
        self.__frame_button.pack(padx=10, pady=10, side=TOP, anchor=CENTER)

        self.__listbox.pack(ipadx=40, ipady=120)

        self.__button_list[0].pack(padx=5, pady=5, side=tkinter.LEFT, anchor=CENTER)
        self.__button_list[1].pack(padx=5, pady=5, side=tkinter.LEFT, anchor=CENTER)

        for i in range(len(self.__entry_list)):
            self.__label_list[i].grid(row=i, column=0, padx=5, pady=5)
            self.__entry_list[i].grid(row=i, column=1, padx=5, pady=5)

    def __run_gui(self):
        self.__root.mainloop()

    def __quit(self):
        self.__root.destroy()
        log_message = self.__database.user_log(login_user_name, login_password, login=0)
        _logShow(log_message)
        self.__root.quit()

    def __update(self, event):
        global dict_args, last_call_method
        selection = event.widget.curselection()
        if selection:
            last_call_method = self.__listbox.get(selection[0])
            for index in range(len(self.__entry_list)):
                if index < len(dict_args.get(last_call_method)[0]):
                    self.__label_list[index].config(text=dict_args.get(last_call_method)[0][index])
                    self.__entry_list[index].config(state=NORMAL)
                else:
                    self.__label_list[index].config(text='')
                    self.__entry_list[index].config(state=DISABLED)

    def __result(self):
        global dict_args, last_call_method
        args = []
        for index in range(len(dict_args.get(last_call_method)[1])):
            args.append(eval(dict_args.get(last_call_method)[1][index] + '(arg)',
                             {'arg': self.__entry_list[index].get()}))

        args = tuple(args)
        db_method = getattr(self.__database, last_call_method)
        log_message = db_method(*args)
        print(log_message)
        _logShow(log_message)


class _logShow:

    def __init__(self, message: str):
        self.__root = Tk()
        self.__root.title('db connector graphic interface')
        self.__frame_button = tkinter.Frame(self.__root, bg='#A6A9D2')
        self.__frame = tkinter.Frame(self.__root, bg='#A6A9D2')
        label_font = font.Font(family="Comic Sans MS",
                               size=10,
                               weight="normal")

        self.__label_list = [Label(self.__frame, font=label_font, text=message, bg='#A6A9D2', wraplength=300)]

        self.__button_list = [Button(self.__frame_button, font=label_font, text='Ok', padx=30, command=self.__quit)]

        self.__root.protocol("WM_DELETE_WINDOW", self.__quit)
        self.__set_layout()
        self.__run_gui()

    def __set_layout(self):
        center_window(self.__root, 400, 300)
        self.__root.config(bg='#A6A9D2')

        self.__frame.pack(padx=10, pady=10, side=TOP, anchor=CENTER)
        self.__frame_button.pack(padx=10, pady=10, side=TOP, anchor=CENTER)

        self.__button_list[0].pack(padx=5, pady=5, side=TOP, anchor=CENTER)
        self.__label_list[0].pack(padx=5, pady=5, side=TOP, anchor=CENTER)

    def __run_gui(self):
        self.__root.mainloop()

    def __quit(self):
        self.__root.destroy()
        self.__root.quit()
