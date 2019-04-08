# Development enviroment

### sipac

Ubuntu 18.04 + Apache 2 + PHP 7.2 + Oracle Client 12.2 + Supervisor

### dgi

Ubuntu 16.04 + Apache 2 + PHP 7.0 + Oracle Client 12.2 + Script for CI/CD with laravel dusk 


##### Both designed to host laravel project

# How to use this image

### Command: 

- docker run jjuanrivvera/ubuntu18.04-apache2-php7.2-oracleclient12.2:tag -p 80:80 -p 443:443 -v /var/www:/your_project_path

### Running container with docker compose file

##### Example
    version: '3'
    services:
        web:
            container_name: container_name
                image: jjuanrivvera99/ubuntu18.04-apache2-php7.2-oracleclient12.2:tagname
            ports:
                - 80:80
                - 443:443
            volumes:
                - "./:/var/www/"