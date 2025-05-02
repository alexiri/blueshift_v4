# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY system_files /system_files
COPY build_files /build_files

# Base Image
FROM quay.io/almalinuxorg/almalinux-bootc:10-kitten@sha256:e9da87507fe7840baf11072207f018e53e14011ee2e4ea74b3fcdb0b2b731a62

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
