// +build tools

package tools

// There may be a better way to do this in the future.
// https://github.com/golang/go/issues/25922
import (
	_ "arp242.net/goimport"
	_ "github.com/110y/goreturn"
	_ "github.com/fatih/gomodifytags"
	_ "github.com/fatih/motion"
	_ "github.com/koron/iferr"
	_ "golang.org/x/tools/cmd/goimports"
	_ "golang.org/x/tools/cmd/gopls"
	_ "golang.org/x/tools/cmd/gorename"
	_ "golang.org/x/tools/cmd/guru"
	// See https://github.com/golang/go/issues/24661
	// "github.com/davidrjenni/reftools/cmd/fillstruct"
	// "github.com/josharian/impl"
	// "honnef.co/go/tools/cmd/keyify"
	// "github.com/koron/iferr"
)
