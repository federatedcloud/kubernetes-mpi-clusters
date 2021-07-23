#FROM cornellcac/nix_alpine_base:0f566286984d3565f89262acb3186483832bdae8 OLD
#FROM nix_alpine_base:1eceb63b86312787b7ead2077687fc65eb732494 Different Build
FROM nix_alpine_base:148ef8f386bd8b4e8c5a084eb522eb2366bc4f88_testing
USER $nixuser 

#Adding ansible and terraform files 
COPY tf-kubernetes $HOME/tf-kubernetes
COPY nix $HOME/nix
COPY mpi-files $HOME/mpi-files
COPY nfs $HOME/nfs
USER root 

#RUN echo $nixuser
RUN chown -R $nixuser:$nixuser $HOME/tf-kubernetes \ 
  $HOME/nix \
  $HOME/mpi-files \
  $HOME/nfs \
  && ln $HOME/nix/default.nix /nixenv/nixuser/
RUN chmod 775 $HOME/nix/run.sh \
  $HOME/nix/rerun.sh
RUN wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip \
  && unzip terraform_1.0.0_linux_amd64.zip && mv terraform /usr/bin
USER $nixuser
RUN nix-shell --show-trace
