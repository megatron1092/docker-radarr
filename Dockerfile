FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION="0.0.1"
ARG RADARR_RELEASE="0.0.1"
LABEL build_version="megatron1092 version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="megatron1092"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG RADARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install --no-install-recommends -y \
	jq \
	libicu66 \
	libmediainfo0v5 \
	sqlite3 && \
 echo "**** install radarr ****" && \
 radarr_url=$(curl -s https://api.github.com/repos/megatron1092/Radarr/releases/tags/0.0.1 \
|jq -r '.assets[].browser_download_url') && \
 mkdir -p /app/radarr/bin && \
 curl -o \
	/tmp/radarr.tar.gz -L \
	"${radarr_url}" && \
 tar ixzf \
	/tmp/radarr.tar.gz -C \
	/app/radarr/bin --strip-components=1 && \
 echo "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=megatron1092" > /app/radarr/package_info && \
 echo "**** cleanup ****" && \
 chmod -R 755 /app/radarr/bin && \
 rm -rf \
	/app/radarr/bin/Radarr.Update \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 7878
VOLUME /config
