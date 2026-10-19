FROM flaresolverr/flaresolverr:v3.5.2@sha256:c80ae007ce2ccdcd217a12426e4f039ef763ff90738c808d38810c3e59323767

USER root
# No setuid or setgid binary: the estate's pods do not yet forbid privilege escalation.
RUN find / -xdev -perm /6000 -type f -exec chmod ug-s {} + \
 && mv /app/chromedriver /app/chromedriver.dist \
 && ln -s /tmp/chromedriver /app/chromedriver
COPY flaresolverr-start /usr/local/bin/flaresolverr-start

# Chrome writes its profile under the home, and only /tmp is writable under the read-only root.
ENV HOME=/tmp
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/flaresolverr-start"]
CMD []
