# Chart: `hub-platform-day2`

Optional hub-wide configuration driven by **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`** (`hubPlatform` key).

## Contents

- **`hubPlatform.proxy`** — When `enabled: true`, renders `config.openshift.io/v1` **`Proxy`** named **`cluster`**.
- **`hubPlatform.trustedCA`** — When `enabled: true` and `bundlePem` is set, creates **`ConfigMap`** `trustedCA.name` in **`openshift-config`**.
- **`hubPlatform.apiServer`** — When **`enabled: true`** and **`namedCertificates`** is non-empty, patches **`APIServer`** **`cluster`** (`operator.openshift.io/v1`) with **`spec.servingCerts.namedCertificates`**. Each entry lists **`names`** (SANs/hostnames) and **`secretName`** for a TLS secret in **`openshift-config`** (`tls.crt`, `tls.key`; see OpenShift *Configuring certificates* → API server named certificates).
- **`hubPlatform.ingressController`** — When **`enabled: true`** and **`defaultCertificate.secretName`** is set, patches **`IngressController`** **`metadata.name`** (default **`default`**) in **`openshift-ingress-operator`** with **`spec.defaultCertificate.name`** pointing at a TLS secret in **`openshift-ingress`**.

Create TLS secrets outside this chart (Vault, cert-manager, SealedSecrets, `oc create secret tls`, etc.) before enabling these flags.

The chart always emits a small sentinel **`ConfigMap`** (`summit-hub-platform-day2-sentinel`) in **`openshift-config`** so OpenShift GitOps always has a manifest to reconcile when optional features are off.

### GitOps note (`IngressController`)

The **`IngressController`** manifest sets **`metadata.namespace: openshift-ingress-operator`**. Ensure your OpenShift GitOps **`AppProject`** allows deploying to that namespace (the **`app-hub-platform-day2`** application targets **`openshift-config`**; cluster-scoped and explicitly-namespaced resources still sync when permitted).

## GitOps

OpenShift GitOps Application: [managed-applications/templates/application-hub-platform-day2.yaml](../../managed-applications/templates/application-hub-platform-day2.yaml) — `path: hub-clusters/day2/applications/hub-platform-day2`, `destination.namespace: openshift-config`.

## Example (`99-environments` fragment)

```yaml
hubPlatform:
  apiServer:
    enabled: true
    namedCertificates:
      - names:
          - api.cluster.example.com
        secretName: apiserver-custom-tls   # Secret in openshift-config
  ingressController:
    enabled: true
    name: default
    defaultCertificate:
      secretName: router-certs-default    # Secret in openshift-ingress
```

## Local render

```bash
helm template hub-platform-day2 ./hub-clusters/day2/applications/hub-platform-day2 \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml
```
