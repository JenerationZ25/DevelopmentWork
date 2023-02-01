from .datamart import DataMartConnector
from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.user_credential import UserCredential
from office365.sharepoint.files.file import File
import os
import logging
from .config import config
import sys

_logger = logging.getLogger(__name__)

class SharePointConnector(DataMartConnector):

    def __init__(self):
        sp_config = self._get_config()
        credentials = UserCredential(sp_config['user_name'], sp_config['user_password'])
        self.ctx = ClientContext(sp_config['base_url'] + sp_config['site_relative_url']).with_credentials(credentials)

    def _get_config(self, config_section='it-technology'):
        cfg = config[config_section]
        return {
            'base_url': cfg.get('base_url'),
            'site_relative_url': cfg.get('site_relative_url'),
            'user_name': cfg.get('user_name'),
            'user_password': cfg.get('user_password'),
        }

    def test_connection(self):
        ##  Test connection
        web = self.ctx.web.get().execute_query()
        _logger.info("Web properties: {0}".format(web.properties))


    def upload(self, local_file_path, remote_sp_dir, filename):
        with open(local_file_path, 'rb') as content_file:
            _logger.info("local file path is: {0}".format(local_file_path))
            _logger.info("target remote sp dir is: {0}".format(remote_sp_dir))
            file_content = content_file.read()
            file = self.ctx.web.get_folder_by_server_relative_url(remote_sp_dir).upload_file(filename, file_content).execute_query()


