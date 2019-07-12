# Development LARAVEL enviroment

### latest

- Ubuntu 18.04 + Apache 2 + PHP 7.2 + Oracle Client 12.2 
- Apache document root '/var/www/public'

# How to use this image

### Command: 

- docker run jjuanrivvera99/ubuntu18.04-apache2-php7.2-oracleclient12.2:tag -p 80:80 -p 443:443 -v /your_project_path:/var/www

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
