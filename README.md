# How to Easily Install Magento For Local Development Using Docker

🤩 Only 4 commands to install!!! 🤯

Below is a solution to install Magento using Docker and docker-compose to orchestrate the services. All the services required to run Magento properly will be containerized including PHP, nginx, Mariadb, Redis, Rabbitmq, and Opensearch. The local Magento code base will be mapped to the container for persistence. All this can be completed in 4 commands!

## Prerequisites

Make sure Git and Docker Desktop are installed. That's it!

# Build the Docker Containers

Navigate to the folder where you want to install Magento.

### Download Repository .zip file

https://github.com/codecodeio/magento-docker-local-development

### Run the Build Command

```bash
docker-compose build
```

\*Any time you change your Dockerfile you need to re-run build. Use --no-cache to be sure it rebuilds everything from scratch.

### Start the Docker Containers

```bash
docker-compose up -d
```

\* -d means detached. Leave this off if you want the terminal to display the container log. This can be useful for debugging but all the logs are also shown in Docker Desktop.

When you need to stop the containers run:

```bash
docker-compose down
```

### Check Services

#### OpenSearch

Check OpenSearch from outside the container

```bash
curl -XGET 'http://localhost:9200/_cluster/health?pretty'
```

Check OpenSearch from inside the container. See the "Access the Magento container" section below to see how to do this.

```bash
curl -XGET 'http://opensearchvanilla:9200/_cluster/health?pretty'
```

# Install Magento

Once the services are running, you can install Magento from within the running container.

## Access the Magento container

Run the following command to open a shell inside the magento container:

```bash
docker exec -it <magento_container_name> bash
```

Replace <magento_container_name> with the actual name of your Magento container. We named the container magentovanilla in our docker-compose.yml file but you can check using <code>docker ps</code>. You can also use the container id here.

## Magento Enterprise Authorization

If you want to install Magento enterprise you will need your authorization keys. If you want to install Magento Open Source you can skip this step. You can follow the instructions in the extra credit section below to add auth.json to the magento root folder to gain access to future updates of Magento Enterprise. Composer will refuse to install into a folder that has any files in it so we can't add that yet. For now set COMPOSER_AUTH as a variable in bash so the magento installation will complete.

```bash
export COMPOSER_AUTH='{
    "http-basic": {
        "repo.magento.com": {
            "username": "<public-key>",
            "password": "<private-key>"
        }
    }
}'
```

Check your authorization keys:

```bash
echo $COMPOSER_AUTH
```

## Use Composer to Install Magento

Once inside the container, navigate to the /var/www/html directory (where Magento should be installed). You can install Magento using Composer:

#### Magento Enterprise Edition

```bash
composer create-project --repository=https://repo.magento.com/ magento/project-enterprise-edition=2.4.6-p6 .
```

#### Magento Open Source

```bash
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition=2.4.6-p6 .
```

# Set Up Magento

Once the Magento files are installed, run the Magento installation command. Make sure to use the correct database credentials that match those in the docker-compose.yml.

Inside the container, run:

```bash
bin/magento setup:install \
--base-url="http://localhost:8765" \
--db-host="mariadbvanilla" \
--db-name="magento" \
--db-user="magento" \
--db-password="magento" \
--admin-firstname="Admin" \
--admin-lastname="User" \
--admin-email="admin@example.com" \
--admin-user="admin" \
--admin-password="admin123" \
--backend-frontname="admin" \
--language="en_US" \
--currency="USD" \
--timezone="America/New_York" \
--use-rewrites=1 \
--search-engine=opensearch \
--opensearch-host="opensearchvanilla" \
--opensearch-port=9200
```

## Restart Nginx

The magento install just created the nginx.conf.sample file needed for nginx to start properly. You'll need to restart this service to get nginx running.

```bash
docker-compose restart nginxvanilla
```

\*You can also run docker-compose down and docker-compose up to restart all services.

# Access Magento

Once Magento is installed, you should be able to access your site at:

http://localhost:8765

The Magento admin panel will be available at http://localhost:8765/admin.
\*Disable two factor authentication for the admin so you don't have to deal with this during development with thic command: <code>bin/magento module:disable Magento_TwoFactorAuth</code>

# Wow You Did It!

Did you ever think you could install Magento so quickly??? It only took 4 commands!

```bash
docker-compose build
docker-compose up
composer create-project
bin/magento setup:install
```

😎

# Extra Credit

1. Install Sample Data.
2. Install Xdebug
3. Add auth.json for Magento Enterprise Edition.
4. Run Multiple Magento Containers.
5. Import Existing Magento Code and Database.

## Install Sample Data

Open a shell inside the magento container and run the following commands:

```bash
bin/magento sampledata:deploy
bin/magento setup:upgrade
```

## Install Xdebug

Working with Magento basically requires Xdebug so you can step through the code and see what this large and complex code base is up to. Follow these instruction to install Xdebug and get it working in Visual Studio Code.

### Review The Dockerfile

Xdebug was already installed by the Dockerfile using pecl install. Make sure this is in your Dockerfile after any other pecl installs.

```bash
# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug
```

Check your Dockerfile for the proper Xdebug setttings. You should see this in your Dockerfile.

```bash
# Add xdebug settings, "zend_extension=xdebug" is alread set
RUN echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
```

### Set up Visual Studio Code for Xdebug

Open your project in VSC.

#### Install the PHP Debug Extension

In VSC navigate to the extensions section and search for PHP Debug or Xdebug. Install the PHP Debug extension made by Xdebug.

#### Set PHP Debug settings

- Navigate to the Run And Debug section of VSC.
- Click "create a launch.json file" and select PHP from the dropdown choices.
- Add pathMappings to the configurations section for "name": "Listen for Xdebug".
  - It should map the magento install on docker "/var/www/html" to the local magento files "${workspaceFolder}/magento" and look like the json below.
  - This file is located in .vscode/launch.json.

```bash
"configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/var/www/html": "${workspaceFolder}/magento"
      }
    },
    ...
```

### Run Xdebug

- Navigate to the Run And Debug section of VSC. At the top of this section click the dropdown and make sure "Listen for Xdebug" is selected.
- Add a breakpoint to pub/index.php
- Click the green "Start Debugging" arrow that looks like a play button.
  - If this workis you should see a blue bar at the bottom of VSC and a new icon bar at the top of the screen that has the pause, step over, step into, step out, restart, and stop buttons.
  - Refresh your website you should see VSC opens and is stopped at your breakpoint. Here you can see the local variables.

🥳 You did it! I don't know about you but that was the easiest time I ever had getting Xdebug to work!

## Add auth.json for Magento Enterprise Edition

Create the auth.json File: In the ./magento folder on your host machine for any future updates from the enterprise Magento repository.

```bash
{
    "http-basic": {
        "repo.magento.com": {
            "username": "<public-key>",
            "password": "<private-key>"
        }
    }
}
```

## Run Multiple Magento Containers

The docker containers are all named with "vanilla" as part of the name so you can easily identify them in Docker Desktop. The volumes are also named so you can associate them with this container and no volumes have been assigned random ids. This way you can easily remove them when not needed. Eventually you will want to create a second magento container which requires changing the 3 items below.

\*The Dockerfile does not need to change.

1. Alter the docker-compose.yml file. Do a find and replace of "vanilla" with whatever you want like "development".
2. The nginx/default.conf needs to point to the new FPM container so magentovanilla should change to magentodevelopment.
3. Finally, the bin/magento setup:install script needs to change the db-host from --db-host="mariadbvanilla" to --db-host="mariadbdevelopment" and opensearch-host from --opensearch-host="opensearchvanilla" to --opensearch-host="opensearchdevelopment"

\*You can only run one container at a time because the ports for nginx, opensearch, and rabbitmq will conflict. You could change all these ports and set environment variables so you can run more than one container at a time but I don't think the complication is worth it.

## Import Existing Magento Code and Database

### Create a backup of the existing code base

```bash
bin/magento support:backup:code
```

### Copy the existing code base into the local code base

```bash
cp -R path/to/existing/code/* ./magento
```

### Puth auth.json back

If you need auth.json to exist it was likely just erased. But it back or rename and update auth.json.sample.

### Dump the existing DB

ssh into the server where your existing code base resides and create a sql dump using this command:

```bash
mysqldump -h host-sql-url.goes.here -u username -pPWD dbname > dump.sql
```

Connect to the local Mariadb service in Docker and start the mysql prompt:

```bash
docker exec -it <mariadb-container-name> mysql -u magento -p magento
```

Drop and recreate the DB:

```bash
DROP DATABASE magento;
CREATE DATABASE magento;
```

### Import the Database

On your local machine run this command:

```bash
docker exec -i <mariadb-container-id> mysql -u root -prootpass magento < path/to/dump.sql
```

If you see GTID errors, remove GTID's from the sql dump file using this command, drop and recreate the DB, then run the import command again.

```bash
sed -i.backup '/@@GLOBAL.GTID_PURGED=/d' dump.sql
```

### Check the result of the Import

ssh into the mariadb container to run queries on the magento db

```bash
docker exec -it magentodev-mariadbdev-1 mysql -u root -prootpass
```

#### Check what the import is up to

```sql
SHOW FULL PROCESSLIST;
```

#### Check the size of the DB

```sql
SELECT table_schema AS "Database",
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.tables
WHERE table_schema = 'magento';
```

#### Check the number of tables

```sql
SELECT COUNT(*)
FROM information_schema.tables
WHERE table_schema = 'magento';
```

### Update some db values to run locally

The database you imported will have settings that will prevent it from funning locally. Runing this update sql to change some data in core_config_data should resolve these issues.

```sql
UPDATE core_config_data
SET value = CASE
    WHEN path = 'catalog/search/opensearch_server_hostname' THEN 'opensearchvanilla'
    WHEN path = 'catalog/search/opensearch_server_port' THEN '9200'
    WHEN path = 'web/unsecure/base_url' THEN 'http://localhost:8765/'
    WHEN path = 'web/secure/base_url' THEN 'http://localhost:8765/'
    WHEN path = 'web/unsecure/base_link_url' THEN 'http://localhost:8765/'
    WHEN path = 'web/secure/base_link_url' THEN 'http://localhost:8765/'
    WHEN path = 'admin/url/use_custom' THEN '0'
    WHEN path ='system/full_page_cache/caching_application' THEN '1'
END
WHERE path IN (
    'catalog/search/opensearch_server_hostname',
    'catalog/search/opensearch_server_port',
    'web/unsecure/base_url',
    'web/secure/base_url',
    'web/unsecure/base_link_url',
    'web/secure/base_link_url',
    'admin/url/use_custom',
    'system/full_page_cache/caching_application'
);
```

#### Check the result of the core_config_data update

```sql
SELECT path, value
FROM core_config_data
WHERE path IN (
    'catalog/search/opensearch_server_hostname',
    'catalog/search/opensearch_server_port',
    'web/unsecure/base_url',
    'web/secure/base_url',
    'web/unsecure/base_link_url',
    'web/secure/base_link_url',
    'admin/url/use_custom',
    'system/full_page_cache/caching_application'
);
```

### Change env.php settings

Change app/etc/env.php to match local settings.

#### Mariadb

- Change db host to mariadbvanilla.
- Change the username and password to what was used in the setup:install command, which was: magento.

#### Redis

- Change redis host to redisvanilla.
- Leave the port as is, 6379, is the default port.

#### Admin Url

- Take note that the admin url is set in app/etc/env.php
- ````bash
    'backend' => [
        'frontName' => 'admin'
    ],```
  ````

### Run some commands to get Magento up and running

```bash
composer install
bin/magento setup:di:compile
bin/magento indexer:reindex
bin/magento cache:clean
bin/magento cache:flush
bin/magento setup:upgrade
```
