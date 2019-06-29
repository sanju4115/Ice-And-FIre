FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get -y install gnupg
RUN apt-get -y install curl
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/download/v1.4.1/dbmate-linux-amd64
RUN apt update
RUN apt install -y postgresql-9.6
RUN chmod +x /usr/local/bin/dbmate
ENV PATH /usr/lib/postgresql/9/bin:$PATH
ADD ./dbwait.sh /bin
RUN chmod +x /bin/dbwait.sh
