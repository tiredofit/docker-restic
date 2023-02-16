# github.com/tiredofit/restic

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/restic?style=flat-square)](https://github.com/tiredofit/restic/releases/latest)
[![Build Status](https://img.shields.io/github/workflow/status/tiredofit/restic/build?style=flat-square)](https://github.com/tiredofit/restic/actions?query=workflow%3Abuild)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/restic.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/restic/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/restic.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/restic/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)

## About

This will build a Docker Image for [Restic](https://restic.net), A deduplicating, compressing backup tool capable of backing up to many different remote locatoins.

Features:

- Multiple backup snapshot support
- Schedule times to take snapshots
- Cleanup/Snapshot retention support
- Repository check support (multiple)
- Repository prune support (multiple)
- Restic REST Server included
- RClone included for REST Server functionality/connecting to different backends
- Multiple repository support
- Metrics shipping to Zabbix server

## Maintainer

- [Dave Conroy](https://github.com/tiredofit/)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
    - [Multi Architecture](#multi-architecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
    - [Container Options](#container-options)
    - [Job Defaults](#job-defaults)
    - [Backup Options](#backup-options)
      - [Default Backup Options](#default-backup-options)
      - [Job Backup Options](#job-backup-options)
    - [Check Options](#check-options)
      - [Default Check Options](#default-check-options)
      - [Job Check Options](#job-check-options)
    - [Cleanup Options](#cleanup-options)
      - [Default Cleanup Options](#default-cleanup-options)
      - [Job Cleanup Options](#job-cleanup-options)
    - [Prune Options](#prune-options)
      - [Default Prune Options](#default-prune-options)
    - [Server Options](#server-options)
    - [RClone Options](#rclone-options)
    - [Unlock Options](#unlock-options)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
  - [Manual Backups](#manual-backups)
  - [Manual Checks](#manual-checks)
  - [Manual Prune](#manual-prune)
  - [Creating Server Users and Passwords](#creating-server-users-and-passwords)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)
- [References](#references)


## Installation
### Build from Source
Clone this repository and build the image with `docker build -t (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/restic) and is the recommended method of installation.

```bash
docker pull tiredofit/restic:(imagetag)
```
The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):

| Container OS | Tag       |
| ------------ | --------- |
| Alpine       | `:latest` |

#### Multi Architecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory | Description                               |
| --------- | ----------------------------------------- |
| `/config` | (server) Configuration and Password Files |
| `/logs`   | Logfiles                                  |

* * *
### Environment Variables

#### Base Images used

This image relies on an [Alpine Linux](https://hub.docker.com/r/tiredofit/alpine) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`,`vim`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-alpine/) | Customized Image based on Alpine Linux |
| [Nginx](https://github.com/tiredofit/docker-nginx/)    | Nginx webserver                        |

#### Container Options

| Variable      | Description                                         | Default    |
| ------------- | --------------------------------------------------- | ---------- |
| `MODE`        | Run multiple modes by seperating with comma:        |            |
|               | `BACKUP` filesystem                                 |            |
|               | `CHECK` repository - See options below              |            |
|               | `CLEANUP` repository - See options below            |            |
|               | `PRUNE` repository - See options below              |            |
|               | `RCLONE` Run a copy of RClone                       |            |
|               | `SERVER` REST repository access - see options below |            |
|               | `STANDALONE` (Do nothing, just run container)       |            |
| `CONFIG_PATH` | Configuration files for Server                      | `/config/` |
| `LOG_PATH`    | Log file path                                       | `/logs/`   |
| `LOG_TYPE`    | `FILE` only at this time                            | `FILE`     |
| `SETUP_MODE`  | `AUTO` only at this time                            | `AUTO`     |


#### Job Defaults
If these are set and no other defaults or variables are set explicitly, they will be added to any of the `BACKUP`, `CHECK`, `CLEANUP` or `PRUNE` jobs.

| Variable                         | Description                                                                    | Default |
| -------------------------------- | ------------------------------------------------------------------------------ | ------- |
| `DEFAULT_REPOSITORY_PATH`        | Path of repository eg `/repository` or `rest:user:password@http://rest.server` |         |
| `DEFAULT_REPOSITORY_PASS`        | Encryption Key for repository eg `secretpassword`                              |         |
| `DEFAULT_UNLOCK_VERBOSITY_LEVEL` | Verbosity level of logs should an unlock exist - Best not to change this.      | `2`     |

#### Backup Options

This allows restic to take periodical snapshots to your repository.
Multiple Backup Jobs can be scheduled at once. Be careful not so schedule jobs so that they bump up against `CHECK`, `CLEANUP`, or `PRUNE` jobs.

##### Default Backup Options

If set, these variables will be passed to each backup job, unless each job explicitly sets otherwise.

| Variable                                  | Description                                                                          | Default |
| ----------------------------------------- | ------------------------------------------------------------------------------------ | ------- |
| `BACKUP_JOB_CONCURRENCY`                  | How many restic backup processes can run at once                                     | `2`     |
| `DEFAULT_BACKUP_ENABLE_CLEANUP`           | Enable cleanup operations post successful backup job                                 | `TRUE`  |
| `DEFAULT_BACKUP_REPOSITORY_PATH`          | Path of repository eg `/repository` or `rest:user:password@http://rest.server`       |         |
| `DEFAULT_BACKUP_REPOSITORY_PASS`          | Encryption Key for repository eg `secretpassword`                                    |         |
| `DEFAULT_BACKUP_SNAPSHOT_ARGS`            | Arguments to pass to Restic Backup command line                                      |         |
| `DEFAULT_BACKUP_SNAPSHOT_BLACKOUT_BEGIN`  | Use `HHMM` notation to start a blackout period where no backups occur eg `0420`      |         |
| `DEFAULT_BACKUP_SNAPSHOT_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no backups occur eg `0430`           |         |
| `DEFAULT_BACKUP_SNAPSHOT_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                |         |
| `DEFAULT_BACKUP_SNAPSHOT_EXCLUDE`         | Comma seperated list of files or paths to exclude from backup eg `.snapshots,.cache` |         |
| `DEFAULT_BACKUP_SNAPSHOT_EXCLUDE_FILE`    | Line seperated list of files or directories to exclude                               |         |
| `DEFAULT_BACKUP_SNAPSHOT_PATH`            | Folder or file to backup eg `/etc`                                                   |         |
| `DEFAULT_BACKUP_SNAPSHOT_PATH_FILE`       | Line seperated list of files or directories to backup                                |         |
| `DEFAULT_BACKUP_SNAPSHOT_TAGS`            | Comma seperated list of tags to attach to snapshot                                   |         |
| `DEFAULT_BACKUP_SNAPSHOT_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                            | `2`     |


##### Job Backup Options

If `DEFAULT_BACKUP_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional backup jobs can be scheduled by using `BACKUP02_`,`BACKUP03_`,`BACKUP04_` ... prefixes.


| Variable                            | Description                                                                                                                                    | Default |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `BACKUP01_ARGS`                     | Arguments to pass to Restic Backup command line                                                                                                |         |
| `BACKUP01_SNAPSHOT_NAME`            | A friendly name to reference your backup snapshot job eg `var_local`                                                                           |         |
| `BACKUP01_REPOSITORY_PATH`          | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `BACKUP01_REPOSITORY_PASS`          | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `BACKUP01_SNAPSHOT_BEGIN`           | What time to do the first snapshot. Defaults to immediate. Must be in one of two formats                                                       |         |
|                                     | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                                     | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `BACKUP01_SNAPSHOT_BLACKOUT_BEGIN`  | Use `HHMM` notation to start a blackout period where no backups occur eg `0420`                                                                |         |
| `BACKUP01_SNAPSHOT_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no backups occur eg `0430`                                                                     |         |
| `BACKUP01_SNAPSHOT_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `BACKUP01_SNAPSHOT_INTERVAL`        | Frequency after first execution of firing backup routines again in                                                                             |         |
| `BACKUP01_SNAPSHOT_NAME`            | A friendly name to reference your snapshot job eg home, or var_local                                                                           |         |
| `BACKUP01_SNAPSHOT_PATH`            | The path to backup from your filesystem eg `/rootfs/home`                                                                                      |         |
| `BACKUP01_SNAPSHOT_EXCLUDE`         | Comma seperated list of files or paths to exclude from backup eg `.snapshots,.cache`                                                           |         |
| `BACKUP01_SNAPSHOT_EXCLUDE_FILE`    | Line seperated list of files or directories to exclude                                                                                         |         |
| `BACKUP01_SNAPSHOT_PATH`            | Folder or file to backup eg `/etc`                                                                                                             |         |
| `BACKUP01_SNAPSHOT_PATH_FILE`       | Line seperated list of files or directories to backup                                                                                          |         |
| `BACKUP01_SNAPSHOT_TAGS`            | Comma seperated list of tags to attach to snapshot                                                                                             |         |
| `BACKUP01_SNAPSHOT_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`     |


#### Check Options

This allows restic to check your repository for errors. There is functionality to check minimally, a subset of the fata, or all data.
A Check job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Check Options

If set, these variables will be passed to each prune job, unless each job explicitly sets otherwise.

| Variable                        | Description                                                                    | Default |
| ------------------------------- | ------------------------------------------------------------------------------ | ------- |
| `DEFAULT_CHECK_AMOUNT`          | Amount of repository to check                                                  |         |
| `DEFAULT_CHECK_ARGS`            | Arguments to pass to Restic Check command line                                 |         |
| `DEFAULT_CHECK_BLACKOUT_BEGIN`  | Use `HHMM` notation to set the start of a blackout period where no checks occur eg `0420`      |         |
| `DEFAULT_CHECK_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no checks occur eg `0430`           |         |
| `DEFAULT_CHECK_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`          |         |
| `DEFAULT_CHECK_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server` |         |
| `DEFAULT_CHECK_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                              |         |
| `DEFAULT_CHECK_USE_CACHE`       | Use cache                                                                      |         |
| `DEFAULT_CHECK_VERBOSITY_LEVEL` | Check operations log verbosity - Best not to change this                       | `2`     |


##### Job Check Options

If `DEFAULT_CHECK_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional check jobs can be scheduled by using `CHECK02_`,`CHECK03_`,`CHECK04_` ... prefixes.


| Variable                  | Description                                                                                                                                    | Default |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `CHECK01_AMOUNT`          | Amount of repository to check (Read Data)                                                                                                      |         |
| `CHECK01_ARGS`            | Arguments to pass to Restic check command line                                                                                                 |         |
| `CHECK01_BLACKOUT_BEGIN`  | Use `HHMM` notation to set the start of a blackout period where no checks occur eg `0420`      |         |
| `CHECK01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no checks occur eg `0430`           |         |
| `CHECK01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `CHECK01_BEGIN`           | What time to do the first check. Defaults to immediate. Must be in one of two formats                                                          |         |
|                           | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                           | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `CHECK01_INTERVAL`        | Frequency after first execution of firing check routines again in minutes                                                                      |         |
| `CHECK01_NAME`            | A friendly name to reference your check snapshot job eg `consistency_check`                                                                    |         |
| `CHECK01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `CHECK01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `CHECK01_USE_CACHE`       | Use cache                                                                                                                                      |         |
| `CHECK01_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`     |

#### Cleanup Options

This allows restic to cleanup old backups from your repository, only retaining snapshots that have a certain criteria.
By default this does not actually delete the files from your repository, only the snapshot references. You can run a seperate `PRUNE` job, or use the included `AUTO_PRUNE` environment variable.
A Cleanup job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Cleanup Options

If set, these variables will be passed to each cleanup job, unless each job explicitly sets otherwise.

| Variable                          | Description                                                                                                               | Default |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------- |
| `DEFAULT_CLEANUP_ARGS`            | Arguments to pass to Restic cleanup command line                                                                          |         |
| `DEFAULT_CLEANUP_AUTO_PRUNE`      | Automatically prune the data (delete from filesystem) upon success `TRUE` `FALSE`                                         |         |
| `DEFAULT_CLEANUP_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`      |         |
| `DEFAULT_CLEANUP_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`           |         |
| `DEFAULT_CLEANUP_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                     |         |
| `DEFAULT_CLEANUP_REPACK`          | Repack files which are `CACHEABLE`, `SMALL` files which are below 80% target pack size, or repack all `UNCOMPRESSED` data |         |
| `DEFAULT_CLEANUP_RETAIN_LATEST`   | How many latest backups to retain eg `3`                                                                                  |         |
| `DEFAULT_CLEANUP_RETAIN_HOURLY`   | How many latest hourly backups to retain eg `24`                                                                          |         |
| `DEFAULT_CLEANUP_RETAIN_DAILY`    | How many daily backups to retain eg `7`                                                                                   |         |
| `DEFAULT_CLEANUP_RETAIN_WEEKLY`   | How many weekly backups to retain eg `5`                                                                                  |         |
| `DEFAULT_CLEANUP_RETAIN_MONTHLY`  | How many monthly backups to retain eg `18`                                                                                |         |
| `DEFAULT_CLEANUP_RETAIN_YEARLY`   | How many yearly backups to retrain eg `10`                                                                                |         |
| `DEFAULT_CLEANUP_RETAIN_TAG`      | A comma seperated list of tags that should not be cleaned up using this process                                           |         |
| `DEFAULT_CLEANUP_VERBOSITY_LEVEL` | Cleanup operations log verbosity - Best not to change this                                                                | `2`     |
| `DEFAULT_CLEANUP_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                            |         |
| `DEFAULT_CLEANUP_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                         |         |

##### Job Cleanup Options

If `DEFAULT_CLEANUP_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional backup jobs can be scheduled by using `CLEANUP02_`,`CLEANUP03_`,`CLEANUP04_` ... prefixes.

| Variable                    | Description                                                                                                                                    | Default |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `CLEANUP01_ARGS`            | Arguments to pass to Restic Cleanup command line                                                                                               |         |
| `CLEANUP01_AUTO_PRUNE`      | Automatically prune the data (delete from filesystem) upon success `TRUE` `FALSE`                                                              |         |
| `CLEANUP01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `CLEANUP01_BEGIN`           | What time to do the first prune. Defaults to immediate. Must be in one of two formats                                                          |         |
|                             | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                             | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `CLEANUP01_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`      |         |
| `CLEANUP01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`           |         |
| `CLEANUP01_INTERVAL`        | Frequency after first execution of firing prune routines again in minutes                                                                      |         |
| `CLEANUP01_NAME`            | A friendly name to reference your cleanup job eg `repository_name`                                                                             |         |
| `CLEANUP01_REPACK`          | Repack files which are `CACHEABLE`, `SMALL` files which are below 80% target pack size, or repack all `UNCOMPRESSED` data                      |         |
| `CLEANUP01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `CLEANUP01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `CLEANUP01_RETAIN_LATEST`   | How many latest backups to retain eg `3`                                                                                                       |         |
| `CLEANUP01_RETAIN_HOURLY`   | How many latest hourly backups to retain eg `24`                                                                                               |         |
| `CLEANUP01_RETAIN_DAILY`    | How many daily backups to retain eg `7`                                                                                                        |         |
| `CLEANUP01_RETAIN_WEEKLY`   | How many weekly backups to retain eg `5`                                                                                                       |         |
| `CLEANUP01_RETAIN_MONTHLY`  | How many monthly backups to retain eg `18`                                                                                                     |         |
| `CLEANUP01_RETAIN_YEARLY`   | How many yearly backups to retrain eg `10`                                                                                                     |         |
| `CLEANUP01_RETAIN_TAG`      | A comma seperated list of tags that should not be cleaned up using this process                                                                |         |
| `CLEANUP01_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`     |


#### Prune Options

This allows restic to delete from the repository filesystem the snapshots that have been marked as "cleaned up".
A Prune job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Prune Options

If set, these variables will be passed to each prune job, unless each job explicitly sets otherwise.

| Variable                        | Description                                                                    | Default |
| ------------------------------- | ------------------------------------------------------------------------------ | ------- |
| `DEFAULT_PRUNE_ARGS`            | Arguments to pass to Restic Prune command line                                 |         |
| `DEFAULT_PRUNE_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no prune operations occur eg `0420`      |         |
| `DEFAULT_PRUNE_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no prune operations occur eg `0430`           |         |
| `DEFAULT_PRUNE_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`          |         |
| `DEFAULT_PRUNE_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server` |         |
| `DEFAULT_PRUNE_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                              |         |
| `DEFAULT_PRUNE_VERBOSITY_LEVEL` | Prune operations log verbosity - Best not to change this                       | `2`     |


If `DEFAULT_PRUNE_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional prune jobs can be scheduled by using `PRUNE02_`,`PRUNE03_`,`PRUNE04_` ... prefixes.

| Variable                  | Description                                                                                                                                    | Default |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `PRUNE01_ARGS`            | Arguments to pass to Restic prune command line                                                                                                 |         |
| `PRUNE01_BEGIN`           | What time to do the first prune. Defaults to immediate. Must be in one of two formats                                                          |         |
|                           | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                           | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `PRUNE01_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`      |         |
| `PRUNE01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`           |         |
| `PRUNE01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `PRUNE01_INTERVAL`        | Frequency after first execution of firing prune routines again in minutes                                                                      |         |
| `PRUNE01_NAME`            | A friendly name to reference your prune snapshot job eg `repository_name`                                                                      |         |
| `PRUNE01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `PRUNE01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `PRUNE01_VERBOSITY_LEVEL` | Prune operations log verbosity - Best not to change this                                                                                       | `2`     |

#### Server Options

This will spawn a REST Server either running with the RESTIC built service, or by using the inbuilt feature of RClone, allowing one to take advantage of backing up to one of the many services it supports.
See the maintenance section to [create users and passwords](#creating-server-users-and-passwords).

| Variable                       | Description                                                         | Default                              |
| ------------------------------ | ------------------------------------------------------------------- | ------------------------------------ |
| `ENABLE_NGINX`                 | Enable NGINX proxy to REST server                                   | `TRUE`                               |
| `SERVER_ENABLE_AUTHENTICATION` | Enable Authentication for REST Server                               | `TRUE`                               |
| `SERVER_ENABLE_METRICS`        | Enable Metrics for REST Server                                      | `TRUE`                               |
| `SERVER_LISTEN_IP`             | Listen IP address                                                   | `0.0.0.0`                            |
| `SERVER_LISTEN_PORT`           | Listening Port                                                      | `8000`                               |
| `SERVER_LOG_LEVEL`             | Log Level                                                           | `INFO`                               |
| `SERVER_RCLONE_CONFIG_FILE`    | If using `SERVER_MODE=RCLONE` what rclone configuration file to use | `server_rclone.conf`                 |
| `SERVER_RCLONE_CONFIG_PATH`    | RClone Configuration Path                                           | `${CONFIG_PATH}`                     |
| `SERVER_LOG_FILE`              | Log File                                                            | `server.log`                         |
| `SERVER_LOG_PATH`              | REST Server Log Path                                                | `${LOG_PATH}`                        |
| `SERVER_MODE`                  | Which REST Backend to use `RESTIC` or `RCLONE`                      | `restic`                             |
| `SERVER_PASSWORD_FILE`         | Where to store the htpassword file for repository access            | `${CONFIG_PATH}/server_password.cfg` |
| `SERVER_REPOSITORY_PATH`       | The Servers repository location                                     | `/repository/`                       |

#### RClone Options

If set in `MODE` this will spawn an RClone instance
| Variable      | Description                                                                                   | Default |
| ------------- | --------------------------------------------------------------------------------------------- | ------- |
| `RCLONE_ARGS` | This will pass arguments to a RClone process that will startup after container initialization |         |

#### Unlock Options
Sometimes repositories will get stuck and in a `locked` state. The image attempts to perform automatic unlocking if it detects errors. These settings shouldn't need to be touched.

| Variable                 | Description                                                | Default |
| ------------------------ | ---------------------------------------------------------- | ------- |
| `UNLOCK_ARGS`            | Pass arguments to the restic unlock command                |         |
| `UNLOCK_REMOVE_ALL`      | Remove all locks even active ones `TRUE` `FALSE`           |         |
| `UNLOCK_VERBOSITY_LEVEL` | Verbosity level of unlock command. Best not to change this | `2`     |


### Networking

| Port | Protocol | Description                 |
| ---- | -------- | --------------------------- |
| 8000 | `tcp`    | Restic / RClone REST Server |

## Maintenance
### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is) bash
```

### Manual Backups
Manual Backups can be performed by entering the container and typing `backup-now`. This will execute all the backups that are scheduled by means of the `BACKUPXX_` variables. Alternatively if you wanted to execute a job on its own you could simply type `backup01-now` (or whatever your number would be).

### Manual Checks
Manua Checks can be performed by entering the container and typing `check-now`. This will execute all the backups that are scheduled by means of the `CHECKXX_` variables. Alternatively if you wanted to execute a job on its own you could simply type `check01-now` (or whatever your number would be).

### Manual Prune
Manual Backups can be performed by entering the container and typing `prune-now`. This will execute all the backups that are scheduled by means of the `PRUNEXX_` variables. Alternatively if you wanted to execute a job on its own you could simply type `prune01-now` (or whatever your number would be).

### Creating Server Users and Passwords
Use the `server-user` command:
- Create: `server-user <username> <password>`
- Delete: `server-user <delete>`

## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) personalized support.
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.

## References

* <https://restic.readthedocs.io/en/latest/020_installation.html>
