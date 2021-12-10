# Bash backup script for Ubuntu servers

[![Continuous Integration](https://github.com/engineervix/ubuntu-server-backup/actions/workflows/main.yml/badge.svg)](https://github.com/engineervix/ubuntu-server-backup/actions/workflows/main.yml)
[![last commit](https://badgen.net/github/last-commit/engineervix//ubuntu-server-backup)](https://github.com/engineervix/ubuntu-server-backup/commits/)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/engineervix/ubuntu-server-backup/latest/main)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)
![License](https://img.shields.io/github/license/engineervix/ubuntu-server-backup)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Introduction](#introduction)
- [Features ✨](#features-)
- [Usage 🚀](#usage-)
- [Supported Ubuntu versions](#supported-ubuntu-versions)
- [TODO ✅](#todo-)
- [Author](#author)
- [Contributing 🤝](#contributing-)
- [Show your support](#show-your-support)
- [License 📝](#license-)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

This is a custom backup script to automate the process of backing up databases, files, configurations, etc. for **web applications** running on an Ubuntu server. These applications are typically Python projects (Django, Flask, etc.), and the server setup is based on [@engineervix/ubuntu-server-setup](https://github.com/engineervix/ubuntu-server-setup).

## Features ✨

- specify backup directories and other configurations through a `config.toml` file. See the [sample file](config.sample.toml)
- uses [rclone](https://rclone.org/) to sync your backups to a cloud provider of your choice
- run the script via **cron**
- timestamps your backups
- automatically deletes backups older than 10 days (of course you can change this to whatever number of days you want)
- backs up the following:
  - all your project files
  - all PostgreSQL databases
  - redis data & configuration
  - list of installed `apt` and `snap` packages
  - list of globally installed `python3` and `python2` packages
  - list of globally installed npm packages
  - all your Python virtual environments (names + installed packages for each)
  - your `.bashrc`, `.zshrc` and `.vimrc.after` files
  - crontabs
  - postfix configuration
  - configs for `fail2ban`, `logwatch`, `apticron`, `unattended-upgrades`, `nginx`, `uwsgi`, `letsencrypt` & `sshd`.

## Usage 🚀

> **Before you get started**
>
> As already mentioned, the server setup is based on <https://github.com/engineervix/ubuntu-server-setup>, so if you're backing up stuff on such a server, you don't need to install anything to use the script, because all the required dependencies are already installed.
>
> However, if your server setup is different, you can have a quick idea of the dependencies just by skimming through the script before running, and also check out the server setup docs: <https://ubuntu-server-setup.readthedocs.io/en/latest/02_features.html>. Some noteworthy dependencies include [jq](https://stedolan.github.io/jq/) and [yq](https://kislyuk.github.io/yq/) for reading the `.toml` config file and other formats like `.json`.
>
> Regardless of your server setup, you need to configure [rclone](https://rclone.org/) with your choice(s) of cloud storage.

⌨️ The backup script (`backup.sh`) reads from a configuration file, `config.toml`. To get started, you can either clone this repo or just download `backup.sh` and `config.sample.toml`. Here's an example of the latter:

```bash
wget https://github.com/engineervix/ubuntu-server-backup/blob/main/backup.sh && \
wget https://github.com/engineervix/ubuntu-server-backup/blob/main/config.sample.toml && \
mv -v config.sample.toml config.toml
```

⌨️ Now, edit your `config.toml` accordingly.

⌨️ You can run this script manually (`./backup.sh` if you're in the same directory, or `/path/to/backup.sh` if calling the script from somewhere else), but you probably wanna run it via `cron`, as `root`. For example, to run it at 3:18AM everyday, your crontab entry will look like: `18 3 * * * /path/to/backup.sh`

## Supported Ubuntu versions

I had Ubuntu 20.04 in mind when writing this, so I don't know if it'll work correctly on other versions.

## TODO ✅

- [ ] do *incremental* backups using <https://duplicity.gitlab.io/duplicity-web/index.html>
- [ ] Backup any additional custom Python virtual environment configs (virtualenvwrapper)
- [ ] Include other *dotfiles* (such as `.profile`, etc.)
- [ ] add email/SMS/telegram/slack notifications on failure (actually, just use <https://healthchecks.io/>)
- [ ] split each backup task into a standalone function
- [ ] run automated tests

## Author

👤 **Victor Miti**

- Blog: <https://importthis.tech>
- Twitter: [![Twitter: engineervix](https://img.shields.io/twitter/follow/engineervix.svg?style=social)](https://twitter.com/engineervix)
- Github: [@engineervix](https://github.com/engineervix)

## Contributing 🤝

Contributions, issues and feature requests are most welcome! A good place to start is by helping out with the unchecked items in the [TODO](#todo-) section of this README!

Feel free to check the [issues page](https://github.com/engineervix/ubuntu-server-backup/issues) and take a look at the [contributing guide](CONTRIBUTING.md) before you get started

## Show your support

Please give a ⭐️ if you found this project helpful!

## License 📝

Copyright © 2021 [Victor Miti](https://github.com/engineervix).

This project is licensed under the terms of the [MIT](https://github.com/engineervix/ubuntu-server-backup/blob/main/LICENSE) license.
