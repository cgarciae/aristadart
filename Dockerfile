FROM google/dart

RUN ln -s /usr/lib/dart /usr/lib/dart/bin/dart-sdk

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get

CMD ["dart", "bin/server.dart"]
