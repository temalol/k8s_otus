CLUSTER_ID=catctl92sn62qte206r4


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
  --kubeconfig=test.kubeconfig

kubectl config set-credentials admin-user \
  --token=$SA_TOKEN \
  --kubeconfig=test.kubeconfig



kubectl config set-context default \
  --cluster=sa-test2 \
  --user=admin-user \
  --kubeconfig=test.kubeconfig

kubectl config use-context default \
  --kubeconfig=test.kubeconfig

