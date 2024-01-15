# k8s_otus


Ingress install
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=ingress-nginx  --set controller.replicaCount=2