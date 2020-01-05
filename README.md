# git-terraform-commit

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

This module creates git commits using Terraforms `local_file` and `null_resource`. 
To connect to the git repository a SSH-Key is required. The path to the key file can be specified using `ssh_key_path`.
We also support changing the base_url to the git remote. The default is `github.com`.

### Usage

```hcl
module "repository" {
  source           = "git::https://github.com/goci-io/git-terraform-commit.git?ref=tags/<latest-version>"
  git_repository   = "goci-repository-setup-example"
  git_organization = "goci-io"
  message          = "[goci] add initial README.md"
  branch           = "test-git-terraform-commits-module"
  changes          = false
  paths            = {
    "example/README.md" = {
      target = "README.md"
      data   = {
        example_var = "Example repository description"
      }
    }
  }
}
```

There is no need to configure a git provider with Terraform. The git remote is configured via `git_base_url` and the provided key file located at `ssh_key_path`. 
An example commit, created based on the [terraform.tfvars](https://github.com/goci-io/git-terraform-commit/tree/master/terraform.tfvars.example), can be viewed [here](https://github.com/goci-io/goci-repository-setup-example/compare/test-git-terraform-commits-module?expand=1).

**Do not** put files into a subdirectory called `repository` as these files will also be checked in as they are and may cause other git errors.
