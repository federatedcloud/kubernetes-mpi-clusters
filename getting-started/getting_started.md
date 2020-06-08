How to get started
=====
You'll first need to install Kubernetes, Minikube, and Docker. 

Kubernetes
-----
The first tool is kubectl. This is how you're going to interact with a Kubernetes cluster, at least at the beginning.

The easiest way is to use snap or homebrew. The corresponding commands are
```
$ snap install kubectl --classic'
```
and
```
$ brew install kubectl
```
Alternatively, you can install a binary and make it executable using the following:
```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
```

Regardless of which way you installed kubectl, test that it is installed properly by running
```
$ kubectl version --client
```

Note that this step of the guide came from [the official Kubernetes installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)

Docker
-----
Docker is one of the default tools for running Minikube, so it's worth installing.
It is used for containerization and version control of applications. The installations can vary depending on your OS or distribution. Since I use Ubuntu, I will share the steps for that.

First navigate [here](https://docs.docker.com/engine/install/) to find the appropriate list of releases. For Ubuntu, you'll want to follow the link [here](https://docs.docker.com/engine/install/ubuntu/)

To ensure a clean install, you can remove previous versions of docker tools with
```
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```
(If you have none installed, apt will tell you so and exit safely)

The two best options are to set up the docker repo or to manually install a .deb file. For a repo, run
```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent sofware-properties-common
```
You'll need the docker GPG key
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify the key with a fingerprint. Running
```
$ sudo apt-key fingerprint 0EBFCD88
```
Should have the string
```
9DC8 5822 9FC7 DD38 E2D8 8D81 803C 0EBF CD88
```
in the second line of the output.

Next, you'll need to add the stable repository, which can vary by system so again refer to the previous link, but it is a command similar to
```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Next, run
```
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Alternatively, packages can be found [here (for ubuntu)](https://download.docker.com/linux/ubuntu/dists/) and can then be installed by
```
$ sudo dpkg -i /path/to/package.deb
```

Finally, run
```
$ sudo docker run hello-world
```
To make sure docker is installed correctly. Consider looking into user groups so you don't have to write `sudo` before every docker command.

Minikube
-----
Minikube is a way of running a Kubernetes cluster locally without having to pay for public computing time or messing around with setting up VMs and all that. It's a great way to get used to the basic functionality of Kubernetes.
There are packages you can install [here](https://github.com/kubernetes/minikube/releases)

Alternatively, you can run
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```
The last two lines ensure `minikube` is executable on your path.

Or, you can run
```
brew install minikube
```
I'm unsure if minikube can be installed via snap.

After this is installed, check that it has been done properly by starting the cluster:
```
$ minikube start
$ minikube status
$ minikube stop
```

The first command has a dependency that is filled by docker by defauly, the second should say various processes are either `running` or `configured`, and the last stops that cluster and stores its end state.
This step comes from [the minikube installation guide](https://kubernetes.io/docs/tasks/tools/install-minikube/) which has useful information about security and hypervisors.

Running a simple container
=====
Kubernetes has a ton of
