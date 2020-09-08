package main

import (
	"github.com/alecthomas/kong"
	"github.com/boostchicken/udm-launcher/pkg/github"
	"github.com/google/go-github/v32/github"
	"log"
	"os/exec"
	"strings"
)

var (
	CLI struct {
		Install struct {
			App string `arg name:app help:"App to install"`
		} `cmd help:"Install app"`

		Remove struct {
			App string `arg name:app help:"App to remove" `
		} `cmd help:"Remove app"`

		List struct {
		} `cmd help:"List apps"`
	}
)

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
		contents, err := githubClient.GetFileContents("boostchicken", "udm-utilities", CLI.Install.App+"/install.udm.pkg", &github.RepositoryContentGetOptions{Ref: "package-manager"})
		if err != nil {
			log.Printf("%s not found", CLI.Install.App)
		}
		split := strings.Split(contents, "\n")
		for _, s := range split {
			if len(s) < 1 {
				break
			}
			cmd := exec.Command(s)
			stdout, err := cmd.Output()
			if err != nil {
				log.Println(err.Error())
			}
			log.Println(string(stdout))
		}
	case "remove <app>":
		fallthrough
	case "list":
		names, _ := githubClient.GetDirectoryListFromRepo("boostchicken", "udm-utilities", "", &github.RepositoryContentGetOptions{Ref: "package-manager"})
		for _, name := range names {
			log.Printf("%s", name)
		}
	}

}
