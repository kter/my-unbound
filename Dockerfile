FROM debian:trixie
RUN apt update && apt install -y unbound unbound-anchor curl && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY unbound.conf /etc/unbound/unbound.conf
COPY dns-blacklist.sh /etc/unbound/dns-blacklist.sh

# TODO: 標準出力に書き込みたい
# RUN ln -sf /dev/stdout /var/log/unbound.log && chown unbound:unbound /var/log/unbound.log
RUN touch /var/log/unbound.log && chown unbound:unbound /var/log/unbound.log
RUN chown -R unbound:unbound /etc/unbound && chmod 755 /etc/unbound

RUN echo "server:" > /etc/unbound/blacklist.conf

# unbound-anchorはルート アンカーが証明書を使って更新されたり、組み込みのルート アンカーが使われたら、このツールはコード1で終了します
# https://unbound.jp/unbound/unbound-anchor/
RUN /usr/sbin/unbound-anchor -a /etc/unbound/root.key || true && chown unbound:unbound /etc/unbound/root.key


EXPOSE 53 53/udp
ENTRYPOINT ["/bin/sh", "-c", "/etc/unbound/dns-blacklist.sh && unbound -d -c /etc/unbound/unbound.conf"]