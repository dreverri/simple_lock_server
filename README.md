## Install

```bash
bundle install
```

## Prepare

Create a directory for lock files; the default is `locks`:

```bash
mkdir locks
```

## Use

Start a lock server:

```bash
bundle exec rackup config.ru
```

Start a lock server with basic authentication:

```bash
LOCK_USER=admin LOCK_PASS=admin bundle exec rackup config.ru
```

Start a lock server using a different directory for lock files:

```bash
mkdir /tmp/lock_files
LOCK_PATH=/tmp/lock_files bundle exec rackup config.ru
```
