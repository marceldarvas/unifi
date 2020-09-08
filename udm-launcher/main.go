package main

import (
	"github.com/alecthomas/kong"
	"github.com/boostchicken/udm-launcher/pkg/github"
	"github.com/google/go-github/v32/github"
	"log"
)

var CLI struct {
	Install struct {
		App string `arg name:app help:"App to install"`
	} `cmd help:"Install app"`

	Remove struct {
		App string `arg name:app help:"App to remove" `
	} `cmd help:"Remove app"`

	List struct {
	} `cmd help:"List apps"`
}

func main() {

	ctx := kong.Parse(&CLI, kong.Name("UDM Launcher"),
		kong.Description("Manage UDM Apps"),
		kong.UsageOnError(),
		kong.ConfigureHelp(kong.HelpOptions{
			Compact: true,
			Summary: true,
		}))
	switch ctx.Command() {
	case "install <app>":
		log.Println(CLI.Install.App)
	case "remove <app>":
		log.Println(CLI.Remove.App)
	case "list":
		names, _ := githubClient.GetDirectoryListFromRepo("boostchicken", "udm-utilities", "/", &github.RepositoryContentGetOptions{Ref: "master"})
		for i, name := range names {
			log.Printf("%d - %s", i, name)
		}
	}

}
