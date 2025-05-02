FROM scratch AS ctx

COPY build_files /build_files

FROM quay.io/almalinuxorg/almalinux-bootc:10-kitten

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
