FROM        frrouting/frr:latest
LABEL maintainer="paul.mao@citrix.com"

# Trigger rebuild
ENV         UPDATED_AT 2020-03-09

# Install Software
RUN     apk update \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
		&& apk upgrade \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
 		&& apk add supervisor \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
			--repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
			rtrlib \
			busybox-extras \
                && touch /etc/frr/vtysh.conf \
		&& rm -rf /var/cache/apk/*

# Supervisord
ADD	daemons /etc/frr/daemons
ADD     supervisord.conf /etc/supervisord.conf
ADD     shutdown-admin-interface /bin/shutdown-admin-interface
# Configuration files
VOLUME /etc/frr

# Expose ports
EXPOSE  179

# Command
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
