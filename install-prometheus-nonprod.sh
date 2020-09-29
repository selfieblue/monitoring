helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Check storageclass
kubectl get sc


kubectl get pod --all-namespaces

# Create namespacve for monitoring
kubectl create ns monitoring -o yaml --dry-run=client | kubectl apply -f -

# Install metric-server
# helm upgrade --install metrics-server stable/metrics-server \
#   --namespace monitoring \
#   --version 2.11.1 \
#   --set serviceAccount.name=metrics-server

# Install Prometheus and Grafana
helm install [RELEASE_NAME] prometheus-community/prometheus


# Get StorageClass and Domain For Grafana and Prometheus
kubectl get sc
#== ssd
# Ingress LoadBalncer
  # https://cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress
  # https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb

# helm upgrade --install prometheus --version 11.3.0 stable/prometheus \
#   -f values-nonprod.yaml \
#   --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-additional-resource-tags"="Name=rbh-nonprod-eks-prometheus-elb" \
#   --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-extra-security-groups"="sg-0145ebfb9121d0fa0" \
#   --set nodeExporter.securityContext.runAsUser=65534 \
#   --namespace monitoring

# helm upgrade --install prometheus --version 11.12.1 stable/prometheus \
#   --set serviceAccounts.alertmanager.create="false" \
#   --set serviceAccounts.pushgateway.create="false" \
#   --set alertmanager.enabled="false" \
#   --set kubeStateMetrics.enabled="false" \
#   --set server.persistentVolume.size="50Gi" \
#   --set server.persistentVolume.storageClass="ssd" \
#   --set server.resources.limits.cpu="2000m" \
#   --set server.resources.limits.memory="4096Mi" \
#   --set server.resources.requests.cpu="1000m" \
#   --set server.resources.requests.memory="512Mi" \
#   --set server.ingress.enabled="true" \
#   --set server.ingress.annotations."kubernetes\.io/ingress\.class"="gce-internal" \
#   --set server.ingress.hosts[0]="'*'"\
#   -f values-nonprod.yaml \
#   --namespace monitoring


helm upgrade --install prometheus --version 11.12.1 stable/prometheus \
  --set serviceAccounts.alertmanager.create="false" \
  --set serviceAccounts.pushgateway.create="false" \
  --set alertmanager.enabled="false" \
  --set kubeStateMetrics.enabled="false" \
  --set server.persistentVolume.size="50Gi" \
  --set server.persistentVolume.storageClass="ssd" \
  --set server.resources.limits.cpu="2000m" \
  --set server.resources.limits.memory="4096Mi" \
  --set server.resources.requests.cpu="1000m" \
  --set server.resources.requests.memory="512Mi" \
  -f values-nonprod.yaml \
  --namespace monitoring


kubectl -n monitoring scale --replicas=1 deployment prometheus-server  

kubectl -n monitoring apply -f new-cm-prometheus-server-nonprod.yaml
kubectl -n monitoring get pod

kubectl -n monitoring scale --replicas=1 deployment prometheus-server


# Addons
# MySQL 	: https://hub.docker.com/r/prom/mysqld-exporter
# MongoDB	: https://github.com/percona/mongodb_exporter
#			      https://github.com/helm/charts/tree/master/stable/prometheus-mongodb-exporter
# Create User : https://github.com/percona/mongodb_exporter
helm upgrade --install robinhood-mongodb-exporter --version 2.8.1 stable/prometheus-mongodb-exporter \
  --set mongodb.uri="" \
  --namespace monitoring
mongodb://myDBReader:D1fficultP%40ssw0rd@mongodb0.example.com:27017/?authSource=admin

# Ingress	: https://github.com/nginxinc/nginx-prometheus-exporter/blob/master/README.md
#           https://github.com/helm/charts/tree/master/stable/prometheus-mysql-exporter
SET GLOBAL log_output='TABLE';
SET GLOBAL slow_query_log=1;
SET GLOBAL long_query_time=2.0;
SET GLOBAL log_slow_verbosity='query_plan,explain';
SHOW VARIABLES LIKE '%slow%';
SELECT * FROM mysql.slow_log\G

helm install --name robinhood-mysql-exporter --version 0.7.1 stable/prometheus-mysql-exporter \
  --set mysql.user="username",mysql.pass="password",mysql.host="example.com",mysql.port="3306" \
  --namespace monitoring

kubectl annotate pods xxxxxx prometheus.io/port="10254"
kubectl annotate pods xxxxxx prometheus.io/scrape="true" --overwrite
