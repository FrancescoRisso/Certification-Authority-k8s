# Certification Authority k8s

A set of containers and YAML files for creating and managing a personal CA in K8s.

## `containers` folder

In the containers folder there is all the material to build the containers to be run in K8s.
This should not be important to the end user, since the containers are automatically built at every commit, and published on docker hub.

## `kubernetes` folder

Here are all the YAML files for the end user.

Whenever a file name ends with `-sample.yaml`, it means that it needs some data inside before being launched.
Data is marked either by a `...` field value, or a comment.

In a local copy of this repository, it is advisable to have a copy of such files, with your data inserted.
For your convenience, files ending with `-private.yaml` will fall under the `.gitignore` rules and will not be committed.

Below is a description of what the different YAML files do, and the respective parameters.

### 00 - namespace

This YAML simply creates a namespace for the CA.
If multiple CAs are desired, it is advisable to have a separate namespace for each CA.

The `-sample.yaml` requires the namespace name to be inserted.

### 01 - PV and PVC

In this YAML, the Persistent Volume and PV Claim are created.
They are required to store the CA and certificates in a persistent way.

Since PVs are not namespace-dependent, a different PV (with a different name) must be created for each CA.
For this reason, a unique PV name must be inserted in the `-sample.yaml` file.

### 02 - CA root password

The CA requires a root password to create the various certificates.
This YAML creates it as a Kubernetes secret, which will be used automatically by the other containers.

The `-sample.yaml` file requires (of course!) the password to be chosen.
Since Kubernetes needs the password to be pre-encrypted using base64, the password to be inserted here should be the output of this command:

```bash
echo "your chosen password" | base64
```

### 03 - Create CA

This YAML contains a job that creates the CA and stores all the required files to disk.

The only required parameter is the duration in days of the root certificate (env `CERT_DURATION`).
Optional env variables include all the certificate parameters, such as name or country.

By default, the YAML would not override an existing CA, unless the `CA_OVERRIDE_IF_EXISTS` env variable is enabled.

Please note that:

-   after a correct execution, the Job will remain present in the Kubernetes environment, to be able to consult its logs.
    To run a new one, the previous should be deleted manually.
-   in case of failure of the container, Kubernetes will restart the pod: it is convenient to delete the job to avoid wasting resources. The container will fail in these cases:
    -   CA exists and `CA_OVERRIDE_IF_EXISTS` is not set
    -   `CERT_DURATION` is not set
    -   unforeseen openssl errors
