FROM alpine:3.22.1

ENV NODE_ENV="production"
ENV USER="nci"
ENV USER_ID=2000
ENV USER_GROUP_ID=2000

RUN addgroup -g "$USER_GROUP_ID" "$USER" && \
	adduser --disabled-password --ingroup "$USER" --uid "$USER_ID" "$USER";

RUN apk add --no-cache openssh git rsync gnupg pass nodejs npm

RUN mkdir /var/nci

ADD package.json /var/nci

RUN chown -R "$USER":"$USER" /var/nci

USER ${USER}

RUN echo "nodejs: `node --version`"

RUN cd /var/nci && \
	npm install && \
	npm ci --only=prod && \
	echo "nodejs: `node --version`" >> dependencies-info.txt && \
	npmPackages=`cd /var/nci && npm ls --prod --depth=0 | tail -n +2` && \
	echo -e "npm packages:\n$npmPackages" >> dependencies-info.txt;

USER root

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

