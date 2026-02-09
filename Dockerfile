FROM alpine:3.22.1 AS build

ENV NODE_ENV="production"
RUN apk add --no-cache nodejs npm && \
	apk add --no-cache --virtual .build-deps python3 make g++ && \
	mkdir -p /var/nci

WORKDIR /var/nci

COPY package.json package-lock.json /var/nci/

RUN npm install --omit=dev --no-audit --no-fund && \
	echo "nodejs: `node --version`" > dependencies-info.txt && \
	npmPackages=`npm ls --omit=dev --depth=0 | tail -n +2` && \
	echo -e "npm packages:\n$npmPackages" >> dependencies-info.txt && \
	apk del .build-deps

FROM alpine:3.22.1

ENV NODE_ENV="production"
RUN apk add --no-cache openssh git rsync gnupg pass nodejs libstdc++ && \
	mkdir -p /var/nci

WORKDIR /var/nci

COPY --from=build /var/nci/node_modules /var/nci/node_modules
COPY --from=build /var/nci/dependencies-info.txt /var/nci/dependencies-info.txt
COPY package.json /var/nci/package.json

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

