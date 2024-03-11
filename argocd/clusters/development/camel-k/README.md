# Camel-K

In order to create the credentials for the registy where Camel-K will build the images, you need to create a secret in the namespace where Camel-K will be running.

```bash
kubectl create secret docker-registry github-camel-k --docker-server=ghcr.io --docker-username=<spoletum> --docker-password=<token> --docker-email=<emailaddress> -n camel-k
```