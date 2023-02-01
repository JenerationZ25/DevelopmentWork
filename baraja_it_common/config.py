__all__ = [
    'config', 'load_config'
]

import os
import yaml
import pkg_resources

config = {}

def load_config(config_path=None, config_name=None):
    global config

    if config_name is None and config_path is None:
        config_name = os.environ.get('CONFIG')

    if config_name is not None:
        config_path = pkg_resources.resource_file('baraja_it_common', f'config/{config_name}.yaml')
        if 'CONFIG_PATH' not in os.environ:
            os.environ['CONFIG_PATH'] = config_path

    if config_path is None:
        config_path = os.environ.get('CONFIG_PATH')

    if config_path is None:
        current_dir = os.path.dirname(os.path.realpath(__file__))
        default_settings = os.path.join(current_dir, 'config', 'data_mart_settings.yaml')
        check_path = [
            default_settings,
        ]
        for p in check_path:
            if os.path.exists(os.path.expanduser(p)):
                config_path = p
                break
    if config_path is None:
        raise RuntimeError('specify configuration name or path')

    config_path = os.path.expanduser(config_path)
    if not os.path.exists(config_path):
        raise RuntimeError(f"configuration file '{config_path}' does not exist")

    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)

load_config()