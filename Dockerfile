# The first thing we need to do is define from what image we want to build from. 
# Here we will use the latest LTS (long term support) version 18 of node available from the Docker Hub
FROM node:18-alpine AS PROD_BUILD_INTERMEDIATE

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot
# Next we create a directory to hold the application code inside the image,
# this will be the working directory for your application:
WORKDIR /usr/src/app


# This image comes with Node.js and NPM already installed so the next thing we need to do is to install 
# your app dependencies using the npm binary. Please note that if you are using npm version 4 or
# a package-lock.json file will not be generated.
ADD package.json ./
ADD package-lock.json ./
ADD utility ./utility
ADD app.js ./

# This command will not install upgraded pkgs. for more visit link
# https://stackoverflow.com/a/76219090/3296607
RUN npm ci --omit=dev  --ignore-scripts && npm cache clean --force

RUN echo "-----------PROJECT STRUCTURE-----------"; ls -ltr /usr/src/app/utility; echo "---------------------------------------"
# To bundle your app's source code inside the Docker image,

COPY package.json /usr/src/app
COPY package-lock.json /usr/src/app
COPY app.js /usr/src/app
COPY utility/* /usr/src/app/utility/
COPY node_modules/* /usr/src/app/node_modules/

# Use the node user from the image (instead of the root user)
USER nonroot

FROM node:18-alpine AS PROD

# Copy the bundled code from the PROD_BUILD_INTERMEDIATE stage to the PROD image
COPY --from=PROD_BUILD_INTERMEDIATE /usr/src/app/node_modules /opt/node-sse/node_modules
COPY --from=PROD_BUILD_INTERMEDIATE /usr/src/app/package.json /opt/node-sse
COPY --from=PROD_BUILD_INTERMEDIATE /usr/src/app/package-lock.json /opt/node-sse
COPY --from=PROD_BUILD_INTERMEDIATE /usr/src/app/utility /opt/node-sse/utility
COPY --from=PROD_BUILD_INTERMEDIATE /usr/src/app/app.js /opt/node-sse

RUN apk add --no-cache curl

RUN echo "------------FINAL STRUCTURE------------\n"; ls -ltr /opt/node-sse ; echo "---------------------------------------"

EXPOSE 3000
ENV NODE_ENV=production
ENV AWS_NODEJS_CONNECTION_REUSE_ENABLED=1

WORKDIR /opt/node-sse

CMD ["node", "app.js"]