FROM archlinux

# TODO: make directory dynamic?
ENV BUILD_DIRECTORY=/build/
COPY ./setup.sh $BUILD_DIRECTORY/
COPY ./packages $BUILD_DIRECTORY/

RUN sh $BUILD_DIRECTORY/setup.sh

COPY ./post-build.sh $BUILD_DIRECTORY/
ENTRYPOINT ["sh","$BUILD_DIRECTORY/post-build.sh"]

