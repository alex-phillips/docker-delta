FROM lsiobase/alpine:3.10

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DELTA_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

# environment settings
ENV HOME="/app"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
    nodejs \
    npm \
    redis && \
 apk add --no-cache --virtual=build-dependencies \
    curl && \
 echo "**** install delta ****" && \
 mkdir -p /app/delta && \
 if [ -z ${DELTA_RELEASE} ]; then \
	DELTA_RELEASE=$(curl -sX GET "https://api.github.com/repos/fosslife/delta/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/delta.tar.gz -L \
	"https://github.com/fosslife/delta/archive/${DELTA_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/delta.tar.gz -C \
	/app/delta/ --strip-components=1 && \
 cd /app/delta && \
 npm i --no-dev && \
 echo "**** cleanup ****" && \
 apk del --purge \
    build-dependencies && \
 rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
