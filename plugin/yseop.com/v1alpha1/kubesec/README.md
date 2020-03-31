# Kubesec

This _kustomize_ plugin reveals data encrypted by [kubesec](https://github.com/shyiko/kubesec) and outputs their content.

## Prerequisites
  - kustomize 3.5.4
  - kubesec 0.9.2

## Usage
```bash
gpg --import <gpg_key>.asc # Public and private key used for file encryption/decryption

export XDG_CONFIG_HOME=`pwd`
mkdir -p $XDG_CONFIG_HOME/yseop.com/v1alpha1/kubesec
make
cp -p Kubesec.so $XDG_CONFIG_HOME/yseop.com/v1alpha1/kubesec

$GOPATH/bin/kustomize build /some/path --enable_alpha_plugins
```

_Kustomize_ directory layout:
```bash
    /
    └── some
        └── path
            ├── secret.yml          # GPG encrypted file
            ├── kubesec.yml
            ├── kustomization.yml
            └── another_secret.yml  # File with GPG encrypted data
```

_kustomization.yml_:
```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

generators:
  - kubesec.yml
```

_kubesec.yml_
```yaml
---
apiVersion: yseop.com/v1alpha1
kind: Kubesec
metadata:
  name: notImportantHere
files:
  - secret.yml
  - another_secret.yml
```

This will output something like
```yaml
apiVersion: v1
data:
  password: dGVzdDI=
kind: Secret
metadata:
  creationTimestamp: null
  name: another_secret
---
apiVersion: v1
data:
  password: dGVzdA==
kind: Secret
metadata:
  creationTimestamp: null
  name: secret

```
## Options
  - **files**: List of files containing encrypted data via _Kubesec_
  - **behavior**: create, merge or replace. Default: create. (Optional)

## Known limitation
  - Only works with PGP. No Google Cloud KMS. No AWS KMS.

## Todo
  - Enable Google Cloud KMS to be provided.
  - Enable AWS KMS to be provided.
  - Increase unit-test coverage.

## Unit Tests
```bash
make unit-test
```

## References
 - [kustomize plugins - Go plugins](https://github.com/kubernetes-sigs/kustomize/tree/master/docs/plugins#go-plugins)
 - [kustomize-sops](https://github.com/viaduct-ai/kustomize-sops)
 - [sopsencodedsecrets](https://github.com/monopole/sopsencodedsecrets)
 - [Extending Kustomize to pull secrets from Vault](https://medium.com/@iliazlobin/extending-kustomize-to-pull-secrets-from-vault-80e119890cae)
