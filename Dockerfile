FROM ubuntu:latest

RUN apt-get update && apt-get install -y caca-utils iputils-ping

CMD ["tail", "-f", "/dev/null"]
