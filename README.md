
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Pod Rejection Due to Pod Security Policy (PSP) Violation
---

This incident type occurs when a Pod in Kubernetes is rejected due to a violation of the Pod Security Policy (PSP). A Pod Security Policy is a set of rules that specify the conditions that a pod must meet to be accepted and run in a Kubernetes cluster. These rules are designed to prevent security risks and ensure that pods run with the least privilege necessary. When a pod violates the PSP, it is rejected, and the incident is triggered.

### Parameters
```shell
export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export PSP_NAME="PLACEHOLDER"

export SERVICEACCOUNT_NAME="PLACEHOLDER"

export ROLE_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"
```

## Debug

### List all Pods in the Namespace that are in the Pending state
```shell
kubectl get pods -n ${NAMESPACE} --field-selector status.phase=Pending
```

### Get the detailed status of a Pod that was rejected due to a PSP violation
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Check the Pod Security Policy that was violated
```shell
kubectl describe psp ${PSP_NAME}
```

### List all ServiceAccounts in the Namespace that are allowed to use the PSP
```shell
kubectl get psp ${PSP_NAME} -o=jsonpath='{.spec.serviceAccountName}'
```

### Get the detailed status of the ServiceAccount that the Pod is using
```shell
kubectl describe sa ${SERVICEACCOUNT_NAME} -n ${NAMESPACE}
```

### List all Roles that are bound to the ServiceAccount
```shell
kubectl get roles -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.namespace}{"\n"}{end}' --field-selector metadata.annotations.'rbac.authorization.kubernetes.io/autoupdate'='true',metadata.annotations.'rbac.authorization.kubernetes.io/autoupdate-after-anyclean'=true | xargs -n2 sh -c 'kubectl get role $0 -n $1 -o=jsonpath="{.metadata.name}\t{.metadata.namespace}\t{.metadata.annotations}\n"'
```

### Get the detailed status of the Role that the ServiceAccount is bound to
```shell
kubectl describe role ${ROLE_NAME} -n ${NAMESPACE}
```

## Repair

### Check if the pod has any privileged containers running. If yes, remove the privilege from the container, and try to deploy the pod again.
```shell

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


```