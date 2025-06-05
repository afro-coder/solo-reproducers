#!/bin/bash

helm repo add glooe https://storage.googleapis.com/gloo-ee-helm

echo "Go get some coffee"

kind create cluster --name uuid-repro

KIND_CONTEXT="kind-uuid-repro"
GLOO_VERSION="1.17.4"
LICENSE=$GQ

helm install gloo glooe/gloo-ee --debug \
--kube-context $KIND_CONTEXT \
--version $GLOO_VERSION \
--namespace gloo-system \
--create-namespace \
--set-string license_key=$LICENSE \
--values - <<EOF
grafana:
  defaultInstallationEnabled: false
prometheus:
  enabled: false
gloo-fed:
  glooFedApiserver:
    enable: false
  enabled: false
global:
  extensions:
    rateLimit:
      enabled: false
    extAuth:
      enabled: false
gloo:
  discovery:
    enabled: false
  settings:
    disableKubernetesDestinations: true
  gatewayProxies:
    gatewayProxy:
      podTemplate:
        resources:
          limits:
            memory: 300Mi
          requests:
            cpu: 1
            memory: 200Mi
      gatewaySettings:
        customHttpGateway:
          options:
            httpConnectionManagerSettings:
              preserveExternalRequestId: true
              tracing:
                openTelemetryConfig:
                  collectorUpstreamRef:
                    name: opentelemetry-collector
                    namespace: gloo-system
              useRemoteAddress: true
              uuidRequestIdConfig:
                packTraceReason: false
                useRequestIdForTraceSampling: false
EOF
# The tracing part here has no requirement but I'm adding it as we need to check if this works as expected. I'll take the testing part.


echo "Creating the upstream/routes needed"
glooctl create upstream static --name opentelemetry-collector --static-hosts httpbin.org
glooctl create upstream static --name httpbin --static-hosts httpbin.org
glooctl add route -p / -u httpbin

#### Sleep for sometime to let the proxy get the configs.
sleep 3
echo -e "Getting the logs"
kubectl logs -n gloo-system deployment/gateway-proxy --tail=20

echo -e "Getting the config_dump"
kubectl exec deployment/gateway-proxy -n gloo-system -- wget -qO- localhost:19000/config_dump

echo -e "\nRun the following to cleanup the cluster"
echo -e "\nkind delete cluster --name uuid-repro"
