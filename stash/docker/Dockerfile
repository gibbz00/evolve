FROM archlinux

# TODO: make directory dynamic?
ENV BUILD_DIRECTORY=/build/
COPY ./setup.sh $BUILD_DIRECTORY/setup.sh
COPY ./packages $BUILD_DIRECTORY/packages

RUN sh $BUILD_DIRECTORY/setup.sh

COPY ./post-build.sh $BUILD_DIRECTORY/post-build.sh
# TODO: make dynamic, ENV variable must be passed to the .bashrc of the builder user
ENTRYPOINT ["sh","/buld/post-build.sh"]

