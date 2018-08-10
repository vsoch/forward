# forward

## What is this?

Forward sets up an sbatch script on your cluster resource and port forwards it back to your local machine! 
Useful for jupyter notebook and tensorboard, amongst other things.

 - **start.sh** is intended for submitting a job and setting up ssh forwarding
 - **start-node.sh** will submit the job and give you a command to ssh to the node, without port forwarding

The folder [sbatches](sbatches) contains scripts, organized by cluster resource, that are intended
for use and submission. It's up to you to decide if you want a port forwarded (e.g., for a jupyter notebook)
or just an instruction for how to connect to a running node with your application.

## Tiny Tutorials
Here we will provide some "tiny tutorials" to go along with helping to use the software. These are tiny because there
are many possible use cases!

 - [Using sherlock/py3-jupyter](https://gist.github.com/vsoch/f2034e2ff768de7eb14d42fef92cc43e) and copying notebook first from your host to use a notebook module (python 3) on the Sherlock cluster at Stanford [Version 0.0.1](https://github.com/vsoch/forward/releases/tag/0.0.1).
 - [Using containershare with repo2docker-julia](https://vsoch.github.io/lessons/containershare) a repo2docker-julia Singularity container deployed on Sherlock using [Version 0.0.1](https://github.com/vsoch/forward/releases/tag/0.0.1)

## Setup
For interested users, a few tutorials are provided on the [Research Computing Lessons](https://vsoch.github.io/lessons) site.
Brief instructions are also documented in this README. 

### Clone the Repository
Clone this repository to your local machine.

You will then need to create a parameter file.  To do so, follow the prompts at:

```bash
bash setup.sh
```

You can always edit `params.sh` later to change these configuration options. 

#### Parameters

 - **RESOURCE** should refer to an identifier for your cluster resource that will be recorded in your ssh configuration, and then referenced in the scripts to interact with the resource (e.g., `ssh sherlock`).
 - **PARTITION** If you intend to use a GPU (e.g., [sbatches/py2-tensorflow.sbatch](sbatches/py2-tensorflow.sbatch) the name of the PARTITION variable should be "gpu."
 - **CONTAINERSHARE** (optional) is a location on your cluster resource (typically world readable) where you might find containers (named by a hash of the container name in the [library]() that are ready to go! If you are at Stanford, leave this to be default. If you aren't, then ask your cluster admin about [setting up a containershare](https://www.github.com/vsoch/containershare)

If you want to modify the partition flag to have a different gpu setup (other than `--partition gpu --gres gpu:1`) then you should set this **entire** string for the partition variable.

### SSH config

You will also need to at the minimum configure your ssh to recognize your cluster (e.g., sherlock) as
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

# Notebooks

Notebooks have associated sbatch scripts that are intended to start a jupyter (or similar)
notebook, and then forward the port back to your machine. If you just want to submit a job,
(without port forwarding) see [the job submission](#job-submission) section. For 
notebook job submission, you will want to use the [start.sh](start.sh) script.

## Notebook password

If you have not set up notebook authentication before, you will need to set a
password via `jupyter notebook password` on your cluster resource.  
Make sure to pick a secure password!


# Job Submission
Job submission can mean executing a command to a container, running a container, or 
writing your own sbatch script (and submitting from your local machine). For 
standard job submission, you will want to use the [start-node.sh](start-node.sh) script.
If your cluster has a containershare, you can use the `containershare-notebook`
set of scripts to have a faster deployment (without needing to pull).

## Usage

```bash
# Choose a containershare notebook, and launch it! On Sherlock, the containers are already in the share
bash start.sh sherlock/containershare-notebook docker://vanessa/repo2docker-julia

# Run a Singularity container that already exists on your resource (recommended)
bash start-node.sh singularity-run /scratch/users/vsochat/share/pytorch-dev.simg

# Execute a custom command to the same Singularity container
bash start-node.sh singularity-exec /scratch/users/vsochat/share/pytorch-dev.simg echo "Hello World"

# Run a Singularity container from a url, `docker://ubuntu`
bash start-node.sh singularity-run docker://ubuntu

# Execute a custom command to the same container
bash start-node.sh singularity-exec docker://ubuntu echo "Hello World"

# Execute your own custom sbatch script
cp myscript.job sbatches/
bash start-node.sh myscript
```

As a service for Stanford users, @vsoch provides a [containershare](https://vsoch.github.io/containershare)
of ready to go containers to use on Sherlock! The majority of these deploy interactive notebooks, 
however can also be run without (use start-node.sh instead of [start.sh](start.sh)). If you
want to build your own container for containershare (or request a container) see the
[README](https://www.github.com/vsoch/containershare) in the repository that serves it.

```bash
# Run a containershare container with a notebook
bash start.sh sherlock/containershare-notebook docker://vanessa/repo2docker-julia
```

If you would like to request a custom notebook, please [reach out](https://www.github.com/vsoch/containershare/issues).

## Usage


```bash
# To start a jupyter notebook in a specific directory ON the cluster resource
bash start.sh jupyter <cluster-dir>

# If you don't specify a path on the cluster, it defaults to your ${SCRATCH}
bash start.sh jupyter /scratch/users/<username>

# To start a jupyter notebook with tensorflow in a specific directory
bash start.sh py2-tensorflow <cluster-dir>

# If you want a GPU node, make sure your partition is set to "gpu."
# To start a jupyter notebook (via a Singularity container!) in a specific directory
bash start.sh singularity-jupyter <cluster-dir>
```

Want to create your own Singularity jupyter container? Use [repo2docker](https://www.github.com/jupyter/repo2docker) and then specify the container URI at the end.

```bash
bash start.sh singularity.jupyter <cluster-dir> <container>

# You can also run a general singularity container!
bash start.sh singularity <cluster-dir> <container>

# To start tensorboard in a specific directory (careful here and not recommended, as is not password protected)
bash start.sh start <cluster-dir>

# To stop the running jupyter notebook server
bash end.sh jupyter
```

If the sbatch job is still running, but your port forwarding stopped (e.g. if
your computer went to sleep), you can resume with:

```bash
bash resume.sh jupyter`
```

# Debugging

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
