#!/bin/bash

echo root:aA123456|chpasswd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN mkdir /run/sshd
/usr/sbin/sshd -D &

IP=`curl -s ip.3322.net`
echo $IP":"$PORT
echo $IP":"$PORT > /ip.log

cat > /etc/nginx/conf.d/mynginx.conf <<-EOF
#nginx
server {
		listen  443;
		server_name  mynginx-production.up.railway.app;

		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		location / {
			proxy_pass http://127.0.0.1:80;
			
			proxy_connect_timeout 600;
			proxy_read_timeout 600;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
		}
	}

server {
		listen  ${PORT};
		server_name  mynginx-production.up.railway.app;

		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		location / {
			proxy_pass http://127.0.0.1:8080;
			
			proxy_connect_timeout 600;
			proxy_read_timeout 600;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
		}
	}


#ssh
server {
		listen  ${PORT};
		server_name  rai-ssh.cn2hk.ml;

		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		location / {
			proxy_pass http://127.0.0.1:22;
			
			proxy_connect_timeout 600;
			proxy_read_timeout 600;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
		}
	}


#wstunnel
server {
		listen  ${PORT};
		server_name  rai-ws.cn2hk.ml;

		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		location / {
			proxy_pass http://127.0.0.1:8080;
			
			proxy_connect_timeout 600;
			proxy_read_timeout 600;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
		}
	}

EOF

wstunnel -s 0.0.0.0:8080 >/dev/null 2>&1 &
service nginx stop
service nginx start
sleep -d 123456
