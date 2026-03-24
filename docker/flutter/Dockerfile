FROM ghcr.io/cirruslabs/flutter:3.38.3

RUN apt-get update && apt-get install -y \
    chromium \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_EXECUTABLE=/usr/bin/chromium

WORKDIR /app

EXPOSE 3000

# pub get runs at container start (not build time) so that
# the volume-mounted source uses Linux-resolved paths.
CMD ["sh", "-c", "flutter pub get && flutter run -d web-server --web-port=3000 --web-hostname=0.0.0.0"]
