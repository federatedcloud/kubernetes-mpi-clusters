#FROM cornellcac/nix_alpine_base:0f566286984d3565f89262acb3186483832bdae8
FROM nix_alpine_base:148ef8f386bd8b4e8c5a084eb522eb2366bc4f88_testing
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
  $HOME/nix/aws-authn.sh
RUN wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip \
  && unzip terraform_1.0.0_linux_amd64.zip && mv terraform /usr/bin
USER $nixuser
RUN nix-shell /home/nixuser/nix/ --show-trace
