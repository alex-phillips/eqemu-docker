FROM debian:stretch

LABEL maintainer="Akkadius <akkadius1@gmail.com>"

USER root

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN apt-get update -yqq && \
    groupadd -g ${PGID} eqemu && \
    useradd -u ${PUID} -g eqemu -m eqemu -G eqemu && \
    usermod -p "*" eqemu

RUN apt-get update && apt-get install -y \
	git \
	sudo \
	bash \
	build-essential \
	cmake \
	cpp \
	curl \
	debconf-utils \
	g++ \
	gcc \
	git \
	git-core \
	libio-stringy-perl \
	liblua5.1 \
	liblua5.1-dev \
	libluabind-dev \
	libmysql++ \
	libperl-dev \
	libperl5i-perl \
	libwtdbomysql-dev \
	default-libmysqlclient-dev \
	minizip \
	lua5.1 \
	make \
	mariadb-client \
	unzip \
	uuid-dev \
	wget \
	zlib1g-dev \
	zlibc \
	libsodium-dev \
	libsodium18 \
	libjson-perl \
	libssl-dev \
	openssh-server

RUN echo "eqemu ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

USER eqemu

WORKDIR /home/eqemu