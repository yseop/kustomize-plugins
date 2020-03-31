/*
Copyright 2020 Yseop
SPDX-License-Identifier: MIT

A Kustomize Plugin for Kubesec encrypted resource
*/
package main_test

import (
	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
	"strings"
	"testing"
)

func TestKubesecMissingFiles(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t)
	th.BuildGoPlugin("yseop.com", "v1alpha1", "Kubesec")

	defer th.Reset()

	th.WriteK(`/base/`, `
generators:
  - kubesec.yml
`)
	th.WriteF(`/base/kubesec.yml`, `
---
apiVersion: yseop.com/v1alpha1
kind: Kubesec
metadata:
  name: notImportantHere
`)
	err := th.RunWithErr("/base", th.MakeOptionsPluginsEnabled())
	if err == nil {
		t.Fatalf("Expected error")
	}
	if !strings.Contains(err.Error(), "Missing mandatory list of files") {
		t.Fatalf("Unexpected error %v", err)
	}
}
