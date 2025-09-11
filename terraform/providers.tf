# Connect Terraform to your current kubeconfig.
provider "kubernetes" {
  config_path = "~/.kube/config"
}
