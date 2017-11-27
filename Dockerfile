
# s2i-haproxy
FROM openshift/base-centos7

ARG HAPROXY_DOWNLOAD="https://www.haproxy.org/download/1.8/src/haproxy-1.8.0.tar.gz"
ARG HAPROXY_MD5=6ccea4619b7183fbcc8c98bae1f9823d
ARG LUA_DOWNLOAD="http://www.lua.org/ftp/lua-5.3.4.tar.gz"
ARG LUA_MD5=53a9c68bcc0eda58bdc2095ad5cdfc63
ENV PATH $PATH:/usr/libexec/s2i/

LABEL io.k8s.description="Platform for building HAproxy" \
      io.k8s.display-name="s2i HAproxy centos7 " \
      io.openshift.expose-services="8080:http"\
      io.openshift.tags="builder,s2i,haproxy,gateway,proxy,lua"

RUN buildDeps='\
        gcc \
        make \
        pcre-static \
        pcre-devel \
        openssl-devel \
        readline-devel \
        wget \
    '\
    && yum install -y ${buildDeps} \
    && wget -O /tmp/lua.tar.gz ${LUA_DOWNLOAD} \
    && echo "${LUA_MD5} */tmp/lua.tar.gz" | md5sum -c \
    && mkdir -p /tmp/lua \
    && tar -xzf /tmp/lua.tar.gz -C /tmp/lua --strip-components=1 \
    && make -C /tmp/lua -j$(nproc) linux \
    && make -C /tmp/lua install \
    && wget -O /tmp/haproxy.tar.gz ${HAPROXY_DOWNLOAD} \
	&& echo "${HAPROXY_MD5} */tmp/haproxy.tar.gz" | md5sum -c \
    && mkdir -p /tmp/haproxy \
    && tar -xzf /tmp/haproxy.tar.gz -C /tmp/haproxy --strip-components=1 \
    && makeOpts='\
	    TARGET=linux2628 \
		USE_LUA=1 \
		USE_OPENSSL=1 \
		USE_PCRE=1 PCREDIR= \
		USE_ZLIB=1 \
	'\
    && make -C /tmp/haproxy -j "$(nproc)" all ${makeOpts} \
    && make -C /tmp/haproxy install \
    && yum remove ${buildDeps} -y \
    && yum clean all -y \
    && rm -rf /var/cache/yum /tmp/*

COPY ./s2i/bin/ /usr/libexec/s2i
USER 1001

WORKDIR ${HOME}
EXPOSE 8080
CMD ["usage"]
