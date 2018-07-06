# forward

## What is this?

Forward sets up an sbatch script on sherlock and port forwards it back to your local machine! 

Useful for jupyter notebook and tensorboard, amongst other things.

## Setup

You need to create a parameter file first.  To do so, follow the prompts at:

`bash setup.sh`

You can always edit params.sh later to change these configuration options.

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

## Adding new sbatch scripts

You can add more sbatch scripts by putting them in the sbatches directory.
