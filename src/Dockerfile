FROM archlinux

# TODO: make directory dynamic?
ENV BUILD_DIRECTORY=/build/
COPY ./setup.sh $BUILD_DIRECTORY/setup.sh
COPY ./packages $BUILD_DIRECTORY/packages.sh

RUN sh $BUILD_DIRECTORY/setup.sh

COPY ./post-build.sh $BUILD_DIRECTORY/post-build.sh
ENTRYPOINT ["sh","$BUILD_DIRECTORY/post-build.sh"]

