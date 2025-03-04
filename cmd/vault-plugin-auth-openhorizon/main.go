package main

import (
	"log"
	"os"

	"github.com/hashicorp/vault/api"
	"github.com/hashicorp/vault/sdk/plugin"
	openhorizon "github.com/open-openhorizon/vault-plugin-auth-openhorizon"
)

// This plugin provides authentication support for openhorizon users within bao.
//
// It uses OpenBao's framework to interact with the plugin system.
//
// This plugin must be configured by a bao admin through the /config API. Without the config, the plugin
// is unable to function properly.

func main() {
	apiClientMeta := &api.PluginAPIClientMeta{}
	flags := apiClientMeta.FlagSet()
	flags.Parse(os.Args[1:])

	tlsConfig := apiClientMeta.GetTLSConfig()
	tlsProviderFunc := api.VaultPluginTLSProvider(tlsConfig)

	err := plugin.Serve(&plugin.ServeOpts{
		BackendFactoryFunc: openhorizon.Factory,
		TLSProviderFunc:    tlsProviderFunc,
	})

	if err != nil {
		log.Fatal(err)
	}
}
