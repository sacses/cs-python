import sqlite3
from sqlite3 import Error


def connection(db_file):
    """ create a database connection to the SQLite database specified
    by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)

    return conn


def get_top_n_acquirers(conn, n):
    """
    Selects most successful acquirer channels
    :param conn: connection object
    :param n: number of elements in ranking, descending
    :return:
    """
    cur = conn.cursor()
    cur.execute(
        f"""SELECT user_channel AS channel,
        count(user_id) AS number_users
        FROM taxfix
        GROUP BY user_channel
        ORDER BY number_users DESC 
        LIMIT {n}"""
    )

    rows = cur.fetchall()

    for i, j in enumerate(rows):
        print(f"'{j[0]}' is the {i+1} channel with {j[1]} users acquired")

    return None


def get_avg_submission_time(conn):
    """
    Selects and prints the average time a user takes to submit their tax
    declaration since they registered
    :param conn: connection object
    :return: integer of number of average days
    """
    cur = conn.cursor()
    cur.execute(
        f"""with dates as 
        (
        select
        user_id,
        datetime(substr(submission_date, 7, 4) || '-' || substr(submission_date, 4, 2) || '-' || substr(submission_date, 1, 2) || ' ' || substr(submission_date, 12, 2) || ':' || substr(submission_date, 15, 2) || ':' || substr(submission_date, 18, 2)) as sub_date,
        datetime(substr(registration_date , 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date , 1, 2) || ' ' || substr(registration_date, 12, 2) || ':' || substr(registration_date, 15, 2) || ':' || substr(registration_date, 18, 2)) as reg_date
        from taxfix
        where submission_date is not null
        )
        select 
        round(avg(STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date)) / 60 / 24) as avg_time
        from dates"""
    )

    row = cur.fetchall()
    days = int(row[0][0])

    print(
        f"Average time a user took to complete their tax submission "
        f"since they've registered was {days} days"
    )

    return days


def get_submission_time_user(conn):
    """
    Provides list user, submission and registration dates, and difference
    :param conn: connection object
    :return:list
    """

    cur = conn.cursor()
    cur.execute(
        f"""with dates as 
        (
        select
        user_id,
        datetime(substr(submission_date, 7, 4) || '-' || substr(submission_date, 4, 2) || '-' || substr(submission_date, 1, 2) || ' ' || substr(submission_date, 12, 2) || ':' || substr(submission_date, 15, 2) || ':' || substr(submission_date, 18, 2)) as sub_date,
        datetime(substr(registration_date , 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date , 1, 2) || ' ' || substr(registration_date, 12, 2) || ':' || substr(registration_date, 15, 2) || ':' || substr(registration_date, 18, 2)) as reg_date
        from taxfix
        where submission_date is not null
        )
        select 
        user_id,
        sub_date,
        reg_date,
        round((STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date))*1.0 / 60 / 24) as difference
        from dates
        order by difference DESC"""
    )

    rows = cur.fetchall()

    return rows


def get_raw_table(conn):
    """
    Selects number of registered users, submissions and their relation
    by registration date
    :param conn:connection object
    :return: list of tuples
    """
    cur = conn.cursor()
    cur.execute(
        f"""SELECT * FROM taxfix"""
    )

    rows = cur.fetchall()

    return rows


def acquire_wrangle():
    """

    :return:
    """
    conn = connection('data/input/chinook.db')
    print(
        "What is the most common channel for acquiring users? "
        "What is the second most common channel for acquiring users?"
    )
    get_top_n_acquirers(conn, 2)

    print(
        ""
        "How much time does it usually take for a user from their registration"
        " to submit their tax declaration?"
    )
    avg_time = get_avg_submission_time(conn)

    user_timings = get_submission_time_user(conn)
    raw_table = get_raw_table(conn)

    return avg_time, user_timings, raw_table






