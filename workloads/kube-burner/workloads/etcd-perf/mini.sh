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
  #To check the etcd pod load status
  #for i in {3..12};
  #do
   #SECRET_NAME="my-large-secret-$i";oc -n multi-image create -f my-large-sec.yaml
  #done
 #echo "to check endpoint health after creating many secrets"
 for i in {1..3}; do oc create secret generic ${SECRET_NAME}-$i -n $NAMESPACE --from-literal=ssh-private-key="$SSH_PRIVATE_KEY" --from-literal=ssh-public-key="$SSH_PUBLIC_KEY" --from-literal=token="TOKEN_VALUE" --from-literal=tls.crt="CERTIFICATE" --from-literal=tls.key="$PRIVATE_KEY";done 
