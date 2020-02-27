# Kuberbetes example chat

![https://github.com/OktaySavdi/kubernetes_chat_example](https://user-images.githubusercontent.com/3519706/75439435-d731ec00-596a-11ea-80f7-d641d1d5aab9.png)

Integration of the chat application prepared with asp .net core on Kubernet with all open source products is provided.

Code repo for image  [github\dotnet-example](https://github.com/OktaySavdi/chat_example)

## [](https://github.com/OktaySavdi/kubernetes_chat_example)Tools & technologies used

1.  Asp .Net Core
2.  Elasticsearch
3. Fluentd
4.  Redis
5.  RabbitMQ
6.  Docker
7. Kubernetes

## [](https://github.com/OktaySavdi/kubernetes_chat_example) Required

-   Docker
-   Kubernetes
-   Ingress Controller

## [](https://github.com/OktaySavdi/kubernetes_chat_example) We used on Kubernetes

 1. Probe (liveness,readness)
 2. Config (servername,port)
 3. Secret (user_name,password)
 4. Environment
 5. Fluentd sidecar injection on pods
 6. Resource
 7. Strategy

## [](https://github.com/OktaySavdi/kubernetes_chat_example) Install

Give execute permission for install.sh

    chmod +x install.sh

Install example

    ./install.sh

Call URL
```json
http://[NodeIP]/chat
http://chat.10.10.10.10.nip.io/chat
```
## [](https://github.com/OktaySavdi/kubernetes_chat_example) Control
**Elasticsearch**
```json
KibanaPASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)

curl -u "elastic:$KibanaPASSWORD" -k "https://10.96.175.207:9200"
  ``` 
**Redis**
```json
kubectl exec -it $(kubectl get po -l run=redis -o jsonpath='{.items[*].metadata.name}') -- redis-cli client list
  ```
**RabbitMQ**
```json
http://[NodeIP]
http://rabbit.10.10.10.10.nip.io
  ```
  
**Kibana**
```json
http://[NodeIP]
http://kibana.10.10.10.10.nip.io
  ```

## [](https://github.com/OktaySavdi/kubernetes_chat_example) Screen
**Chat** 

![https://github.com/OktaySavdi/kubernetes_chat_example](https://user-images.githubusercontent.com/3519706/75439673-4c9dbc80-596b-11ea-8ae6-069801dddb1e.png)

**Message**
![https://github.com/OktaySavdi/kubernetes_chat_example](https://user-images.githubusercontent.com/3519706/75439713-5e7f5f80-596b-11ea-98c5-5b3179921afb.png)

**Elastic Log**
![https://github.com/OktaySavdi/kubernetes_chat_example](https://user-images.githubusercontent.com/3519706/75439741-6b9c4e80-596b-11ea-9f77-cc0726936f52.png)

**Health**
![https://github.com/OktaySavdi/kubernetes_chat_example](https://user-images.githubusercontent.com/3519706/75439765-7b1b9780-596b-11ea-8cfe-a0ef39c14cfc.png)
