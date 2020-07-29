docker exec -t tf_kubernetes_container nix-shell /home/nixuser/nix --run 'cd ~/tf-kubernetes; terraform destroy --auto-approve'
docker stop tf_kubernetes_container
