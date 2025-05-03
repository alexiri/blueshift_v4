#!/usr/bin/env bash

set -xeuo pipefail

# If we can't find the cosign public key, there's nothing to set up.
if [ ! -f /ctx/cosign.pub ]; then
    echo "Cosign public key not found, skipping setup."
    exit 0
fi

CONTAINER_DIR="/etc/containers"
CONTAINER_PKI="/etc/pki/containers"
IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"

mkdir -p $CONTAINER_PKI
cp /ctx/cosign.pub ${CONTAINER_PKI}/${IMAGE_NAME_FILE}.pub

POLICY_FILE="${CONTAINER_DIR}/policy.json"

# We need to add our cosign public key to the policy file and make sure
# that the default policy is set to reject.
jq --arg image_registry "${IMAGE_REGISTRY}" \
   --arg image_name "${IMAGE_NAME}" \
   --arg pki_path "${CONTAINER_PKI}/${IMAGE_NAME_FILE}.pub" \
   '.transports.docker |=
    { ($image_registry + "/" + $image_name): [
        {
            "type": "sigstoreSigned",
            "keyPath": $pki_path,
            "signedIdentity": {
                "type": "matchRepository"
            }
        }
    ] }
    + .
    | .default[0].type = "reject"' "${POLICY_FILE}" > "/tmp/POLICY.tmp"

mv "/tmp/POLICY.tmp" "${POLICY_FILE}"

cat <<EOF > "${CONTAINER_DIR}/registries.d/${IMAGE_REGISTRY##*/}-${IMAGE_NAME_FILE}.yaml"
docker:
  ${IMAGE_REGISTRY}/${IMAGE_NAME}:
    use-sigstore-attachments: true
EOF
