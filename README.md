# forward

## What is this?

Forward sets up an sbatch script on sherlock and port forwards it back to your local machine! 

Useful for jupyter notebook and tensorboard, amongst other things.

## Setup
For interested users, a few tutorials are provided:

 - [sherlock jupyter](https://vsoch.github.io/lessons/sherlock-jupyter/) 
 - [sherlock tensorflow](https://vsoch.github.io/lessons/jupyter-tensorflow/)
 - [sherlock singularity jupyter](https://vsoch.github.io/lessons/sherlock-singularity)

Brief instructions are also documented in this README. Note that if you use a Singularity container,
you don't need to set up a password on Sherlock (it will be generated for you on the fly).

### Clone the Repository
Clone this repository to your local machine.

You will then need to create a parameter file.  To do so, follow the prompts at:

`bash setup.sh`

You can always edit params.sh later to change these configuration options. 

#### Parameters

 - **PARTITION** If you intend to use a GPU (e.g., [sbatches/py2-tensorflow.sbatch](sbatches/py2-tensorflow.sbatch) the name of the PARTITION variable should be "gpu."

If you want to modify the partition flag to have a different gpu setup (other than `--partition gpu --gres gpu:1`) then you should set this **entire** string for the partition variable.

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

To start a jupyter notebook with tensorflow in a specific directory:

`bash start.sh py2-tensorflow /path/to/dir`

If you want a GPU node, make sure your partition is set to "gpu." 

To start a jupyter notebook (via a Singularity container!) in a specific directory:

`bash start.sh singularity-jupyter /path/to/dir`

Want to create your own Singularity jupyter container? Use [repo2docker](https://www.github.com/jupyter/repo2docker) and then specify the container URI at the end:

`bash start.sh singularity.jupyter /path/to/dir <container>`

You can also run a general singularity container!

`bash start.sh singularity /path/to/dir <container>`

To start tensorboard in a specific directory (careful here and not recommended, as is not password protected):

`bash start.sh start /path/to/dir`

To stop the running jupyter notebook server:

`bash end.sh jupyter`

If the sbatch job is still running, but your port forwarding stopped (e.g. if
your computer went to sleep), you can resume with:

`bash resume.sh jupyter`

## Debugging
Along with some good debugging notes [here](https://vsoch.github.io/lessons/jupyter-tensorflow#debugging), common errors are below.

### Connection refused after start.sh finished

Sometimes you can get connection refused messages after the script has started
up.  Just wait up to a minute and then refresh the opened web page, and this
should fix the issue.

### Terminal Hangs when after start.sh

Sometimes when you have changes in your network, you would need to reauthenticate.
In the same way you might get a login issue here, usually opening a new shell resolves 
the hangup.

### Terminal Hangs on "== Checking for previous notebook =="

This is the same bug as above - this command specifically is capturing output into
a variable, so if it hangs longer than 5-10 seconds, it's likely hit the password 
prompt and would hang indefinitely. If you issue a standard command that will
re-prompt for your password in the terminal session, you should fix the issue.

```bash
$ ssh sherlock pwd
```

### slurm_load_jobs error: Socket timed out on send/recv operation 

[This error](https://www.rc.fas.harvard.edu/resources/faq/slurm-errors-socket-timed-out) is basically
saying something to the effect of "slurm is busy, try again later." It's not an issue with submitting
the job, but rather a ping to slurm to perform the check. In the case that the next ping continues, you should be ok. However, if the script is terminate, while you can't control the "busyness" of slurm, you **can**
control how likely it is to be allocated a node, or the frequency of checking. Thus, you can do either of the
following to mitigate this issue:

**choose a partition that is more readily available**

In your params.sh file, choose a partition that is likely to be allocated sooner, thus reducing the 
queries to slurm, and the chance of the error.

**offset the checks by changing the timeout between attempts**

The script looks for an exported variable, `TIMEOUT` and sets it to be 1 (1 second) if
not defined. Thus, to change the timeout, you can export this variable:

```bash
export TIMEOUT=3
```

While the forward tool cannot control the busyness of slurm, these two strategies should help a bit.

### I ended a script, but can't start

As you would kill a job on Sherlock and see some delay for the node to come down, the
same can be try here! Try waiting 20-30 seconds to give the node time to exit, and try again.


## How do I contribute?

First, please read the [contributing docs](CONTRIBUTING.md). Generally, you will want to:

 - fork the repository to your username
 - clone your fork
 - checkout a new branch for your feature, commit and push
 - add your name to the CONTRIBUTORS.md
 - issue a pull request!

## Adding new sbatch scripts

You can add more sbatch scripts by putting them in the sbatches directory.
