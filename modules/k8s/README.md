### Installing the Action Runner Controller
creating GitHub personal access token (PAT) for using by self-hosted runner make sure the following scopes are selected:

repo (all)
admin:org (all) (mandatory for organization-wide runner)
admin:public_key - read:public_key
admin:repo_hook - read:repo_hook
admin:org_hook
notifications
workflow
Also, when creating a PAT for self-hosted runner which will process events from several repositories of the particular organization, create the PAT using organization owner account. Otherwise your new PAT will not have sufficient privileges for all repositories.

```shell
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update
helm upgrade --install --namespace actions-runner-system --create-namespace --set=authSecret.create=true --set=authSecret.github_token="<your-PAT>"  --wait actions-runner-controller actions-runner-controller/actions-runner-controller
```
