# Farmshare

1. Following the original tutorial - the container to use in Rice is located at /farmshare/home/classes/bioe/301p/ce/ces - maintained by Dr.Paul Nuyujukian of Department of Bioengineering.
2. On Rice, type `model load singularity`, and then `singularity exec /farmshare/home/classes/bioe/301p/ce/ces jupyter notebook --generate-config`. 
3. Choose a password and type and verify password, it will be stored and later used to access the notebooks. 
4. Fill out the params.sh file like the original tutorial by running `bash setup.sh`.  Choose a port that is higher than 32768 for the tunnel to work. 
5. In order to start type `bash start_farmshare.sh singularity-jupyter` for classic notebook or `bash start_farmshare.sh singularity-jupyterlab` for Jupyter Lab.
6. During establishing the tunnel to the compute node, there will be a prompt for user password and duo factor authentication. 
7. See where the notebook is running is at the end of the prompt and type in a browser (http://localhost:(your chosen port number)). The default location of the notebook will be at your scratch location - /farmshare/scratch/users/yourusername
