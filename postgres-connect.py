"""Import the local mortgage CSV into a new PostgreSQL table."""

import csv
import os
from datetime import datetime
from decimal import Decimal
from pathlib import Path

import psycopg
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / 'data' / 'raw' / 'mortgage_default_data.csv'
HEADERS = ['', 'income', 'loan_amount', 'term_length', 'install_to_inc',
           'occup', 'marital', 'schufa', 'num_applic', 'OBS_DATE', 'target_var']


def convert(value, column):
    if value.strip() in ('', 'Not avail.'):
        return None
    if column == 'OBS_DATE':
        return datetime.strptime(value, '%d%b%Y - %H:%M:%S')
    if column in ('occup', 'marital'):
        return value
    number = Decimal(value)
    if not number.is_finite():
        raise ValueError('Non-finite numeric value')
    if column in ('', 'term_length', 'num_applic', 'target_var'):
        if number != number.to_integral_value():
            raise ValueError(f'Expected an integer for {column}')
        return int(number)
    return number


def main():
    load_dotenv(ROOT / '.env')
    settings = {key: os.environ.get('PG' + key.upper())
                for key in ('host', 'port', 'dbname', 'user', 'password')}
    settings['dbname'] = os.environ.get('PGDATABASE')
    if not all(settings.values()):
        raise ValueError('Fill in PGHOST, PGPORT, PGDATABASE, PGUSER, and PGPASSWORD in .env')

    # Validate every row before changing the database.
    with CSV_PATH.open(newline='', encoding='utf-8-sig') as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != HEADERS:
            raise ValueError('CSV headers do not match the expected mortgage dataset')
        rows = []
        for line, row in enumerate(reader, start=2):
            try:
                rows.append(tuple(convert(row[column], column) for column in HEADERS))
            except (ValueError, TypeError, ArithmeticError) as exc:
                raise ValueError(f'Invalid CSV value on line {line}') from exc

    # The transaction rolls back on failure; an existing table is never replaced.
    with psycopg.connect(**settings, connect_timeout=10) as connection:
        with connection.cursor() as cursor:
            cursor.execute('''
                CREATE TABLE public.mortgage_default (
                    source_row_id BIGINT PRIMARY KEY,
                    income NUMERIC,
                    loan_amount NUMERIC,
                    term_length INTEGER,
                    install_to_inc NUMERIC,
                    occup TEXT,
                    marital TEXT,
                    schufa NUMERIC,
                    num_applic INTEGER,
                    obs_date TIMESTAMP,
                    target_var SMALLINT CHECK (target_var IN (0, 1))
                )
            ''')
            with cursor.copy('COPY public.mortgage_default FROM STDIN') as copy:
                for row in rows:
                    copy.write_row(row)
            cursor.execute('SELECT COUNT(*) FROM public.mortgage_default')
            count = cursor.fetchone()[0]
            if count != len(rows):
                raise RuntimeError('Imported row count does not match CSV')
    print(f'Imported and verified {count:,} rows in public.mortgage_default.')


if __name__ == '__main__':
    main()
