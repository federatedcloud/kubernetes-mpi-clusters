FROM cornellcac/nix_alpine_base:0f566286984d3565f89262acb3186483832bdae8

USER $nixuser 

#Adding ansible and terraform files 
COPY tf-kubernetes $HOME/tf-kubernetes
COPY nix $HOME/nix
COPY mpi-files $HOME/mpi-files
USER root 

#RUN echo $nixuser
RUN chown -R $nixuser:$nixuser $HOME/tf-kubernetes \ 
  $HOME/nix \
  $HOME/mpi-files
RUN chmod 775 $HOME/nix/run.sh \
  $HOME/nix/rerun.sh \
  $HOME/nix/wait.sh \
  $HOME/nix/gcloud-authn.sh
RUN wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip \
  && unzip terraform_1.0.0_linux_amd64.zip && mv terraform /usr/bin
USER $nixuser
RUN nix-shell /home/nixuser/nix/ --show-trace
