FROM cornellcac/nix_alpine_base:0f566286984d3565f89262acb3186483832bdae8

USER $nixuser 

#Adding ansible and terraform files 
COPY tf-kubernetes $HOME/tf-kubernetes
COPY nix $HOME/nix
COPY terraform /usr/bin
USER root 

#RUN echo $nixuser
RUN chown -R $nixuser:$nixuser $HOME/tf-kubernetes \ 
  $HOME/nix
USER $nixuser
RUN nix-shell /home/nixuser/nix/ --show-trace
