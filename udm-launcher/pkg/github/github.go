package githubClient

import (
	"context"
	"github.com/google/go-github/v32/github"
)

var (
	client = github.NewClient(nil)
)

func GetDirectoryListFromRepo(owner string, repo string, path string, opts *github.RepositoryContentGetOptions) ([]string, error) {
	var names []string

	_, directories, _, err := client.Repositories.GetContents(context.Background(), owner, repo, path, opts)
	if err != nil {
		return nil, err
	}
	c := make(chan string)

	for _, directory := range directories {
		go func() {
			if CheckForFile(owner, repo, path+"/"+*directory.Name+"/README.md", opts) {
				c <- *directory.Name
			}
		}()
	}
	close(c)
	for s := range c {
		names = append(names, s)
	}
	return names, nil
}

func CheckForFile(owner string, repo string, path string, opts *github.RepositoryContentGetOptions) bool {
	file, _, _, err := client.Repositories.GetContents(context.Background(), owner, repo, path, opts)
	if err != nil || file == nil {
		return false
	}
	return true
}
