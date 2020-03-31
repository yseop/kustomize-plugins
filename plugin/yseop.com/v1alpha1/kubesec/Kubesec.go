/*
Copyright 2020 Yseop
SPDX-License-Identifier: MIT

A Kustomize Plugin for Kubesec encrypted resource
*/
package main

import (
	"fmt"
	"github.com/pkg/errors"
	kubesec "github.com/shyiko/kubesec/cmd"
	"path/filepath"
	"sigs.k8s.io/kustomize/api/ifc"
	"sigs.k8s.io/kustomize/api/resmap"
	"sigs.k8s.io/kustomize/api/resource"
	"sigs.k8s.io/kustomize/api/types"
	"sigs.k8s.io/yaml"
)

//noinspection GoUnusedGlobalVariable
//nolint: golint
var KustomizePlugin plugin

type plugin struct {
	h        *resmap.PluginHelpers
	rsf      *resource.Factory
	ldr      ifc.Loader

	Behavior string   `json:"behavior,omitempty" yaml:"behavior,omitempty"`
	Files    []string `json:"files,omitempty" yaml:"files,omitempty"`
	Keys     []string `json:"keys,omitempty" yaml:"keys,omitempty"`
}

func (p *plugin) Config(h *resmap.PluginHelpers, c []byte) (err error) {
	p.Behavior = ""
	p.Files = nil
	p.Keys = nil

	p.h = h
	p.ldr = h.Loader()
	p.rsf = h.ResmapFactory().RF()

	return yaml.Unmarshal(c, p)
}

func (p *plugin) Generate() (resmap.ResMap, error) {
	resMap := resmap.New()

	if p.Files == nil {
		return nil, fmt.Errorf("Missing mandatory list of files")
	}

	for _, file := range p.Files {
		f := filepath.Join(p.ldr.Root(), file)

		bytes, err := p.ldr.Load(f)
		if err != nil {
			return nil, errors.Wrapf(err, "Failed to read file %s", file)
		}

		decrypted, _, err := kubesec.Decrypt(bytes)
		if err != nil {
			return nil, errors.Wrapf(err, "Failed to decrypt file %s", file)
		}

		res, err := p.rsf.FromBytes(decrypted)
		if err != nil {
			return nil, errors.Wrapf(err, "Failed to unmarshall resource from bytes %s", res)
		}

		if p.Behavior != "" {
			res.SetOptions(types.NewGenArgs(
				&types.GeneratorArgs{Behavior: p.Behavior},
			        &types.GeneratorOptions{DisableNameSuffixHash: true}))
		}
		resMap.Append(res)
	}

	return resMap, nil
}

func main() {}
