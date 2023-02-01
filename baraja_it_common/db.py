__all__ = [
    'DWHConnection', 'close_connections'
]

import os
from datetime import datetime,date

import pandas as pd
import psycopg2

import logging
from .config import config

_logger = logging.getLogger(__name__)

class DWHConnection:

    pg_conn = None

    def __init__(self):
        self.close_on_exit = not self.is_open()
        self._connect()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.is_open():
            if self.close_on_exit:
                self.close()

    @classmethod
    def _get_config(cls):
        cfg = config['odoo-13-read-replica']
        return {
            'host': cfg.get('host'),
            'port': cfg.get('port', '5432'),
            'dbname': cfg.get('database', '----'),
            'user': cfg.get('user'),
            'password': cfg.get('password'),
        }

    @classmethod
    def is_open(cls):
        return cls.pg_conn is not None and cls.pg_conn.closed == 0

    @classmethod
    def connect(cls):
        return cls()

    @classmethod
    def _connect(cls):
        if not cls.is_open():
            cls.pg_conn = psycopg2.connect(**cls._get_config())

    @classmethod
    def close(cls):
        try:
            cls.pg_conn.close()
            cls.pg_conn = None
        except:
            pass

    @classmethod
    def fetch(cls, sql, vars=None, params=None, **kwargs):
        vars = vars or params
        close = not cls.is_open
        cls._connect()
        try:
            with cls.pg_conn as pg_conn:
                df = pd.read_sql(sql, con=pg_conn, params=vars, **kwargs)
        finally:
            if close:
                cls.close()
        return df
