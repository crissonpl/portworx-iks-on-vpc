# Portworx on VPC

This module creates a Portworx instance and installs it onto an existing IKS on VPC cluster.

## Table of Contents

1. [Description](##description)
2. [Installation Prerequisites](##Installation-Prerequisites)
3. [Block Storage Volumes](##Block-storage-volumes)
4. [Documentation](##documentation)
5. [Module Variables](##module-variables)

---

## Description

This module follows the lifecycle of storing data on a software-defined storage (SDS) with Portworx on a VPC cluster using the Portworx KVDB. An example deployment is included to verify installation success.  

---

## Installation Prerequisites

In order to install Portworx onto a cluster, the public service endpoint must be enabled. The minimum supported size for a Portworx cluster is three nodes. Each node must meet the following hardware, software, and network requirements:

* 4 cores CPU
* 4 GB RAM

---

## Block Storage Volumes

Portworx requires at least 3 worker nodes with raw and unformatted block storage. This module will create a block storage volume for each worker node in the cluster and attach it to that worker.

---

## Documentation

* [Storing data on software-defined storage (SDS) with Portworx](https://cloud.ibm.com/docs/containers?topic=containers-portworx)
* [Verifying your Portworx installation](https://cloud.ibm.com/docs/containers?topic=containers-getting-started-with-portworx#px-verify-installation)
* [Installation requirements](https://docs.portworx.com/start-here-installation/)# Name

---

## Module Variables

Variable | Type | Description | Default
---------|------|-------------|--------
`ibmcloud_api_key` | string | api key for IBM Cloud |
`unique_id` | string | unique identifiers for all created resources |
`generation` | number | Generation for VPC | 2
`ibm_region` | string | region where all created resources will be deployed |
`cluster` | string | name of existing kubernetes cluster |
`resource_group` | string | resource group of existing kubernetes cluster | `asset-development`
`capacity` | number | Capacity for all block storage volumes provisioned in gigabytes | 100
`profile` | string | The profile to use for this volume. | `10iops-tier`
`image_name` | string | image for deployment where portworx volume will be mounted to for use | `test`
`file_path` | string | path for the portworx volume to be mounted to on the pods of the deployment | `/portworxDir`
