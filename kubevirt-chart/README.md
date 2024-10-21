# kubevirt

![Version: 1.3.1](https://img.shields.io/badge/Version-1.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.3.1](https://img.shields.io/badge/AppVersion-v1.3.1-informational?style=flat-square)

KubeVirt is a Kubernetes extension for running virtual machines alongside container workloads.

**Homepage:** <https://kubevirt.io/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| hventura | <hventura@whitestack.com> |  |

## Source Code

* <https://github.com/kubevirt/kubevirt>

## Requirements

Kubernetes: `>=1.22.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubernetesClusterDomain | string | `"cluster.local"` |  |
| operator.serviceAccount.annotations | object | `{}` |  |
| virtOperator.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| virtOperator.podSecurityContext.runAsNonRoot | bool | `true` |  |
| virtOperator.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| virtOperator.replicas | int | `2` |  |
| virtOperator.virtOperator.args[0] | string | `"--port"` |  |
| virtOperator.virtOperator.args[1] | string | `"8443"` |  |
| virtOperator.virtOperator.args[2] | string | `"-v"` |  |
| virtOperator.virtOperator.args[3] | string | `"2"` |  |
| virtOperator.virtOperator.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| virtOperator.virtOperator.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| virtOperator.virtOperator.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| virtOperator.virtOperator.env.kubevirtVersion | string | `"v1.3.1"` |  |
| virtOperator.virtOperator.env.virtOperatorImage | string | `"quay.io/kubevirt/virt-operator:v1.3.1"` |  |
| virtOperator.virtOperator.image.repository | string | `"quay.io/kubevirt/virt-operator"` |  |
| virtOperator.virtOperator.image.tag | string | `"v1.3.1"` |  |
| virtOperator.virtOperator.imagePullPolicy | string | `"IfNotPresent"` |  |
| virtOperator.virtOperator.resources.requests.cpu | string | `"10m"` |  |
| virtOperator.virtOperator.resources.requests.memory | string | `"450Mi"` |  |

