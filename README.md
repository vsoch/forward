# forward

## What is this?

Forward sets up an sbatch script on sherlock and port forwards it back to your local machine! 

Useful for jupyter notebook and tensorboard, amongst other things.

## Setup

Clone this repository to your local machine.

You will then need to create a parameter file.  To do so, follow the prompts at:

`bash setup.sh`

You can always edit params.sh later to change these configuration options.

### SSH config

You will also need to at the minimum configure your ssh to recognize sherlock as
a valid host.  We have provided a [hosts folder](hosts)  for helper scripts that will generate
recommended ssh configuration snippets to put in your `~/.ssh/config` file. Based
on the name of the folder, you can intuit that the configuration depends on the cluster
host. Here is how you can generate this configuration for Sherlock:

```bash
bash hosts/sherlock_ssh.sh
```
```
Host sherlock
    User put_your_username_here
    Hostname sh-ln01.stanford.edu
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%l%r@%h:%p
```

Using these options can reduce the number of times you need to authenticate. If you
don't have a file in the location `~/.ssh/config` then you can generate it programatically:

```bash
bash hosts/sherlock_ssh.sh >> ~/.ssh/config
```

Do not run this command if there is content in the file that you might overwrite! 
One downside is that you will be foregoing sherlock's load
balancing since you need to be connecting to the same login machine at each
step.

### Notebook password

If you have not set up notebook authentication before, you will need to set a
password via `jupyter notebook password` on sherlock.  Make sure to pick a
secure password!


## Usage

To start a jupyter notebook in a specific directory:

`bash start.sh jupyter /path/to/dir`

To start tensorboarrd in a specific directory:

`bash start.sh start /path/to/dir`

To stop the running jupyter notebook server:

`bash end.sh jupyter`

If the sbatch job is still running, but your port forwarding stopped (e.g. if
your computer went to sleep), you can resume with:

`bash resume.sh jupyter`

### Connection refused after start.sh finished

Sometimes you can get connection refused messages after the script has started
up.  Just wait up to a minute and then refresh the opened web page, and this
should fix the issue.

## Adding new sbatch scripts

You can add more sbatch scripts by putting them in the sbatches directory.
