from __future__ import print_function

import re
import os
import random
import vim
import sqlite3
from collections import namedtuple


Fact = namedtuple('Fact', ['path', 'name', 'body', 'efactor', 'interval', 'count'])
FactRow = namedtuple('FactRow', ['filename', 'fact_name', 'first_seen', 
    'last_scored', 'interval', 'efactor'])


def vim_srs_initialize():
    pass


def get_all_fact_files(locations):
    fact_files = []
    fact_extensions = vim.eval("g:srs_filetypes")

    for location in locations:
        if not os.path.exists(location):
            continue

        if os.path.isfile(location):
            fact_files.append(location)

        if os.path.isdir(location):
            files_in_dir = os.listdir(location)
            for f in files_in_dir:
                if os.path.isdir(f):
                    continue

                (_, ext) = os.path.splitext(f)
                if ext in fact_extensions:
                    fact_files.append(os.path.join(location, f))

    return fact_files


def ensure_database_initialized(conn):
    c = conn.cursor()
    c.execute('''CREATE TABLE facts
             (filename text, fact_name text, first_seen timestamp, 
             last_scored timestamp, efactor real, interval integer, count integer)''')
    conn.commit()

def calculate_interval(fact):
    if fact.efactor < 3:
        fact = fact._replace(count=1)
    interval = 1
    if fact.count == 2:
        interval = 6
    elif fact.count > 2:
        interval = round(fact.interval * fact.efactor)
    return fact._replace(interval=interval)


# map of directorys to connections
connections = {}
def update_facts_from_db(facts):
    new_facts = []

    for fact in facts:
        fact_dir = os.path.dirname(fact.path)
        fact_filename = os.path.basename(fact.path)
        conn = connections.get(fact_dir)
        if conn is None:
            db_path = os.path.join(fact_dir, '.srs.db')
            if not os.path.exists(db_path):
                conn = sqlite3.connect(db_path, detect_types=1)
                ensure_database_initialized(conn)
            else:
                conn = sqlite3.connect(db_path, detect_types=1)
            connections[fact_dir] = conn

        c = conn.cursor()
        c.execute("select efactor, interval, count from facts where filename=:filename", {"filename": fact_filename})
        row = c.fetchone()

        if row is None:
            new_fact = fact._replace(efactor=2.5, count=1)
        else:
            new_fact = fact._replace(efactor=row[0], interval=row[1], count=row[2])

        new_fact = calculate_interval(new_fact)
        new_facts.append( new_fact )
        #TODO: calculate which facts are due
    return new_facts


def load_facts_from_files(files):
    facts = []
    current_fact = None
    fact_marker = vim.eval("g:srs_fact_marker")
    fact_re = re.compile(r"\s*" + fact_marker + r"\s*(?P<fact_name>.*)", re.MULTILINE)

    for fact_filename in files:
        with open(fact_filename, 'r') as f:
            fact_file = f.read()
            
        for line in fact_file.splitlines():
            match = fact_re.match(line)
            if match:
                current_fact_name = match.group("fact_name")
                if current_fact:
                    fact = Fact(path=fact_filename, name=current_fact_name, body="\n".join(current_fact), efactor=None, interval=None, count=None)
                    facts.append(fact)
                current_fact = [line]
            elif current_fact is not None:
                current_fact.append(line)
        if current_fact:
            fact = Fact(path=fact_filename, name=current_fact_name, body="\n".join(current_fact), efactor=None, interval=None, count=None)
            facts.append(fact)

    facts = update_facts_from_db(facts)
    return facts


def vim_srs_begin():
    locations = vim.eval("locations")
    fact_files = get_all_fact_files(locations)
    facts = load_facts_from_files(fact_files)
    random.shuffle(facts)
    return facts


def vim_srs_answer():
    quality = vim.eval("quality")
    current_fact_index = vim.eval("s:current_fact_index")
    current_facts = vim.eval("s:current_facts")
    new_facts = []

    #TODO update fact in db, remove from or add to end of list depending on answer
    return current_facts[1:]
