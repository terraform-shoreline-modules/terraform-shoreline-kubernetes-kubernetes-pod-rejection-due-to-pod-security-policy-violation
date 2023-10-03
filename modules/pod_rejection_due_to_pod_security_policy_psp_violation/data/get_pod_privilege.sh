
#!/bin/bash

# Get pod name

POD_NAME=${POD_NAME}

# Get container name

CONTAINER_NAME=${CONTAINER_NAME}

# Check if container is privileged

PRIVILEGED=$(kubectl get pod $POD_NAME -o jsonpath="{.spec.containers[?(@.name==\"$CONTAINER_NAME\")].securityContext.privileged}")

# If container is privileged, remove privilege

if [[ $PRIVILEGED == "true" ]]; then

    kubectl patch pod $POD_NAME -p '{"spec":{"containers":[{"name": "'"$CONTAINER_NAME"'", "securityContext":{"privileged":false}}]}}'

fi