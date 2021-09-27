FROM debian:latest
RUN apt update -y && apt install -y nginx curl wget ssh busybox npm && npm install -g wstunnel
ADD Start.sh /Start.sh
RUN chmod 777 /Start.sh
CMD /Start.sh
