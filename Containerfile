# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files
COPY files/scripts /build_files
COPY cosign.pub /cosign.pub

# Base Image
FROM quay.io/almalinuxorg/almalinux-bootc:10-kitten@sha256:c772a78339d77b55de9bc3fe739f227cd73cf9f832450e6d7cf8137ee729f387

ARG IMAGE_NAME
ARG IMAGE_REGISTRY

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
