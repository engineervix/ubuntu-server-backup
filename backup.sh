#!/usr/bin/env bash

# =================================================================================================
# description:  backups up *important stuff* on an Ubuntu server (tested on 20.04)
# author:       Victor Miti <https://github.com/engineervix>
# url:          <https://github.com/engineervix/ubuntu-server-backup>
# version:      0.2.0
# license:      MIT
#
# What's this *important stuff*?
# ------------------------------ 
# This script was written primarily to backup databases, files,
# configurations, etc. pertaining to *web applications* running on
# the server. These applications are typically Python projects
# (Django, Flask, etc.), and the server setup is based on
# <https://github.com/engineervix/ubuntu-server-setup>
# 
# Usage
# ------
# - while you can run this script manually, you probably wanna run it via cron, as root
#   e.g. to run it at 3:18AM everyday, in your crontab: `18 3 * * * /path/to/backup.sh`
# - there should be a `config.toml` file in the same directory as the script, start from there
#   and update the (self-explanatory) configuration values to suit your needs
# 
# Dependencies
# -------------
# - [jq](https://stedolan.github.io/jq/) --> `apt install jq`
# - [yq](https://kislyuk.github.io/yq/)  --> `pip3 install yq`
# - [rclone](https://rclone.org/)        --> `apt install rclone`
# - ...
# - wait a minute, this list is quite long! As I already mentioned, the server setup is
#   based on <https://github.com/engineervix/ubuntu-server-setup>, so if you're backing
#   up stuff on such a server, you don't need to install anything to use the script,
#   because all these dependencies are already installed
# 
# NOTE: If your server setup is different, you can have a quick idea of the dependencies 
#       just by skimming through the script before running, and also check out the server setup docs:
#       <https://ubuntu-server-setup.readthedocs.io/en/latest/02_features.html> 
#
# TODO:
# 1. do *incremental* backups using <https://duplicity.gitlab.io/duplicity-web/index.html>
# 2. Backup any additional custom Python virtual environment configs (virtualenvwrapper)
# 3. Include other dotfiles (such as `.profile`, etc.)
# 4. add email/SMS/telegram/slack notifications on failure (actually, just use <https://healthchecks.io/>)
# 5. split each backup task into a standalone function
# 6. run automated tests
# =================================================================================================

## 0. Let's read from the configuration file & define some variables

SCRIPT_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
SCRIPT=$(basename "$0")

configfile="${SCRIPT_DIR}/config.toml"

# the tomlq binary is installed in this location
export PATH=$PATH:/usr/local/bin/

if ! command -v tomlq &> /dev/null
then
    echo "tomlq could not be found. Check by running <(sudo -H) pip3 install yq>"
    exit
fi

if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Check by running <(sudo) apt install jq>"
    exit
fi

machine=$( tomlq -r .core.machine_name "$configfile" )
user=$( tomlq -r .core.user "$configfile" )
projects_dir=$( tomlq -r .core.projects_dir "$configfile" )
backup_dir=$( tomlq -r .core.backup_dir "$configfile" )
days=$( tomlq -r .core.days "$configfile" )

files_dir=$( tomlq -r .subfolders.files "$configfile" )
db_dir=$( tomlq -r .subfolders.databases "$configfile" )
config_dir=$( tomlq -r .subfolders.settings "$configfile" )

remote=$( tomlq -r .rclone.remote "$configfile" )
extras=$( tomlq -r .extra "$configfile" | jq -c '.[]' )

timestamp=$(date '+%Y%m%d_%H%M%S')

## 01. backup the files:

mkdir -p "${backup_dir}/${files_dir}"
cd "${projects_dir}" || exit
for f in *; do
    if [ -d "${f}" ]; then
        tar --exclude='**/.git'\
            --exclude='**/node_modules'\
            --exclude='**/htmlcov'\
            --exclude='**/staticfiles'\
            --exclude='**/.cache'\
            --exclude='**/.pytest_cache'\
            --exclude='**/__pycache__'\
            --exclude='.tox'\
            --exclude='.coverage'\
            --exclude='.coverage.xml'\
            --exclude='*.pyc'\
            --exclude='*.pyo'\
            --exclude='*~'\
            -cv "$f" | xz -3e > "${backup_dir}/${files_dir}/${f}_${timestamp}".tar.xz
    else
        cp -v "$f" "${backup_dir}/${files_dir}/$f"
    fi
done

## 02. backup databases:

# --- perhaps one could alternatively use tools like https://sqlbak.com/ --- #

### PostgreSQL

mkdir -p "${backup_dir}/${db_dir}"

for db in $(sudo -u postgres psql -t -c "select datname from pg_database where not datistemplate and datname <> 'postgres' and datname <> '${user}'" | grep '\S' | awk '{$1=$1};1'); do
  error="${backup_dir}/${db_dir}/errors-backup-${db}".txt
  sudo -u postgres pg_dump "$db" | gzip > "${backup_dir}/${db_dir}/${db}_${timestamp}".sql.gz 2>"$error"
  code=$?
  if [ $code -ne 0 ]; then
      echo 1>&2 "The backup failed (exit code $code), check for errors in $error"
  fi
done

### redis
mkdir -p "${backup_dir}/${config_dir}"/dotfiles/
cp -v /etc/redis/redis.conf "${backup_dir}/${config_dir}"/dotfiles/redis.conf
rdiff-backup --preserve-numerical-ids --no-file-statistics /var/lib/redis "${backup_dir}/${db_dir}"/redis

## 03. backup settings:

### packages
mkdir -p "${backup_dir}/${config_dir}"/packages/
apt-clone clone --with-dpkg-repack "${backup_dir}/${config_dir}"/packages/
snap list > "${backup_dir}/${config_dir}"/packages/snap_list.txt
pip3 freeze > "${backup_dir}/${config_dir}"/packages/system_Py3_installed_packages.txt
npm list -g --depth 0 > "${backup_dir}/${config_dir}"/packages/npm_global_installed_packages.txt

### Python Virtual Environments
mkdir -p "${backup_dir}/${config_dir}"/venv/

export WORKON_HOME=/home/"${user}"/Env
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
# shellcheck source=/dev/null
source /usr/local/bin/virtualenvwrapper.sh

lsvirtualenv > "${backup_dir}/${config_dir}"/venv/venv_list.txt

grep "^[^=\ ]" < "${backup_dir}/${config_dir}"/venv/venv_list.txt | while IFS= read -r venv
do
  # workon "${venv}"
  pybinary=/home/"${user}"/Env/"${venv}"/bin/python
  pyversion=$("${pybinary}" --version | awk '{print $1$2}' | sed 's/\.//g')
  # pyversion=$(echo -e "import sys\nprint('Python'+str(sys.version_info.major)+str(sys.version_info.minor)+str(sys.version_info.micro))" | python)
  "${pybinary}" -m pip freeze > "${backup_dir}/${config_dir}/venv/requirements_${venv}_${pyversion}".txt
  # deactivate
done

### Celery
if [ -z "$(ls -A /etc/conf.d/)" ]; then
   echo "Looks like there's no celery project on this machine"
else
    mkdir -p "${backup_dir}/${config_dir}"/celery/{conf.d,systemd}
    cp -v /etc/conf.d/* "${backup_dir}/${config_dir}/celery/conf.d/"
    cp -v /etc/systemd/system/celery* "${backup_dir}/${config_dir}/celery/systemd/"
fi

### dotfiles
cp -v /home/"${user}"/.bashrc "${backup_dir}/${config_dir}"/dotfiles/_bashrc
cp -v /home/"${user}"/.zshrc "${backup_dir}/${config_dir}"/dotfiles/_zshrc
cp -v /home/"${user}"/.vimrc.after "${backup_dir}/${config_dir}"/dotfiles/_vimrc.after

### crontabs
crontab -l > "${backup_dir}/${config_dir}"/dotfiles/root_crontab.backup
sudo -i -u "${user}" -H bash -c crontab -l | sudo tee "${backup_dir}/${config_dir}/dotfiles/${user}_crontab.backup"

### postfix config
cp -v /etc/postfix/main.cf "${backup_dir}/${config_dir}"/dotfiles/main.cf
cp -v /etc/postfix/sasl_passwd "${backup_dir}/${config_dir}"/dotfiles/sasl_passwd

### fail2ban
cp -v /etc/fail2ban/jail.local "${backup_dir}/${config_dir}"/dotfiles/jail.local

### logwatch
cp -v /etc/logwatch/conf/logwatch.conf "${backup_dir}/${config_dir}"/dotfiles/logwatch.conf

### apticron / unattended-upgrades
cp -v /etc/apticron/apticron.conf "${backup_dir}/${config_dir}"/dotfiles/apticron.conf
cp -v /etc/apt/apt.conf.d/50unattended-upgrades "${backup_dir}/${config_dir}"/dotfiles/50unattended-upgrades
cp -v /etc/apt/apt.conf.d/20auto-upgrades "${backup_dir}/${config_dir}"/dotfiles/20auto-upgrades

### sshd_config
cp -v /etc/ssh/sshd_config "${backup_dir}/${config_dir}"/dotfiles/sshd_config

### nginx
cp -v /etc/nginx/sites-available/default "${backup_dir}/${config_dir}"/dotfiles/default

### letsencrypt
cp -v /root/letsencrypt.sh "${backup_dir}/${config_dir}"/dotfiles/letsencrypt.sh

#### based on https://github.com/AlexWinder/letsencrypt-backup/blob/master/backup.sh

##### Location where the Let's Encrypt configuration files are (and the ones which are to be backed up)
backup_from="/etc/letsencrypt/"

##### Where files are to be backed up to
backup_to="${backup_dir}/${config_dir}/letsencrypt/"

##### Location of temporary directory where files will be stored for a short period whilst they are compressed
tmp_location="/tmp/"

##### Build the backup name
backup_name="letsencrypt_backup-${timestamp}"

##### Make a temporary directory
mkdir -p "${tmp_location}${backup_name}"

##### Copy the configuration files to the temporary directory
cp -r ${backup_from}. "${tmp_location}${backup_name}"

##### Access the temporary directory
cd $tmp_location || exit

##### Set default file permissions
umask 177

##### Compress the backup into a tar file
tar -cvzf "${tmp_location}${backup_name}.tar.gz" "${backup_name}"

##### Create the backup location, if it doesn't already exist
mkdir -p "${backup_to}"

##### Move the tar.gz file to the backup location
mv "${tmp_location}${backup_name}.tar.gz" "${backup_to}"

##### Delete the old directory from the temporary folder
rm -rf "${tmp_location}${backup_name}"

##### Set a value to be used to find all backups with the same name
# find_backup_name="${backup_to}letsencrypt_backup-*.tar.gz"

### uwsgi
mkdir -p "${backup_dir}/${config_dir}"/uwsgi/sites/
cp -rv /etc/uwsgi/sites/ "${backup_dir}/${config_dir}"/uwsgi/
cp -v /etc/systemd/system/uwsgi.service "${backup_dir}/${config_dir}"/uwsgi/uwsgi.service

## 04. push to the cloud

### first, the backups
rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${backup_dir}/${files_dir}/" "${remote}:${machine}/${files_dir}/"
rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${backup_dir}/${db_dir}/" "${remote}:${machine}/${db_dir}/"
rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${backup_dir}/${config_dir}/" "${remote}:${machine}/${config_dir}/"

### then, the backup file + accompanying config
rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${SCRIPT_DIR}/${SCRIPT}" "${remote}":"${machine}"
rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${configfile}" "${remote}":"${machine}"

### finally, any additional stuff

if [ -z "$extras" ]
then
  echo "looks like there's no other stuff to backup"
else
  for extra in $extras;
  do
    extra=$(echo -e "${extra}" | sed 's/^.\(.*\).$/\1/')  # strip the 1st & last chars
    directory=$( basename "${extra}" )
    mkdir -p "${backup_dir}/additional_backups/${directory}"
    tar --exclude='**/.git'\
        --exclude='**/node_modules'\
        --exclude='**/htmlcov'\
        --exclude='**/staticfiles'\
        --exclude='**/.cache'\
        --exclude='**/.pytest_cache'\
        --exclude='**/__pycache__'\
        --exclude='.tox'\
        --exclude='.coverage'\
        --exclude='.coverage.xml'\
        --exclude='*.pyc'\
        --exclude='*.pyo'\
        --exclude='*~'\
        -cv "${extra}" | xz -3e > "${backup_dir}/additional_backups/${directory}/${directory}_${timestamp}".tar.xz    
  done
  rclone sync --progress --config "/home/${user}/.config/rclone/rclone.conf" "${backup_dir}/additional_backups/" "${remote}":"${machine}"/additional_backups/
fi

## 05. cleanup

### delete backups older than 10 days
find "${backup_dir}/${files_dir}/" -mtime +"${days}" -type f -delete
find "${backup_dir}/${db_dir}/" -mtime +"${days}" -type f -delete
find "${backup_dir}/additional_backups/" -mtime +"${days}" -type f -delete

### delete backup logs older than specified No. of days
find "${backup_dir}" -mtime +"${days}" -type f -name "backup_*.log" -delete

### delete the configs directory
rm -rv "${backup_dir:?}/${config_dir:?}"

## cron example (run daily at 3:18AM), with redirection of output to timestamped logfile
# 18 3 * * * /path/to/backup.sh >> /path/to/backup_`date +\%Y\%m\%d_\%H\%M\%S`.log 2>&1
