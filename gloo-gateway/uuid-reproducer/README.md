
## uuidRequestIdConfig Replication

This repo shows how to replicate the bug encountered while setting `uuidRequestIdConfig` in Gloo Edge 1.17.4 

The reason for using this option is to disable envoy from modifying the trace `x-request-id`, as mentioned [here](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/request_id/uuid/v3/uuid.proto#envoy-v3-api-field-extensions-request-id-uuid-v3-uuidrequestidconfig-pack-trace-reason)

### Prequisites
- kind
- glooctl
- kubectl
- helm
- docker

To initiate the reproducer, simply clone the repo and run 
```
bash deploy.sh
```
Modify the file and Add your license key Variable in the helm command.

That will create a kind cluster, install gloo-ee with the version specified in the deploy.sh file.

The reproducer automatically shows you the last 20 lines of logs and takes the config_dump to show you the error here.

```
Errors from the pod

[2025-06-05 15:12:21.942][1][warning][config] [external/envoy/source/extensions/config_subscription/grpc/grpc_subscription_impl.cc:138] gRPC config for type.googleapis.com/envoy.config.listener.v3.Listener rejected: Error adding/updating listener(s) listener-::-8080: Didn't find a registered implementation for type: 'hcm.options.gloo.solo.io.HttpConnectionManagerSettings.UuidRequestIdConfigSettings'


Getting the config_dump
Failed to convert protobuf message to JSON string: INVALID_ARGUMENT: could not find @type 'type.googleapis.com/hcm.options.gloo.solo.io.HttpConnectionManagerSettings.UuidRequestIdConfigSettings
```
