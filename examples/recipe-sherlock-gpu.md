# Jupyter with GPU on Sherlock

A recipe for interactive computing using custom Jupyter kernels on Stanford's Sherlock.
Contributed by [@zqfang](https://github.com/zqfang)

## Setting up custom conda environment on Sherlock's login node
### 1. Download and install Miniconda

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# install
bash Miniconda3-latest-Linux-x86_64.sh 
conda config --set always_yes yes 
```


### 2. Install jupyter notebook/lab and secure your notebooks with a password  

```bash
# install the default py3 kernel for jupyter notebook
conda install ipython jupyter notebook jupyterlab
# add password
jupyter notebook password
```

### 3. (Optional) Add custom conda environment. i.e. fastai
```bash
conda create -n fastai ipython ipykernel 
# add the custom to Jupyter notebook
conda activate fastai
python -m ipykernel install --user --name fastai --display-name FastAI

```
you could also add R, Julia etc kernel.

### 4. Install pytorch/tensorflow

You should select the existed cuda version which installed in Sherlock
```bash
conda install -c pytorch pytorch torchvision cudatoolkit=10.1 
```
tensorflow
```bash
conda install tensorflow-gpu cudatoolkit=10.1
```

### 5. Load gpu modules. Select the corresponding cuda version you've just installed 
```bash
# this is my version
module load cuda/10.1.168
module load cudnn/7.6.4
module load nccl
```

### 6. now, open ipython, run
```python
import torch
print(torch.cuda.is_avilable())
```
if print out is `True`, then you'er OK to use GPUs.

# Follow these steps on your local machine
see details [here](https://vsoch.github.io/lessons/sherlock-jupyter/).

### 7. Download the `forward` repo
```bash
git clone https://github.com/vsoch/forward
cd forward
```
### 8. Generate your parameters
```
bash setup.sh
```
Select Sherlock partition: <span style="color: red">gpu</span>

### 9. SSH Credentials

```bash
bash hosts/sherlock_ssh.sh >> ~/.ssh/config
```

### 10. create a sbatch script in forward/sbatches/sherlock and save as `jupyter-gpu.sbatch`

This recipe is also provided in the repository [here](https://github.com/vsoch/forward/blob/master/sbatches/sherlock/jupyter-gpu.sbatch).

```bash
#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
if [ -z "$NOTEBOOK_DIR" ]; then
    cd $SCRATCH
else
    cd $NOTEBOOK_DIR
fi

## to compile libtorch C++ code, load these modules
# module load gcc/7.3.0
# module load gdb
# module load cmake
# export CC=$(which gcc)
# export CXX=$(which g++)

# select cuda version you need
module load cuda/10.1.168
module load cudnn/7.6.4
module load nccl

# activate fastai env 
source activate fastai 
jupyter lab --no-browser --port=$PORT
```

### 11. Start a session
The default working directory is `$SCRATCH`
```bash
bash start.sh jupyter-gpu
```
change the working directory 
```
bash start.sh jupyter /path/to/dir
```

### 12. open your browser in local machine and type  

if your port is 51888, then
```
http://localhost:51888/
```
here is my jupyter lab computing environment. Have fun!


### 13. Resume a session
```bash
bash resume.sh jupyter-gpu
# or
bash resume.sh jupyter-gpu /path/to/dir
```
## 14. Stop a session

```bash
bash end.sh jupyter-gpu
# or
bash end.sh jupyter-gpu /path/to/dir
```
