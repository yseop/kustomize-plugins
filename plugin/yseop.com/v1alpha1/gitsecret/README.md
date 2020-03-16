# Git secret

This kustomize plugin reveals files encrypted by git-secret and outputs their content.

## Prerequisites
  - kustomize 3.5.4
  - git-secret 0.3.2

## Usage
```bash
export KUSTOMIZE_VERSION=3.5.4
export GITSECRET_VERSION=0.3.2
export XDG_CONFIG_HOME=`pwd`
make
gpg --import <gpg_key>.asc # Private key used for encrypting files
./bin/kustomize build /some/path --enable_alpha_plugins
```

_Kustomize_ directory layout:
```bash
    /
    └── some
        └── path
            ├── another_secret.yml.secret # GPG encrypted file
            ├── gitsecret.yml
            ├── kustomization.yml
            └── secret.yml.secret         # GPG encrypted file
```

_kustomization.yml_:
```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

generators:
  - gitsecret.yml
```

_gitsecret.yml_
```yaml
---
apiVersion: yseop.com/v1alpha1
kind: GitSecret
metadata:
  name: notImportantHere
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
## Known limitation
  - Encrypted file extension (`.secret`)
  - No YAML merging
  - No YAML overriding

## Tests
```bash
export KUSTOMIZE_VERSION=3.5.4
export GITSECRET_VERSION=0.3.2
export XDG_CONFIG_HOME=`pwd`
make git-secret
make git-secret-test
```
