c = get_config()

import os

# === Основные параметры ===
c.JupyterHub.ip = os.getenv('JUPYTERHUB_IP', '0.0.0.0')
c.JupyterHub.port = int(os.getenv('JUPYTERHUB_PORT', 8000))
c.JupyterHub.data_files_path = os.getenv('JUPYTERHUB_DATA_PATH', '/opt/jupyterhub_data')

# === Простая аутентификация ===
c.JupyterHub.authenticator_class = 'jupyterhub_nativeauthenticator.NativeAuthenticator'

# Разрешаем регистрацию (только один раз для трёх пользователей)
c.NativeAuthenticator.open_signup = True
c.NativeAuthenticator.check_common_password = True
c.NativeAuthenticator.minimum_password_length = 8

# === Спавнер обычного процесса ===
c.JupyterHub.spawner_class = 'simple'

# === Каталог для ноутбуков ===
notebooks_dir = os.getenv('NOTEBOOKS_PATH', '/opt/notebooks')
c.Spawner.notebook_dir = notebooks_dir
c.Spawner.default_url = '/lab'
c.Spawner.args = ['--NotebookApp.token=']

# === Логи ===
c.JupyterHub.log_level = 'INFO'

# === Дополнительные параметры ===
c.JupyterHub.admin_users = set()
c.JupyterHub.allow_named_servers = False
c.JupyterHub.shutdown_on_logout = True