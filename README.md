# Automate cellulaire

## Pré requis
### Installation
#### CUDA Toolkit 11.6 téléchargement 
```console
massinissa@Modern-8MO:~$ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin

massinissa@Modern-8MO:~$ sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

massinissa@Modern-8MO:~$ wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb

massinissa@Modern-8MO:~$ sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb

massinissa@Modern-8MO:~$ sudo apt-key add /var/cuda-repo-ubuntu2004-11-6-local/7fa2af80.pub

massinissa@Modern-8MO:~$ sudo apt-get update

massinissa@Modern-8MO:~$ sudo apt-get -y install cuda

massinissa@Modern-8MO:~$ sudo nano /etc/profile.d/cuda.sh

export PATH=$PATH:/usr/local/cuda/bin
export CUDADIR=/usr/local/cuda

massinissa@Modern-8MO:~$ sudo chmod +x /etc/profile.d/cuda.sh
massinissa@Modern-8MO:~$ sudo nano /etc/ld.so.conf.d/cuda.conf
/usr/local/cuda/lib64
massinissa@Modern-8MO:~$ sudo ldconfig
sudo ldconfig
massinissa@Modern-8MO:~$ reboot
massinissa@Modern-8MO:~$ nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2019 NVIDIA Corporation
Built on Sun_Jul_28_19:07:16_PDT_2019
Cuda compilation tools, release 10.1, V10.1.243
```
#### utiliser nvcc pour crée un executable

```console
massinissa@Modern-8MO:~/Documents/MesProjet/automate-cellulaire$ nvcc -lglut -lGL cellule.cu -o cellule_executable
massinissa@Modern-8MO:~/Documents/MesProjet/automate-cellulaire$ ./cellule_executable
```

