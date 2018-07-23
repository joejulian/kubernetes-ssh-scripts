# kubernetes-ssh-scripts

A highly opinionated set of bash scripts for deploying kubernetes on a set of machines.

## Getting Started

### Prerequisites

This project requires:

* `cfssl`
* `jq`
* `ssh`

Additionally, there must be nodes booted up, and running sshd with a username that has the ability to sudo and that can be accessed by ssh key.

### Configuration

Configuring `~/.ssh/config` is an exercise left to the user. For the hosts you've provisioned above, you should be able to `ssh $host` and be presented with a shell.

### Execution

Execute local scripts

```bash
local/run.sh $(jq -c "" example.json)
```