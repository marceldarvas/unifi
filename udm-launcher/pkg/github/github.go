package githubClient

import (
	"context"
	"github.com/google/go-github/v32/github"
	"log"
	"sync"
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

	go func() {
		for s := range c {
			names = append(names, s)
		}
	}()
	var wg = sync.WaitGroup{}
	for _, directory := range directories {
		if *directory.Type == "dir" {
			wg.Add(1)
			go func(directoryName string, group *sync.WaitGroup) {
				if CheckForFile(owner, repo, path+directoryName+"/install.udm.pkg", opts) {
					c <- path + directoryName
				}
				wg.Done()
			}(*directory.Name, &wg)
		}
	}
	wg.Wait()
	close(c)

	return names, nil
}

func CheckForFile(owner string, repo string, path string, opts *github.RepositoryContentGetOptions) bool {
	file, _, _, err := client.Repositories.GetContents(context.Background(), owner, repo, path, opts)
	if err != nil || file == nil {
		return false
	}
	return true
}

func GetFileContents(owner string, repo string, path string, opts *github.RepositoryContentGetOptions) (string, error) {
	file, _, _, err := client.Repositories.GetContents(context.Background(), owner, repo, path, opts)
	if err != nil || file == nil {
		log.Fatalf("unable to read %s/%s:%s", repo, path, opts.Ref)
	}
	return file.GetContent()
}
