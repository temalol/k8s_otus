#set your variables here
#################
CLUSTER_ID=cat8jf64t7igk8k8jsfd


#################

############### k8s config creating

mkdir kubeconfig

yc managed-kubernetes cluster get --id $CLUSTER_ID --format json | \
  jq -r .master.master_auth.cluster_ca_certificate | \
  awk '{gsub(/\\n/,"\n")}1' > ca.pem

kubectl create -f sa.yaml -f sa.yaml


SA_TOKEN=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | \
  grep admin-user-token | \
  awk '{print $1}') -o json | \
  jq -r .data.token | \
  base64 -d)

MASTER_ENDPOINT=$(yc managed-kubernetes cluster get --id $CLUSTER_ID \
  --format json | \
  jq -r .master.endpoints.external_v4_endpoint)


kubectl config set-cluster sa-test2 \
  --insecure-skip-tls-verify=true \
  --server=$MASTER_ENDPOINT \
  --kubeconfig=kubeconfig/test.kubeconfig

kubectl config set-credentials admin-user \
  --token=$SA_TOKEN \
  --kubeconfig=kubeconfig/test.kubeconfig



kubectl config set-context default \
  --cluster=sa-test2 \
  --user=admin-user \
  --kubeconfig=kubeconfig/test.kubeconfig

kubectl config use-context default \
  --kubeconfig=kubeconfig/test.kubeconfig

###################################
##################### s3 credentials csi
mkdir s3_csi_cred

yc iam access-key create  --service-account-name bucket > s3_csi_cred/csi_s3_secret.yaml

key_id=$(yq .access_key.key_id < s3_csi_cred/csi_s3_secret.yaml)
secret=$(yq .secret < s3_csi_cred/csi_s3_secret.yaml)

yq  -n '(.secret.accessKey=strenv(key_id), .secret.secretKey=strenv(secret))' > s3_csi_cred/file.yaml
sops -p E48E7EBD5FDA8F68CE04FBEB8D3A327416AA7D97 -e s3_csi_cred/file.yaml > s3_csi_cred/prometheus_secret.yaml

##########################################
################# docker credentials
mkdir docker_cred

yc iam key create --service-account-name docker-account -o docker_cred/docker_key.json

#####################



