# Running [Synthea](https://github.com/synthetichealth/synthea) using [Singularity](https://sylabs.io/singularity/)

## Introduction

[Synthea]() is a patient population generator. Written in Java, it allows for the simulation of realistic patients with their corresponding medical records.

Singularity is a container based solution that allows users to package applications together with all possible dependencies. The packaged container can then be run on any operating system that supports singularity. This eliminates the need to bother about different operating systems, dependencies, etc.

### Why Synthea on Singularity

Synthea is not a complex application at least dependency wise. As long the host system has Java installed it would be possible to build and run Synthea. The installation of Java itself is also not a cumbersome process.

This begs the question: Why bother running Synthea on Singularity? The answer is in a caveat mentioned already: ***As long as the host system has Java installed***. In this particular context the host system is a Linux HPC Cluster. To avoid conflicts between software versions, etc, there is only a limited set of software installed on the cluster. Also root access is not available.

The HPC cluster however has Singularity support. This would mean that there are two possible ways to get Synthea to run:

1. Install Java in a manner that does not require root access
2. Use a Singularity container with Synthea bundled.

As the name of this article suggests, the second option was selected.

## Approach

Before running on the cluster, it was required to validate this approach on a local system i.e. not on the cluster. At the time of writing this, the local system was running MacOS. 

Singularity is specifically designed for Linux systems. At the time of writing there was already a desktop version with support for MacOS. The idea - according to Singularity's developers - was that eventually the MacOS version would have all the features available on the Linux version but in the meantime only a subset of features were available for MacOS.

This meant that were two possible paths to evaluating the Synthea-on-Singularity option:

1. Use the desktop version of Singularity on MacOS
2. Run a Linux virtual machine (VM) on MacOS and work within the VM.

The second option was chosen. 

It should be noted that no evaluation was made of the desktop version to determine if the subset of features available would be sufficient for the needs of the task.

Furthermore, [Vagrant](https://www.vagrantup.com) was used to manage the creation of the VM. For those unfamiliar with Vagrant, the authors describe it as *a tool for managing virtual machine environments in a single workflow*. A simplified explanation is that Vagrant allows for automating creating, provisioning, managing and deleting virtual machines.

The rest of this description assumes that Vagrant is already installed. Also a `Vagrantfile` is included in this repository which contains the instructions to spin a virtual machine running Ubuntu 18.04 with adequate resources.

To bring up the virtual machine, run the command below in the same directory as the `Vagrantfile`:
```bash
vagrant up
```

To access the virtual machine, run the command below:
```bash
vagrant ssh
```

At this point you should be running inside the virtual machine

## Setting up Singularity

Singularity has very descriptive instructions for installation in [its user guide](https://sylabs.io/singularity/).

Please see the script `singularity-setup.sh` for the commands required to setup singularity on Ubuntu.

## Building Synthea

Synthea includes as part of its release file a `.jar` file which is bundled with all the dependencies required to run. However for this particular use case, some modifications were made to Synthea's source code and it was required to build a new `.jar` file with the dependencies bundled.

To do this, run the following command:
```bash
./gradlew uberJar
```

This generates a `synthea-with-dependencies.jar` file in the `<synthea-root>build/libs` directory.

This file was stored in a cloud storage provider (dropbox) to allow for remote access when required.

## Building a Synthea Container

The next step involved building a container which could run Synthea.

Singularity allows users to build a container image from scratch or to build on top of an existing container.

Again the [documentation is very helpful in describing the steps](https://sylabs.io/guides/3.4/user-guide/quick_start.html#build-images-from-scratch) that need to be followed.

For this use case, an Ubuntu 18.04 container image was selected as the base. Also a singularity definition file was created. For those familiar with Docker, this definition file would be the equivalent of the Dockerfile. In very brief details, the definition file contains instructions for for building/provisioning the container, for running the container and also defining help messages amongst other possibilities.

The created definition file is provided in this repo (see the `synthea.def` file).

The container was built with the following command:
```bash
sudo singularity build synthea.sif synthea.def
```

This generated a `synthea.sif` singularity container which could then be run on the cluster.

## Running the Container on the Cluster

The cluster in question makes use of [SLURM](https://slurm.schedmd.com/) a Linux job scheduling tool. Since the cluster is a multi-tenant system, SLURM has the advantage of helping to ensure fair usage of resources.

Jobs to be run are submitted using `sbatch`. The resources to be utilized by the job are specified in a script. See `run_synthea.job` for the `sbatch` configuration. 

Before submitting the job, the singularity module needed to be loaded on the cluster. This was done using the following command:

```bash
module load singularity
```

The job was then submitted using this command:
```bash
sbatch run_synthea.job
```

## Conclusions

This description, though mainly for the sake of reproducibility, illustrates the advantages of Singularity especially in a HPC setting. 

In particular, it allows for the deployment of applications with very complex dependency graphs without polluting the installed application space of the host system.