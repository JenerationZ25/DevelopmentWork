# Set up for using baraja_it_common package
## Step1: Download this package to local
    cd c:\baraja
    git clone ....
## Step 2: Set up config file path for baraja_it_common package
### For Windows:
- Add a key-value in Environment **System Variables**
    - Variable name: CONFIG_PATH 
    - Variable value: C:\baraja\baraja_it_common\baraja_it_common\config\data_mart_settings.yaml
## Step 3: Install this package in local
    cd c:\baraja
    pip install -e baraja_it_common

## Notice:
- in baraja_it_common/config/data_mart_settings.yaml
  odoo db connection point to odoo-13-prd-read-replica
  sharepoint connection point to baraja.sharepoint.com/sites/it