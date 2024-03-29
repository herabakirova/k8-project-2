#!/bin/bash

# Variables:
project_name="kubernetes-dashboard-group-3"
project_name_display="Project-Group-3"
billing_account="###"
bucket="kubernetes-dashboard-group3"
region="us-central1"
cluster_name="group-project-3"


#Installing kubectl (latest version):
function kubectl() {
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

#Installing gcloud:
function gcloud() {
sudo apt-update
sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo -y
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli -y
apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
}

# Installing terraform:
function terraform() {
sudo apt install unzip -y
wget https://releases.hashicorp.com/terraform/1.7.4/terraform_1.7.4_linux_amd64.zip
unzip terraform_1.7.4_linux_amd64.zip
sudo mv terraform /usr/local/bin
}

# Creating GCP infrastructure with Terraform:
function terraform_infr() {
terraform init
terraform apply -auto-approve
}

# Authorizing gcloud SDK, creating project and bucket:
function gcloud_auth() {
gcloud auth login
gcloud projects create $project_name --name=$project_name_display #var
gcloud billing projects link $project_name --billing-account $billing_account  #var
gcloud auth application-default login
gcloud auth application-default set-quota-project $project_name y
gcloud storage buckets create gs://$bucket --location=US --project=$project_name #var
}

# Deploying kubernetes-dashboard in the cluster:
function dashboard() {
gcloud container clusters get-credentials $cluster_name --region $region --project $project_name
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n kubernetes-dashboard
kubectl create sa admin -n kubernetes-dashboard
kubectl create clusterrolebinding cluster-admin-rolebinding --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin -n kubernetes-dashboard
kubectl create token admin -n kubernetes-dashboard > token
cat token
}

kubectl
gcloud
terraform
gcloud_auth
terraform_infr
dashboard