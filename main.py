from mysql.connector import connect, Error
import PySimpleGUI as pys

layout = [[pys.Text("Hello from PySimpleGUI")], [pys.Button("OK")]]
pys.Window(title="Hello World", layout=layout, margins=(400, 400), resizable=True).read()

try:

    with connect(
            host="localhost",
            user="root",
            password="",
            database="db_project"
    ) as connection:
        print(connection)
        with connection.cursor() as cursor:
            cursor.execute("""select * from USER_DATA;""")
            for row in cursor:
                print(row)

except Error as e:
    print(e)
