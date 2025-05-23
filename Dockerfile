FROM debian:bookworm

ENV OPENLDAP_VERSION=2.6.9

RUN apt-get update && apt-get install -y \
    build-essential \
    libtool \
    autoconf \
    libssl-dev \
    libsasl2-dev \
    libsasl2-modules \
    libdb-dev \
    libsystemd-dev \
    libreadline-dev \
    libldap2-dev \
    curl \
    wget \
    git \
    vim \
    nano \
    net-tools \
    iputils-ping \
    dnsutils \
    slapd \
    ldap-utils \
    ca-certificates \
    pkg-config \
    groff  # soelim

# Descargar y compilar OpenLDAP
RUN mkdir -p /build && \
    cd /build && \
    wget https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz && \
    tar -xzf openldap-${OPENLDAP_VERSION}.tgz && \
    cd openldap-${OPENLDAP_VERSION} && \
    ./configure --prefix=/usr/local/openldap \
        --with-tls=openssl \
        --with-cyrus-sasl \
        --enable-debug \
        --enable-slapd \
        --enable-modules \
        --enable-overlays && \
    make -j$(nproc) && \
    make install

ENV PATH="/usr/local/openldap/bin:/usr/local/openldap/sbin:$PATH"

# Directorios persistentes
VOLUME ["/etc/openldap/slapd.d", "/var/lib/ldap"]

# Inicio en modo slapd.d
CMD ["slapd", "-F", "/etc/openldap/slapd.d", "-h", "ldap:/// ldaps:///", "-d", "256"]

