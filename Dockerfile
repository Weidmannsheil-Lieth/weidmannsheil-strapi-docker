# https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/installation/docker.html#production-environments

FROM node:16-alpine as build

# Installing libvips-dev for sharp Compatibility

RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/
COPY ./app/package.json ./app/package-lock.json ./
RUN npm install --production

WORKDIR /opt/app
COPY ./app/ .
RUN npm run build


FROM node:16-alpine

# Installing libvips-dev for sharp Compatibility
RUN apk add vips-dev
RUN rm -rf /var/cache/apk/*

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app

COPY --from=build /opt/node_modules ./node_modules
ENV PATH /opt/node_modules/.bin:$PATH

COPY --from=build /opt/app ./

EXPOSE 1337

CMD ["npm", "run", "start"]
