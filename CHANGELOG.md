# Changelog

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project attempts to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.3.0](https://github.com/engineervix/ubuntu-server-backup/compare/v0.2.0...v0.3.0) (2021-12-11)


### 🚀 Features

* **specify-`days`-in-`config.toml`-&-compress-each-directory-in-the-`[extra]`-section:** also add a bunch of TODOs! ([077eb30](https://github.com/engineervix/ubuntu-server-backup/commit/077eb30965fe2c1309a9610bec6d3aa11f6963ca))

## [v0.2.0](https://github.com/engineervix/ubuntu-server-backup/compare/v0.1.1...v0.2.0) (2021-12-11)


### 👷 CI/CD

* change name to *ShellCheck*, instead of *Continuous Integration* ([cacac6e](https://github.com/engineervix/ubuntu-server-backup/commit/cacac6ee36d745260c0089f8f6a92b1b42b0e860))


### 📝 Docs

* add backing up celery configurations to the TODO list ([6e357d1](https://github.com/engineervix/ubuntu-server-backup/commit/6e357d1cafc9a6997cc4f3d2704b90ddcd07e7ba))
* add important notice and recommendations ([5d8e588](https://github.com/engineervix/ubuntu-server-backup/commit/5d8e588538ae6447459288f276001c23480be7fa))
* mention the need to test using BATS ([cd82888](https://github.com/engineervix/ubuntu-server-backup/commit/cd82888aa7a236d7e76774e76c5329e127c30cac))


### 🚀 Features

* backup celery configs if they exist ([f157f7f](https://github.com/engineervix/ubuntu-server-backup/commit/f157f7f4be351ed932978477c4c2cee894a00347))

## [v0.1.1](https://github.com/engineervix/ubuntu-server-backup/compare/v0.1.0...v0.1.1) (2021-12-11)


### ♻️ Code Refactoring

* add `--with-dpkg-repack` option to `apt-clone` command ([c8b51b5](https://github.com/engineervix/ubuntu-server-backup/commit/c8b51b580048c3c0c04d972888542d30c343dd28))


### 📝 Docs

* provide more details on cron setup, and confirm testing on Ubuntu 20.04 ([dcd0087](https://github.com/engineervix/ubuntu-server-backup/commit/dcd00872e1f3a6813961f0d46ee37edf1bed4d43))
* **readme:** ensure that the script is executable ([b18f5be](https://github.com/engineervix/ubuntu-server-backup/commit/b18f5beb59b3fae76db799997c8afed2e2bdcdd7))


### 🐛 Bug Fixes

* critical bug which can result in losing everything on your server ([5580ae5](https://github.com/engineervix/ubuntu-server-backup/commit/5580ae5fba4c5bce8db033fe772c6d23edc10ef9))
* exclude `.cache/` folders in backups ([8a82f4e](https://github.com/engineervix/ubuntu-server-backup/commit/8a82f4e5b023cdfbb269bd280a39eccacac795bd))
* **readme:** download paths ([2aa3456](https://github.com/engineervix/ubuntu-server-backup/commit/2aa3456065050beb3278a027be16f3a06783acda))
* remove python2-related backups since py2 reached EOL ([0c37da7](https://github.com/engineervix/ubuntu-server-backup/commit/0c37da7451224cb18040194cfd56deff751f29a1))
* use absolute path to config file ([bfc82e9](https://github.com/engineervix/ubuntu-server-backup/commit/bfc82e9010368d3de52589c0bc3167ad2262b001))

## [v0.1.0](https://github.com/engineervix/ubuntu-server-backup/compare/v0.0.0...v0.1.0) (2021-12-10)


### 🚀 Features

* automate backup of DBs, files, configs, etc. for web apps running on an Ubuntu server ([e59c80a](https://github.com/engineervix/ubuntu-server-backup/commit/e59c80ae4e781f4924a9e37a8b23511b6fa6e83a))


### 👷 CI/CD

* remove Ubuntu 18.04 in matrix ([6030e00](https://github.com/engineervix/ubuntu-server-backup/commit/6030e0098f8244f65cdf6ff8db7c6e31813c41f9))
* setup GitHub Actions ([87ebe24](https://github.com/engineervix/ubuntu-server-backup/commit/87ebe241cbcf0bf4bd13904d6cfa9b28f41286e8))


### 📝 Docs

* add contribution guide ([717f0ab](https://github.com/engineervix/ubuntu-server-backup/commit/717f0ab2da9a3b8c4d34809e68964812f1e66544))
* **changelog:** initialise the automation of the documentation of notable changes ([c8f0c35](https://github.com/engineervix/ubuntu-server-backup/commit/c8f0c3509e0b3452eb36c1304a73b4425f232e37))
* **docs:** add a README for the project ([6025da9](https://github.com/engineervix/ubuntu-server-backup/commit/6025da940b04a9cff480af2bba0a2c34d18ba8e0))
* **readme:** update the *last commit* badge ([eb002a6](https://github.com/engineervix/ubuntu-server-backup/commit/eb002a6f78cc27044e5eddf64e45d702247a14a4))
