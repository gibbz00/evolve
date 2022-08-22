FROM archlinux

# TODO: make directory dynamic?
ENV BUILD_DIRECTORY=/tmp/build/
COPY ./setup.sh $BUILD_DIRECTORY/setup.sh
COPY ./packages $BUILD_DIRECTORY/packages

RUN sh $BUILD_DIRECTORY/setup.sh
