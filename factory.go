package openhorizon

import (
	"context"
	"fmt"
	"os"

	"github.com/hashicorp/vault/sdk/logical"
)

func Factory(ctx context.Context, c *logical.BackendConfig) (logical.Backend, error) {
	o := OHAuthPlugin(c)
	if err := o.Setup(ctx, c); err != nil {
		return nil, err
	}

	if o.Logger().IsInfo() {
		o.Logger().Info(ohlog(fmt.Sprintf("initializing, env vars are: %v", os.Environ())))
	}

	return o, nil
}
