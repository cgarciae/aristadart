FROM google/dart-runtime
ENV DART_VM_OPTIONS --enable-async

#FROM google/dart

#WORKDIR /app

#ADD pubspec.* /app/
#RUN pub get
#ADD . /app
#RUN pub get --offline
