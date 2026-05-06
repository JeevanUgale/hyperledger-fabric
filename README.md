#  Hyperledger Fabric on Kubernetes with CI/CD & Monitoring

##  Overview

This project demonstrates an **end-to-end enterprise-grade deployment of a Hyperledger Fabric network on Kubernetes**, integrated with **CI/CD (Jenkins)** and **observability (Prometheus + Grafana)**.

It showcases a **real-world DevOps + Blockchain implementation**, covering network provisioning, automation, and operational visibility.

---

##  Architecture Summary

* **Blockchain Framework:** Hyperledger Fabric (v2.5)
* **Container Orchestration:** Kubernetes (KIND cluster)
* **CI/CD:** Jenkins
* **Monitoring:** Prometheus + Grafana
* **Database:** CouchDB (state database)

---

##  Network Topology

| Component    | Count | Description                      |
| ------------ | ----- | -------------------------------- |
| Organization | 1     | org1                             |
| Fabric CA    | 1     | Identity & certificate authority |
| Orderer      | 1     | Channel ordering service         |
| Peers        | 2     | peer0, peer1                     |
| CouchDB      | 2     | One per peer                     |
| Channel      | 1     | `mychannel`                      |
| Chaincode    | 1     | asset-transfer-basic             |

---

##  Certificate Authority

This setup uses:

 **Fabric CA (not cryptogen)**

* Dynamic identity management
* Supports enrollment & registration
* Production-aligned approach

---

##  Manual Deployment Workflow

### 1️ Environment Setup

* Provisioned VM using Vagrant (Ubuntu 22.04)
* Installed:

  * Docker
  * Kubernetes (KIND)
  * Helm
  * Fabric binaries & images

---

### 2️ Network Configuration

* Kubernetes manifests created for:

  * Orderer
  * Peers
  * CouchDB
* Internal DNS configured:

  ```bash
  org1-peer0.test-network.svc.cluster.local
  ```

---

### 3️ Certificate Generation

* TLS certificates via cert-manager
* Identity certificates via Fabric CA:

  * Bootstrap admin enrollment
  * Org admin registration

---

### 4️ Genesis Block & Channel Config

* Generated using `configtxgen`
* Defined:

  * MSPs
  * Policies
  * Orderer configuration

---

### 5️ Network Deployment

```bash
./network up
```

✔ Creates:

* Namespace
* CA
* Orderer
* Peers
* CouchDB

---

### 6️ Channel Creation

```bash
./network channel create
```

✔ Steps:

* Register & enroll admins
* Generate genesis block
* Join orderer
* Join peers

---

### 7️ Chaincode Deployment

```bash
./network chaincode deploy asset-transfer-basic ../asset-transfer-basic/chaincode-java
```

 Workflow:

* Build Docker image
* Push to local registry
* Package (CCaaS)
* Install on peers
* Approve & commit

---

### 8️ Transaction Testing

#### Invoke

```bash
./network chaincode invoke asset-transfer-basic '{"Args":["InitLedger"]}'
```

#### Query

```bash
./network chaincode query asset-transfer-basic '{"Args":["ReadAsset","asset1"]}'
```

 Output:

```json
{
  "owner": "Tomoko",
  "color": "blue",
  "size": 5,
  "appraisedValue": 300
}
```

---

##  Monitoring Implementation

### Stack Deployed

* Prometheus (via Helm)
* Grafana

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

---

### ServiceMonitor Configuration

Custom ServiceMonitor created to scrape:

* Peers (`operations` port)
* Orderer (`8443`)
* Fabric CA

```yaml
endpoints:
  - port: operations
    path: /metrics
    interval: 15s
```

---

### Metrics Enabled

Configured in components:

```bash
ORDERER_METRICS_PROVIDER=prometheus
CORE_OPERATIONS_LISTENADDRESS=0.0.0.0:9443
```

---

##  CI/CD Implementation

### Tool: Jenkins

Pipeline automates:

1. Infrastructure bootstrap
2. Network deployment
3. Channel creation
4. Chaincode deployment
5. Transaction validation

---

### Pipeline Flow

1. Environment setup
2. Pre-checks
3. Network up
4. Channel create
5. Deploy chaincode
6. Invoke Transaction
7. Query Transaction
---

##  Key Challenges Solved

| Problem                | Solution                                           |
| ---------------------- | -------------------------------------------------- |
| DNS resolution failure | Switched to K8s internal DNS (`svc.cluster.local`) |
| TLS & CA integration   | Used cert-manager + Fabric CA                      |
| Service discovery      | Kubernetes services + ServiceMonitor               |
| SSH issues in Jenkins  | Fixed Vagrant networking & keys                    |
| Metrics visibility     | Enabled Fabric Prometheus endpoints                |

---

##  Key Learnings

* Fabric on Kubernetes requires **DNS consistency**
* Fabric CA is essential for **production-grade identity**
* Observability is critical for blockchain ops
* CI/CD pipelines can fully automate blockchain lifecycle

---

##  Future Enhancements

* Multi-org network (Org2, Org3)
* GitOps with ArgoCD
* Advanced alerting (Alertmanager)
* DevSecOps integration (image scanning)
* External access via Ingress + TLS

---

##  Conclusion

This project demonstrates a **complete lifecycle of blockchain deployment** integrated with:

* DevOps practices
* CI/CD automation
* Monitoring & observability

It reflects a **production-aligned architecture** rather than a basic lab setup.

---
