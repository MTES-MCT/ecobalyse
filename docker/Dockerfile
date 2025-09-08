# syntax=docker/dockerfile:1

ARG NODE_VERSION=22.0.0

FROM node:${NODE_VERSION}-alpine

# Use production node environment by default.
ENV NODE_ENV=production

WORKDIR /usr/src/app

ADD https://github.com/MTES-MCT/ecobalyse/releases/download/v7.0.0/v7.0.0-dist.tar.gz /usr/src/app/dist.tar.gz
RUN tar xzf dist.tar.gz \
  && mv dist/server-app.js . \
  && mv dist/openapi.yaml . \
  && mkdir public \
  && mv dist/data public

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev --ignore-scripts

# Run the application as a non-root user.
USER node

# Copy the rest of the source files into the image.
COPY docker/server-simple.js .
COPY lib lib/
COPY package.json .

# Expose the port that the application listens on.
EXPOSE 8001


# Run the application.
CMD ["node", "server-simple.js"]
