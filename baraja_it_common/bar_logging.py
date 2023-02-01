from .path_handler import PathHandler
import os
import logging
import logging.config
_logger = logging.getLogger(__name__)

class BarLogging:
    def __init__(self):
        self.path_handler = PathHandler()
        self.current_dir = os.path.dirname(os.path.realpath(__file__))

    def set_bar_logging(self, script_dir, logfile_relatvie_path):
        '''
        Setup logging using logging config file in config/logging.ini
        Saved log output file with given relate path,
            e.g. 'Logs/odooetl.log', log file will saved in the relave path of the script calling this function
        :param script_dir:
                    absolute directory path of the script calling this customized logging,
                    e.g. c:\baraja\baraja_it_script\baraja_it_script\pipeline\Test
                    it will create a Log folder under this path
                    e.g. c:\baraja\baraja_it_script\baraja_it_script\pipeline\Test\Logs
        :param logfile_relatvie_path:
                    relative logfile path
                    e.g. given Logs/test.log
                    it will saved in e.g. c:\baraja\baraja_it_script\baraja_it_script\pipeline\Test\Logs\test.log
                    e.g. given test.log
                    it will saved in e.g. c:\baraja\baraja_it_script\baraja_it_script\pipeline\Test\test.log
        '''
        logging_config_file_path = self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'config'), 'logging.ini')
        self.path_handler.create_folder(script_dir, 'Logs')
        logging.config.fileConfig(logging_config_file_path,
                                  defaults={'logFileName': logfile_relatvie_path},
                                  disable_existing_loggers=False)
