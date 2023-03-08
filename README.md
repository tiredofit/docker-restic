# github.com/tiredofit/restic

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-restic?style=flat-square)](https://github.com/tiredofit/docker-restic/releases/latest)
[![Build Status](https://img.shields.io/github/workflow/status/tiredofit/docker-restic/build?style=flat-square)](https://github.com/tiredofit/docker-restic/actions?query=workflow%3Abuild)
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
- Pre and Post Hooks for all operations
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
      - [Hooks](#hooks)
    - [Check Options](#check-options)
      - [Default Check Options](#default-check-options)
      - [Job Check Options](#job-check-options)
      - [Hooks](#hooks-1)
    - [Cleanup Options](#cleanup-options)
      - [Default Cleanup Options](#default-cleanup-options)
      - [Job Cleanup Options](#job-cleanup-options)
      - [Hooks](#hooks-2)
    - [Inventory Options](#inventory-options)
      - [Default Inventory Options](#default-inventory-options)
      - [Hooks](#hooks-3)
    - [Prune Options](#prune-options)
      - [Default Prune Options](#default-prune-options)
      - [Hooks](#hooks-4)
    - [Server Options](#server-options)
    - [RClone Options](#rclone-options)
    - [Unlock Options](#unlock-options)
      - [Hooks](#hooks-5)
    - [Notifications](#notifications)
      - [Custom Notifications](#custom-notifications)
      - [Email Notifications](#email-notifications)
      - [Matrix Notifications](#matrix-notifications)
      - [Mattermost Notifications](#mattermost-notifications)
      - [Rocketchat Notifications](#rocketchat-notifications)
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

| Directory | Description                                         |
| --------- | --------------------------------------------------- |
| `/cache`  | Cached files from repository for quicker operations |
| `/config` | (server) Configuration and Password Files           |
| `/logs`   | Logfiles                                            |

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

| Variable      | Description                                               | Default    |
| ------------- | --------------------------------------------------------- | ---------- |
| `MODE`        | Run multiple modes by seperating with comma:              |            |
|               | `BACKUP` filesystem                                       |            |
|               | `CHECK` repository - See options below                    |            |
|               | `CLEANUP` repository - See options below                  |            |
|               | `INVENTORY` repository - See options below                |            |
|               | `PRUNE` repository - See options below                    |            |
|               | `RCLONE` Run a copy of RClone                             |            |
|               | `SERVER` REST repository access - see options below       |            |
|               | `STANDALONE` (Do nothing, just run container)             |            |
| `CACHE_PATH`  | Cached files to optimize performance                      | `/cache/`  |
| `CONFIG_PATH` | Configuration files for Server                            | `/config/` |
| `LOG_PATH`    | Log file path                                             | `/logs/`   |
| `LOG_TYPE`    | `FILE` only at this time                                  | `FILE`     |
| `SETUP_MODE`  | `AUTO` only at this time                                  | `AUTO`     |
| `DELAY_INIT`  | Delay Repository Initialization routines by `int` seconds |            |
| `SKIP_INIT`   | Skip Repository Initialization Checks                     | `FALSE`    |

#### Job Defaults
If these are set and no other defaults or variables are set explicitly, they will be added to any of the `BACKUP`, `CHECK`, `CLEANUP`, `INVENTORY` or `PRUNE` jobs.

| Variable                  | Description                                                                    | Default |
| ------------------------- | ------------------------------------------------------------------------------ | ------- |
| `DEFAULT_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server` |         |
| `DEFAULT_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                              |         |

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
| `DEFAULT_BACKUP_SNAPSHOT_HOOK_POST`       | Path and Filename to execute post snapshot operation                                 |         |
| `DEFAULT_BACKUP_SNAPSHOT_HOOK_PRE`        | Path and Filename to execute pre snapshot operation                                  |         |
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
| `BACKUP01_SNAPSHOT_HOOK_POST`       | Path and Filename to execute post snapshot operation                                                                                           |         |
| `BACKUP01_SNAPSHOT_HOOK_PRE`        | Path and Filename to execute pre snapshot operation                                                                                            |         |
| `BACKUP01_SNAPSHOT_INTERVAL`        | Frequency after first execution of firing backup routines again in                                                                             |         |
| `BACKUP01_SNAPSHOT_NAME`            | A friendly name to reference your snapshot job eg home, or var_local                                                                           |         |
| `BACKUP01_SNAPSHOT_PATH`            | The path to backup from your filesystem eg `/rootfs/home`                                                                                      |         |
| `BACKUP01_SNAPSHOT_EXCLUDE`         | Comma seperated list of files or paths to exclude from backup eg `.snapshots,.cache`                                                           |         |
| `BACKUP01_SNAPSHOT_EXCLUDE_FILE`    | Line seperated list of files or directories to exclude                                                                                         |         |
| `BACKUP01_SNAPSHOT_PATH`            | Folder or file to backup eg `/etc`                                                                                                             |         |
| `BACKUP01_SNAPSHOT_PATH_FILE`       | Line seperated list of files or directories to backup                                                                                          |         |
| `BACKUP01_SNAPSHOT_TAGS`            | Comma seperated list of tags to attach to snapshot                                                                                             |         |
| `BACKUP01_SNAPSHOT_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`     |

##### Hooks

The following will be sent to the snapshot job hook script:


Pre: `HOSTNAME CONTAINER_NAME BACKUP INSTANCE_NUMBER[XX] BACKUP[XX]_NAME BACKUP[XX]_REPOSITORY_PATH ROUTINE_START_EPOCH BACKUP[XX]_SNAPSHOT_PATH BACKUP[XX]_SNAPSHOT_PATH_FILE`

Example:
```bash
server container_name BACKUP 01 backupjobname rest:username:password@http://repo.url 1677953980 /etc /backup-location-file.if_set
```

Post: `HOSTNAME CONTAINER_NAME BACKUP INSTANCE_NUMBER[XX] BACKUP[XX]NAME BACKUP[XX]REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_EPOCH EXITCODE LOGFILE FILES_NEW FILES_CHANGED FILES_UNMODIFIED DIRS_NEW DIRS_CHANGED DIRS_UNMODIFIED SIZE_BYTES_ADDED SIZE_BYTES_STORED SIZE_BYTES_PROCESSED ERROR_COUNT`

Example:
```bash
server container_name BACKUP 01 backupjobname rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 /logs/20230304/20230304_100501-backup-backupjobname.log 123 100 1024 2 3 2048 1204 1536 65535 0`
```

#### Check Options

This allows restic to check your repository for errors. There is functionality to check minimally, a subset of the fata, or all data.
A Check job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Check Options

If set, these variables will be passed to each prune job, unless each job explicitly sets otherwise.

| Variable                        | Description                                                                               | Default |
| ------------------------------- | ----------------------------------------------------------------------------------------- | ------- |
| `DEFAULT_CHECK_AMOUNT`          | Amount of repository to check                                                             |         |
| `DEFAULT_CHECK_ARGS`            | Arguments to pass to Restic Check command line                                            |         |
| `DEFAULT_CHECK_BLACKOUT_BEGIN`  | Use `HHMM` notation to set the start of a blackout period where no checks occur eg `0420` |         |
| `DEFAULT_CHECK_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no checks occur eg `0430`                 |         |
| `DEFAULT_CHECK_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                     |         |
| `DEFAULT_CHECK_HOOK_POST`       | Path and Filename to execute post repository check operation                              |         |
| `DEFAULT_CHECK_HOOK_PRE`        | Path and Filename to execute pre repository check operation                               |         |
| `DEFAULT_CHECK_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`            |         |
| `DEFAULT_CHECK_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                         |         |
| `DEFAULT_CHECK_USE_CACHE`       | Use cache                                                                                 |         |
| `DEFAULT_CHECK_VERBOSITY_LEVEL` | Check operations log verbosity - Best not to change this                                  | `2`     |


##### Job Check Options

If `DEFAULT_CHECK_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional check jobs can be scheduled by using `CHECK02_`,`CHECK03_`,`CHECK04_` ... prefixes.


| Variable                  | Description                                                                                                                                    | Default |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `CHECK01_AMOUNT`          | Amount of repository to check (Read Data)                                                                                                      |         |
| `CHECK01_ARGS`            | Arguments to pass to Restic check command line                                                                                                 |         |
| `CHECK01_BLACKOUT_BEGIN`  | Use `HHMM` notation to set the start of a blackout period where no checks occur eg `0420`                                                      |         |
| `CHECK01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no checks occur eg `0430`                                                                      |         |
| `CHECK01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `CHECK01_BEGIN`           | What time to do the first check. Defaults to immediate. Must be in one of two formats                                                          |         |
|                           | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                           | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `CHECK01_HOOK_POST`       | Path and Filename to execute post repository check operation                                                                                   |         |
| `CHECK01_HOOK_PRE`        | Path and Filename to execute pre repository check operation                                                                                    |         |
| `CHECK01_INTERVAL`        | Frequency after first execution of firing check routines again in minutes                                                                      |         |
| `CHECK01_NAME`            | A friendly name to reference your check snapshot job eg `consistency_check`                                                                    |         |
| `CHECK01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `CHECK01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `CHECK01_USE_CACHE`       | Use cache                                                                                                                                      |         |
| `CHECK01_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`     |


##### Hooks

The following will be sent to the hook script:

Pre: `HOSTNAME CONTAINER_NAME CHECK INSTANCE_NUMBER[XX] CHECK[XX]_NAME CHECK[XX]_REPOSITORY_PATH ROUTINE_START_EPOCH`

Example:
```bash
server container_name CHECK 01 checkjobname rest:username:password@http://repo.url 1677953980
```

Post: `HOSTNAME CONTAINER_NAME CHECK INSTANCE_NUMBER[XX] CHECK[XX]NAME CHECK[XX]REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_EPOCH EXITCODE LOGFILE PACKS_UNREFERENCED SNAPSHOTS_PROCESSED`

Example:

```bash
server container_name CHECK 01 checkjobname rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 /logs/20230304/20230304_100501-check-checkjobname.log 0 205 205
```


#### Cleanup Options

This allows restic to cleanup old backups from your repository, only retaining snapshots that have a certain criteria.
By default this does not actually delete the files from your repository, only the snapshot references. You can run a seperate `PRUNE` job, or use the included `AUTO_PRUNE` environment variable.
A Cleanup job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Cleanup Options

If set, these variables will be passed to each cleanup job, unless each job explicitly sets otherwise.

| Variable                          | Description                                                                                                                     | Default      |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `DEFAULT_CLEANUP_ARGS`            | Arguments to pass to Restic cleanup command line                                                                                |              |
| `DEFAULT_CLEANUP_AUTO_PRUNE`      | Automatically prune the data (delete from filesystem) upon success `TRUE` `FALSE`                                               |              |
| `DEFAULT_CLEANUP_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`                               |              |
| `DEFAULT_CLEANUP_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`                                           |              |
| `DEFAULT_CLEANUP_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                           |              |
| `DEFAULT_CLEANUP_GROUP_BY`        | Group Snapshots by `host`,`paths`,`tags`                                                                                        | `host,paths` |
| `DEFAULT_CLEANUP_HOOK_POST`       | Path and Filename to execute post cleanup operation                                                                             |              |
| `DEFAULT_CLEANUP_HOOK_PRE`        | Path and Filename to execute pre cleanup operation                                                                              |              |
| `DEFAULT_CLEANUP_HOST`            | The hostname to perform cleanup operations against. Default is $HOSTNAME / $CONTAINER NAME. Use `ALL` for repository operations |              |
| `DEFAULT_CLEANUP_REPACK`          | Repack files which are `CACHEABLE`, `SMALL` files which are below 80% target pack size, or repack all `UNCOMPRESSED` data       |              |
| `DEFAULT_CLEANUP_RETAIN_LATEST`   | How many latest backups to retain eg `3`                                                                                        |              |
| `DEFAULT_CLEANUP_RETAIN_HOURLY`   | How many latest hourly backups to retain eg `24`                                                                                |              |
| `DEFAULT_CLEANUP_RETAIN_DAILY`    | How many daily backups to retain eg `7`                                                                                         |              |
| `DEFAULT_CLEANUP_RETAIN_WEEKLY`   | How many weekly backups to retain eg `5`                                                                                        |              |
| `DEFAULT_CLEANUP_RETAIN_MONTHLY`  | How many monthly backups to retain eg `18`                                                                                      |              |
| `DEFAULT_CLEANUP_RETAIN_YEARLY`   | How many yearly backups to retrain eg `10`                                                                                      |              |
| `DEFAULT_CLEANUP_RETAIN_TAG`      | A comma seperated list of tags that should not be cleaned up using this process                                                 |              |
| `DEFAULT_CLEANUP_VERBOSITY_LEVEL` | Cleanup operations log verbosity - Best not to change this                                                                      | `2`          |
| `DEFAULT_CLEANUP_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                  |              |
| `DEFAULT_CLEANUP_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                               |              |

##### Job Cleanup Options

If `DEFAULT_CLEANUP_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional backup jobs can be scheduled by using `CLEANUP02_`,`CLEANUP03_`,`CLEANUP04_` ... prefixes.

| Variable                    | Description                                                                                                                                    | Default      |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `CLEANUP01_ARGS`            | Arguments to pass to Restic Cleanup command line                                                                                               |              |
| `CLEANUP01_AUTO_PRUNE`      | Automatically prune the data (delete from filesystem) upon success `TRUE` `FALSE`                                                              |              |
| `CLEANUP01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |              |
| `CLEANUP01_BEGIN`           | What time to do the first prune. Defaults to immediate. Must be in one of two formats                                                          |              |
|                             | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |              |
|                             | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |              |
| `CLEANUP01_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`                                              |              |
| `CLEANUP01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`                                                          |              |
| `CLEANUP01_GROUP_BY`        | Group Snapshots by `host`,`paths`,`tags`                                                                                                       | `host,paths` |
| `CLEANUP01_HOOK_POST`       | Path and Filename to execute post cleanup operation                                                                                            |              |
| `CLEANUP01_HOOK_PRE`        | Path and Filename to execute pre cleanup operation                                                                                             |              |
| `CLEANUP01_HOST`            | The hostname to perform cleanup operations against. Default is $HOSTNAME / $CONTAINER NAME. Use `ALL` for repository operations                |              |
| `CLEANUP01_INTERVAL`        | Frequency after first execution of firing prune routines again in minutes                                                                      |              |
| `CLEANUP01_NAME`            | A friendly name to reference your cleanup job eg `repository_name`                                                                             |              |
| `CLEANUP01_REPACK`          | Repack files which are `CACHEABLE`, `SMALL` files which are below 80% target pack size, or repack all `UNCOMPRESSED` data                      |              |
| `CLEANUP01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |              |
| `CLEANUP01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |              |
| `CLEANUP01_RETAIN_LATEST`   | How many latest backups to retain eg `3`                                                                                                       |              |
| `CLEANUP01_RETAIN_HOURLY`   | How many latest hourly backups to retain eg `24`                                                                                               |              |
| `CLEANUP01_RETAIN_DAILY`    | How many daily backups to retain eg `7`                                                                                                        |              |
| `CLEANUP01_RETAIN_WEEKLY`   | How many weekly backups to retain eg `5`                                                                                                       |              |
| `CLEANUP01_RETAIN_MONTHLY`  | How many monthly backups to retain eg `18`                                                                                                     |              |
| `CLEANUP01_RETAIN_YEARLY`   | How many yearly backups to retrain eg `10`                                                                                                     |              |
| `CLEANUP01_RETAIN_TAG`      | A comma seperated list of tags that should not be cleaned up using this process                                                                |              |
| `CLEANUP01_VERBOSITY_LEVEL` | Backup operations log verbosity - Best not to change this                                                                                      | `2`          |

##### Hooks
The following will be sent to the hooks script :

Pre: `HOSTNAME CONTAINER_NAME CLEANUP INSTANCE_NUMBER[XX] CLEANUP[XX]_NAME CLEANUP[XX]_HOST CLEANUP[XX]_REPOSITORY_PATH ROUTINE_START_EPOCH`

Example:
```bash
server container_name CLEANUP 01 cleanupname repository rest:username:password@http://repo.url 1677953980
```

Post: `HOSTNAME CONTAINER_NAME CLEANUP INSTANCE_NUMBER[XX] CLEANUP[XX]NAME CLEANUP[XX]_HOST CLEANUP[XX]REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_EPOCH EXITCODE LOGFILE SNAPSHOTS_REMOVED PRUNE_PACKS_PROCESSED PRUNE_PACKS_KEEP PRUNE_PACKS_REPACK PRUNE_PACKS_DELETE PRUNE_PACKS_DELETE_UNREFERENCED PRUNE_PACKS_DELETE_OLD`

```bash
server container_name CLEANUP 01 cleaupname repository rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 /logs/20230304/20230304_100501-cleanup-cleanupname.log 23 6266 3921 372 1973 82 2345
```

#### Inventory Options

This allows restic to take inventory of what backups have been taken on the repository. It creates a log file detailing the snapshot id, date / time, hostname, tags, and backup paths.
An Inventory job takes lots of time if working with remote repositories.

##### Default Inventory Options

If set, these variables will be passed to each inventory job, unless each job explicitly sets otherwise.

| Variable                            | Description                                                                    | Default |
| ----------------------------------- | ------------------------------------------------------------------------------ | ------- |
| `DEFAULT_INVENTORY_ARGS`            | Arguments to pass to Restic `snapshots` command line                           |         |
| `DEFAULT_INVENTORY_HOOK_POST`       | Path and Filename to execute post inventory operation                          |         |
| `DEFAULT_INVENTORY_HOOK_PRE`        | Path and Filename to execute pre inventory operation                           |         |
| `DEFAULT_INVENTORY_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server` |         |
| `DEFAULT_INVENTORY_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                              |         |


If `DEFAULT_INVENTORY_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional inventory jobs can be scheduled by using `INVENTORY02_`,`INVENTORY03_`,`INVENTORY04_` ... prefixes.

| Variable                      | Description                                                                                                                                    | Default |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `INVENTORY01_ARGS`            | Arguments to pass to Restic inventory command line                                                                                             |         |
| `INVENTORY01_BEGIN`           | What time to do the first inventory. Defaults to immediate. Must be in one of two formats                                                      |         |
|                               | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                               | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `INVENTORY01_HOOK_POST`       | Path and Filename to execute post inventory operation                                                                                          |         |
| `INVENTORY01_HOOK_PRE`        | Path and Filename to execute pre inventory operation                                                                                           |         |
| `INVENTORY01_INTERVAL`        | Frequency after first execution of firing inventory routines again in minutes                                                                  |         |
| `INVENTORY01_NAME`            | A friendly name to reference your inventory job eg `repository_name`                                                                           |         |
| `INVENTORY01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `INVENTORY01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |

##### Hooks
The following will be sent to the hooks script :

Pre: `HOSTNAME CONTAINER_NAME INVENTORY INSTANCE_NUMBER[XX] INVENTORY[XX]_NAME INVENTORY[XX]_REPOSITORY_PATH ROUTINE_START_EPOCH`

Example:
```bash
server container_name INVENTORY 01 cleanupname rest:username:password@http://repo.url 1677953980
```

Post: `HOSTNAME CONTAINER_NAME INVENTORY INSTANCE_NUMBER[XX] INVENTORY[XX]NAME INVENTORY[XX]REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_EPOCH EXITCODE LOGFILE SNAPSHOTS_TOTAL`

```bash
server container_name INVENTORY 01 cleaupname rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 /logs/20230304/20230304_100501-cleanup-cleanupname.log 23
```

#### Prune Options

This allows restic to delete from the repository filesystem the snapshots that have been marked as "cleaned up".
A Prune job requires exlcusive access to the Restic Repository, therefore no other jobs should be running on them at any time.

##### Default Prune Options

If set, these variables will be passed to each prune job, unless each job explicitly sets otherwise.

| Variable                        | Description                                                                                     | Default |
| ------------------------------- | ----------------------------------------------------------------------------------------------- | ------- |
| `DEFAULT_PRUNE_ARGS`            | Arguments to pass to Restic Prune command line                                                  |         |
| `DEFAULT_PRUNE_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no prune operations occur eg `0420` |         |
| `DEFAULT_PRUNE_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no prune operations occur eg `0430`             |         |
| `DEFAULT_PRUNE_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                           |         |
| `DEFAULT_PRUNE_HOOK_POST`       | Path and Filename to execute post prune operation                                               |         |
| `DEFAULT_PRUNE_HOOK_PRE`        | Path and Filename to execute pre prune operation                                                |         |
| `DEFAULT_PRUNE_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                  |         |
| `DEFAULT_PRUNE_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                               |         |
| `DEFAULT_PRUNE_VERBOSITY_LEVEL` | Prune operations log verbosity - Best not to change this                                        | `2`     |


If `DEFAULT_PRUNE_` variables are set and you do not wish for the settings to carry over into your jobs, you can set the appropriate environment variable with the value of `unset`.
Additional prune jobs can be scheduled by using `PRUNE02_`,`PRUNE03_`,`PRUNE04_` ... prefixes.

| Variable                  | Description                                                                                                                                    | Default |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `PRUNE01_ARGS`            | Arguments to pass to Restic prune command line                                                                                                 |         |
| `PRUNE01_BEGIN`           | What time to do the first prune. Defaults to immediate. Must be in one of two formats                                                          |         |
|                           | Absolute HHMM, e.g. `2330` or `0415`                                                                                                           |         |
|                           | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half |         |
| `PRUNE01_BLACKOUT_BEGIN`  | Use `HHMM` notation to the start of a blackout period where no cleanup operations occur eg `0420`                                              |         |
| `PRUNE01_BLACKOUT_END`    | Use `HHMM` notation to set the end period where no cleanup operations occur eg `0430`                                                          |         |
| `PRUNE01_DRY_RUN`         | Don't actually do anything, just emulate the procedure `TRUE` `FALSE`                                                                          |         |
| `PRUNE01_HOOK_POST`       | Path and Filename to execute post prune operation                                                                                              |         |
| `PRUNE01_HOOK_PRE`        | Path and Filename to execute pre prune operation                                                                                               |         |
| `PRUNE01_INTERVAL`        | Frequency after first execution of firing prune routines again in minutes                                                                      |         |
| `PRUNE01_NAME`            | A friendly name to reference your prune snapshot job eg `repository_name`                                                                      |         |
| `PRUNE01_REPOSITORY_PATH` | Path of repository eg `/repository` or `rest:user:password@http://rest.server`                                                                 |         |
| `PRUNE01_REPOSITORY_PASS` | Encryption Key for repository eg `secretpassword`                                                                                              |         |
| `PRUNE01_VERBOSITY_LEVEL` | Prune operations log verbosity - Best not to change this                                                                                       | `2`     |

##### Hooks

The following information will be sent to the hook script:
Pre: `HOSTNAME CONTAINER_NAME PRUNE INSTANCE_NUMBER[XX] PRUNE[XX]_NAME PRUNE[XX]_REPOSITORY_PATH ROUTINE_START_EPOCH`

Example:
```bash
server container_name PRUNE 01 prunereponame rest:username:password@http://repo.url 1677953980
```

Post: `HOSTNAME CONTAINER_NAME PRUNE INSTANCE_NUMBER[XX] PRUNE[XX]NAME PRUNE[XX]REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_EPOCH EXITCODE LOGFILE PACKS_REVIEWED PACKS_DELETED_UNREFERENCED PACKS_REPACKED PACKS_REINDEXED PACKS_DELETED_OLD PACKS_INDEX_DELETED_OBSOLETE`

Example:

```bash
server container_name PRUNE 01 prunereponame rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 /logs/20230304/20230304_100501-prune-prunereponame.log 203 37 10 110 41 5
```

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
| `UNLOCK_HOOK_POST`       | Path and Filename to execute post repository unlock        |         |
| `UNLOCK_HOOK_PRE`        | Path and Filename to execute pre repository unlock         |         |
| `UNLOCK_REMOVE_ALL`      | Remove all locks even active ones `TRUE` `FALSE`           |         |
| `UNLOCK_VERBOSITY_LEVEL` | Verbosity level of unlock command. Best not to change this | `2`     |

##### Hooks

The following information will be sent to the hook script:

Pre: `HOSTNAME CONTAINER_NAME UNLOCK REPOSITORY_PATH ROUTINE_START_EPOCH`

Example:
```bash
server container_name UNLOCK rest:username:password@http://repo.url 1677953980
```

Post: `HOSTNAME CONTAINER_NAME TYPE REPOSITORY_PATH ROUTINE_START_EPOCH PROCESS_START_EPOCH PROCESS_FINISH_EPOCH PROCESS_TOTAL_SECONDS EXITCODE LOGFILE

Example:
```bash
server container_name UNLOCK rest:username:password@http://repo.url 1677953980 1677953981 1677953991 10 0 20230304/20230304_090351-unlock.log
```
#### Notifications

This image has capabilities on sending notifications via a handful of services when a restic process fails.

| Parameter              | Description                                                                       | Default |
| ---------------------- | --------------------------------------------------------------------------------- | ------- |
| `ENABLE_NOTIFICATIONS` | Enable Notifications                                                              | `FALSE` |
| `NOTIFICATION_TYPE`    | `CUSTOM` `EMAIL` `MATRIX` `MATTERMOST` `ROCKETCHAT` - Seperate Multiple by commas |         |

##### Custom Notifications

The following is sent to the custom script. Use how you wish:

````
$1 unix timestamp
$2 logfile
$3 errorcode
$4 subject
$5 body/error message
````

| Parameter                    | Description                                             | Default |
| ---------------------------- | ------------------------------------------------------- | ------- |
| `NOTIFICATION_CUSTOM_SCRIPT` | Path and name of custom script to execute notification. |         |


##### Email Notifications
| Parameter   | Description                                                                               | Default |
| ----------- | ----------------------------------------------------------------------------------------- | ------- |
| `MAIL_FROM` | What email address to send mail from for errors                                           |         |
| `MAIL_TO`   | What email address to send mail to for errors. Send to multiple by seperating with comma. |         |
| `SMTP_HOST` | What SMTP server to use for sending mail                                                  |         |
| `SMTP_PORT` | What SMTP port to use for sending mail                                                    |         |

##### Matrix Notifications

Fetch a `MATRIX_ACCESS_TOKEN`:

````
curl -XPOST -d '{"type":"m.login.password", "user":"myuserid", "password":"mypass"}' "https://matrix.org/_matrix/client/r0/login"
````

Copy the JSON response `access_token` that will look something like this:

````
{"access_token":"MDAxO...blahblah","refresh_token":"MDAxO...blahblah","home_server":"matrix.org","user_id":"@myuserid:matrix.org"}
````

| Parameter             | Description                                                                              | Default |
| --------------------- | ---------------------------------------------------------------------------------------- | ------- |
| `MATRIX_HOST`         | URL (https://matrix.example.com) of Matrix Homeserver                                    |         |
| `MATRIX_ROOM`         | Room ID eg `\!abcdef:example.com` to send to. Send to multiple by seperating with comma. |         |
| `MATRIX_ACCESS_TOKEN` | Access token of user authorized to send to room                                          |         |

##### Mattermost Notifications
| Parameter                | Description                                                                                  | Default |
| ------------------------ | -------------------------------------------------------------------------------------------- | ------- |
| `MATTERMOST_WEBHOOK_URL` | Full URL to send webhook notifications to                                                    |         |
| `MATTERMOST_RECIPIENT`   | Channel or User to send Webhook notifications to. Send to multiple by seperating with comma. |         |
| `MATTERMOST_USERNAME`    | Username to send as eg `GCDS`                                                                |         |

##### Rocketchat Notifications
| Parameter                | Description                                                                                  | Default |
| ------------------------ | -------------------------------------------------------------------------------------------- | ------- |
| `ROCKETCHAT_WEBHOOK_URL` | Full URL to send webhook notifications to                                                    |         |
| `ROCKETCHAT_RECIPIENT`   | Channel or User to send Webhook notifications to. Send to multiple by seperating with comma. |         |
| `ROCKETCHAT_USERNAME`    | Username to send as eg `GCDS`                                                                |         |


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
