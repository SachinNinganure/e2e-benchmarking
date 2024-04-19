  #CASE 03 Many secrets; 300namespaces each with 400 secrets
  for i in {1..3}; do oc new-project sproject-$i; for j in {1..2}; do oc -n sproject-$i create secret generic my-secret-$j --from-literal=key1=supersecret --from-literal=key2=topsecret;done  done
  #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Configure the name of the secret and namespace
  SECRET_NAME="my-large-secret"
  NAMESPACE="my-namespace"

  # SSH key
  ssh-keygen -t rsa -b 4096 -f sshkey -N ''
  SSH_PRIVATE_KEY=$(cat sshkey | base64 | tr -d '\n')
  SSH_PUBLIC_KEY=$(cat sshkey.pub | base64 | tr -d '\n')

  # Token (example token here, replace with your actual token generation method)
  TOKEN_VALUE=$(openssl rand -hex 32 | base64 | tr -d '\n')

  # Self-signed Certificate
  openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 -nodes -subj "/CN=mydomain.com"
  CERTIFICATE=$(cat tls.crt | base64 | tr -d '\n')
  PRIVATE_KEY=$(cat tls.key | base64 | tr -d '\n')
  oc -n multi-image create -f testsec.yaml
  rm -f sshkey sshkey.pub tls.crt tls.key
  git clone https://github.com/peterducai/etcd-tools.git;sleep 10;
  
#CASE 4 large secrets---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo "Large secrets...!"
for i in {3..8};
do
SECRET_NAME="my-large-secret-$i"

# Create the secret YAML file
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $NAMESPACE
type: Opaque
data:
  ssh-private-key: $SSH_PRIVATE_KEY
  ssh-public-key: $SSH_PUBLIC_KEY
  token: $TOKEN_VALUE
  tls.crt: $CERTIFICATE
  tls.key: $PRIVATE_KEY
EOF
done
# Clean up the generated files
rm -f sshkey sshkey.pub tls.crt tls.key

echo "to check endpoint health after creating many secrets"
date;oc adm top node;date;etcd-tools/etcd-analyzer.sh;date


echo "Fio Test STARTS...........................................................................!"
#etcd-tools/fio_suite.sh
etc_masternode1=`oc get node |grep master|awk '{print $1}'|tail -1`
oc debug -n openshift-etcd --quiet=true node/$etc_masternode1 -- chroot host bash -c "podman run --privileged --volume /var/lib/etcd:/test quay.io/peterducai/openshift-etcd-suite:latest fio"
