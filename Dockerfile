FROM alpine:3.22.1

ENV NODE_ENV="production"
RUN apk add --no-cache openssh git rsync gnupg pass nodejs npm libstdc++ && \
	apk add --no-cache --virtual .build-deps python3 make g++ && \
	mkdir -p /var/nci

WORKDIR /var/nci

COPY package.json package-lock.json /var/nci/

RUN echo "nodejs: `node --version`"

RUN npm ci --omit=dev --no-audit --no-fund && \
	echo "nodejs: `node --version`" > dependencies-info.txt && \
	npmPackages=`npm ls --omit=dev --depth=0 | tail -n +2` && \
	echo -e "npm packages:\n$npmPackages" >> dependencies-info.txt && \
	apk del .build-deps

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

