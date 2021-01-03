Below is a sample NGINX configuration. You can use it as the pattern for your proxy server configuration. If you are not familiar with NGINX check [the official getting started guide](https://www.nginx.com/resources/wiki/start/) 

> NOTE! It is good to secure access to the data. Always have security in mind.

### 1. Restrict access to those indices you want to expose using `Location`.
1. [DigitalOcean Location tutorial](https://www.digitalocean.com/community/tutorials/understanding-nginx-server-and-location-block-selection-algorithms)
2. [Official Location tutorial](https://docs.nginx.com/nginx/admin-guide/web-server/web-server/#configuring-locations)

### 2. Restrict access with HTTP Basic Authentication.
1. [Official Basic Authentication tutorial](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/)
2. [DigitalOcean Basic Authentication tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-nginx-on-ubuntu-14-04)

### 2. Use encrypted connection.

1. [DigitalOcean HTTPS configuration tutorial](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04)
2. [Official HTTPS configuration tutorial](http://nginx.org/en/docs/http/configuring_https_servers.html)

Sample NGINX configuration.

```yaml
upstream elasticsearch_proxy {
    # elasticsearch search engine address
    server 127.0.0.1:9200;
}

server {

    #Ad 1. Restrict access to specific indexes eg. starting with : 'logs-2021-' add following location directive. 
    location ~ /logs-2021-.*$ {

        #Ad 2. Restrict access with basic authentication
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_pass http://elasticsearch_proxy;
        proxy_redirect     off;
    }

    #Ad 3. Use encrypted connection
    listen [::]:443 ssl ipv6only=on;
    listen 433 ssl;
    ssl_certificate /path/to/a/fullchain.pem;
    ssl_certificate_key /path/to/a/privkey.pem;
}
```