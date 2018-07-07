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
a valid host.  I highly recommend you use the set up options below to
minimize the number of times you will need to type in your password/ two-factor!
So put the following in your local ssh config (at ~/.ssh/config, create
it if needed).  

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
