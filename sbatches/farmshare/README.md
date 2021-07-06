# Farmshare

1. Go to your home directory in rice. Type `module load singularity`.
2. On Rice,while still in your home directory, type `singularity exec library://sohams/default/farmsharejupyter:latest jupyter notebook --generate-config`
3. Next type, `singularity exec library://sohams/default/farmsharejupyter:latest jupyter notebook password`. Choose a password and verify it. This will serve as the login password for the notebooks. 
4. Follow the original tutorial to setup ssh, and fill out the params.sh file by running `bash setup.sh`.  Choose a port that is higher than 32768 for the tunnel to work. 
5. In order to start type `bash start_farmshare.sh singularity-jupyter` for classic notebook or `bash start_farmshare.sh singularity-jupyterlab` for Jupyter Lab.
6. During establishing the tunnel to the compute node, there will be a prompt for user password and duo factor authentication. 
7. See where the notebook is running is at the end of the prompt and type in a browser (http://localhost:(your chosen port number)). The default location of the notebook will be at your scratch location - /farmshare/scratch/users/yourusername
