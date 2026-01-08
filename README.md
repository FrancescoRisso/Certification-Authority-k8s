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

Different parameters can be provided by means of environmental variables:

| Env                     |  Req.   | Effect                                    |
| :---------------------- | :-----: | :---------------------------------------- |
| `CERT_DURATION`         | &check; | Duration of the certificate in days       |
| `CA_NAME`               | &cross; | Name of the CA                            |
| `CA_COUNTRY`            | &cross; | Two-letter code for the country of the CA |
| `CA_STATE_PROVINCE`     | &cross; | State/province of the CA                  |
| `CA_LOCALITY`           | &cross; | Locality of the CA                        |
| `CA_ORG`                | &cross; | Name of the CA organization               |
| `CA_ORG_UNIT`           | &cross; | Name of the CA organization unit          |
| `CA_OVERRIDE_IF_EXISTS` | &cross; | Enable to override the CA with a new one  |

By default, the YAML would not override an existing CA, unless the `CA_OVERRIDE_IF_EXISTS` env variable is enabled.

Please note that:

-   after a correct execution, the Job will remain present in the Kubernetes environment, to be able to consult its logs.
    To run a new one, the previous should be deleted manually.
-   in case of failure of the container, Kubernetes will restart the pod: it is convenient to delete the job to avoid wasting resources. The container will fail in these cases:
    -   CA exists and `CA_OVERRIDE_IF_EXISTS` is not set
    -   `CERT_DURATION` is not set
    -   unforeseen openssl errors

### 04 - Describe CA

This YAML contains a job that describes the CA stored in the PV.

Different pieces of information can be printed, based on the environment variables that are enabled:

| Env             | Content                                                                      |
| :-------------- | :--------------------------------------------------------------------------- |
| `ROOT_CERT`     | Print the root certificate (the one that should added to the user devices)   |
| `CERTIFICATES`  | Print the private key generated for the certificate                          |
| `INSTR_ANDROID` | Print instructions for installing the root certificate on Android devices    |
| `INSTR_W11`     | Print instructions for installing the root certificate on Windows 11 devices |

Please note that:

-   after a correct execution, the Job will remain present in the Kubernetes environment, to be able to consult its logs.
    To run a new one, the previous should be deleted manually.
-   in case of failure of the container, Kubernetes will restart the pod: it is convenient to delete the job to avoid wasting resources. The container will fail if the CA does not exist.

### 05 - Create certificate

This YAML contains a job that creates a new certificate and stores all the required files to disk.

Different parameters can be provided by means of environmental variables:

| Env                   |  Req.   | Effect                                                                |
| :-------------------- | :-----: | :-------------------------------------------------------------------- |
| `CERT_DURATION`       | &check; | Duration of the certificate in days                                   |
| `CERT_ID`             | &check; | A filename-acceptable identifier for the certificate, e.g. my-website |
| `CERT_DESCRIPTION`    | &check; | The .ext file to describe the certificate, edit as required           |
| `CERT_NAME`           | &cross; | Name of the certificate                                               |
| `CERT_COUNTRY`        | &cross; | Two-letter code for the country of the certificate                    |
| `CERT_STATE_PROVINCE` | &cross; | State/province of the certificate                                     |
| `CERT_LOCALITY`       | &cross; | Locality of the certificate                                           |
| `CERT_ORG`            | &cross; | Name of the certificate organization                                  |
| `CERT_ORG_UNIT`       | &cross; | Name of the certificate organization unit                             |

Please note that:

-   after a correct execution, the Job will remain present in the Kubernetes environment, to be able to consult its logs.
    To run a new one, the previous should be deleted manually.
-   in case of failure of the container, Kubernetes will restart the pod: it is convenient to delete the job to avoid wasting resources. The container will fail in these cases:
    -   the CA does not exist
    -   `CERT_DURATION` is not set
    -   `CERT_ID` is not set or is already an existing certificate
    -   `CERT_DESCRIPTION` is not set
    -   unforeseen openssl errors

### 06 - Describe certificate

This YAML contains a job that describes a certificate stored in the PV.

Different pieces of information can be printed, based on the environment variables that are enabled:

| Env          |  Req.   | Content                                              |
| :----------- | :-----: | :--------------------------------------------------- |
| `CERT_ID`    | &check; | The id of the certificate to be described            |
| `PRIV_KEY`   | &cross; | Print the private key generated for the certificate  |
| `CERT`       | &cross; | Print the certificate itself                         |
| `CERT_DESCR` | &cross; | Print the .ext file used to generate the certificate |

Please note that:

-   after a correct execution, the Job will remain present in the Kubernetes environment, to be able to consult its logs.
    To run a new one, the previous should be deleted manually.
-   in case of failure of the container, Kubernetes will restart the pod: it is convenient to delete the job to avoid wasting resources. The container will fail if no certificate has the selected ID, or the ID was not provided.
