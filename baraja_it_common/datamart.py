import os
import logging
import sys

_logger = logging.getLogger(__name__)

class DataMartConnector:

    def __init__(self):
        self.ctx = None

    def _get_config(self, config_section=None):
        pass

    def test_connection(self):
        pass


    def upload(self, localpath, remotepath):
        pass


