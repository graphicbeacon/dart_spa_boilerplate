# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

RUN apt -y update && apt -y upgrade

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* .
RUN dart pub get

# Copy app source code and update packages
COPY . .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/spa_server.dart -o bin/server

FROM alpine

# Resolve dynamic link issue
# https://stackoverflow.com/questions/66963068/docker-alpine-executable-binary-not-found-even-if-in-path/66974607#66974607
ENV GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION=2.30-r0

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
        do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

WORKDIR /app
COPY --from=build /app/bin/server /app/server
# COPY any other directories or files you may require at runtime, ex:
COPY --from=build /app/public/ /app/public
EXPOSE 8080
CMD ["/app/server"]