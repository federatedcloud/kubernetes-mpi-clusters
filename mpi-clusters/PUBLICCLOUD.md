Getting Started
===============
To run larger applications that require more computing power, you may need to move beyond your local machine and use resources such as the public cloud. As per the readme, this guide will show you how to get started with Kubernetes on GCP.

1. Create an account with GCP
2. Create a Cloud project from the [Cloud Console project selector page](https://console.cloud.google.com/home/dashboard?authuser=1)
3. Make sure billing is enabled (it should be automatically) [here](https://cloud.google.com/billing/docs/how-to/modify-project)

There are more configuration options available, but this is enough to key started.

First Steps
===========
The simplest tutorial for getting started is pretty much a [containerized online hello world](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app?authuser=1). If you followed the previous guides, everything related to Kubernetes should be familiar, so this will only expand upon the new features specific to GCP.

There are 3 ways to guide your workflow with GCP
 - Local command line. You will need to follow the remaining installation procedure
    - The page [here](https://cloud.google.com/sdk/install) has a full list of installation methods.
    - For Ubuntu/Debian, `gcloud` is available through `apt-get` after gettting the Google Cloud public key. There are specific instructions [here](https://cloud.google.com/sdk/docs/downloads-apt-get)
    - Run `gcloud init`. This will prompt you for a default project. Use the one you created earlier. 
 - Cloud Shell. GCP provides an online shell that has all the tools you need to get started.
 - Cloud Console. There is an online interface were all the same actions on the command line can be done by clicking on various menus and buttons.

Our recommendation is the Cloud Shell as it seems to provide the most information about running processes and is a cleaner experience.
