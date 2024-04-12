# CD Toolchain

## Description

A toolchain is a set of tool integrations that support development, deployment, and operations tasks. This guide describes how to setup tolchain to manage a schematics workspace. The toolchain will contain the following tool integrations:

- [GitHub](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-github)
- [Delivery Pipeline](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-deliverypipeline)
- [Other Tool (Schematics)](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-othertool)

## Table of Contents

- [CD Toolchain](#cd-toolchain)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Create Toolchain](#create-toolchain)
  - [Add Github Integration](#add-github-integration)
  - [Add Delivery Pipeline Integration](#add-delivery-pipeline-integration)
    - [Configure Integration](#configure-integration)
    - [Configure Tekton Repository](#configure-tekton-repository)
    - [Configure Workers](#configure-workers)
    - [Configure Input Variables](#configure-input-variables)
    - [Configure Commit Trigger](#configure-commit-trigger)
    - [Configure Manual Trigger](#configure-manual-trigger)
  - [Add Other Tool (Schematics) Integration](#add-other-tool-schematics-integration)

## Prerequisites

- [Created schematics workspace](https://cloud.ibm.com/docs/schematics?topic=schematics-sch-create-wks&interface=ui).
- Image [pipeline-ubi](../apps/pipeline-ubi/README.md) built and pushed to the [registry](../terraform/ibm-icr/README.md).
- [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).
- [IBM Cloud API key](https://cloud.ibm.com/docs/account?topic=account-manapikey).
- IBM Container Registry pull secret. The secret must be in docker config format and encoded as base64:

```bash
base64 <<EOT
{
    "auths": {
        "<server>": {
            "username": "iamapikey",
            "password": "<api-key>",
            "email": "<user-email>",
            "auth": "$(echo -n 'iamapikey:<api-key>' | base64)"
        }
    }
}
EOT
```

## Quick Start

[![Deploy To IBM Cloud](https://console.bluemix.net/devops/graphics/create_toolchain_button.png)](https://cloud.ibm.com/devops/setup/deploy?repository=https://github.com/szatkowskip/iac-pattern-guide&env_id=ibm:yp:us-south)

## Create Toolchain

- Log in to [IBM Cloud](http://cloud.ibm.com/).

- From the IBM Cloud console, click the menu (hamburger) icon, and select **DevOps > Toolchains**.

- On the Toolchains page, click **Create Toolchain**.

- On the Create Toolchain page, click the **Build your own toolchain** template and enter the details.

  - **Toolchain name**: `<toolchain_name>`
  - **Select region**: `<region>`
  - **Select a resource group**: `<resource_group>`

- Click **Create**.

## Add Github Integration

- In the created toolchain, select **Overview** and click **Add**.

- From the Tool Integrations list, select **GitHub** and enter the details.

  - **GitHub Server**: `GitHub (https://github.com)`
  - **Auth type**: `Personal Access Token`
  - **Personal Access Token**: `<github-personal-access-token>`
  - **Repository type**: `Existing`
  - **Repository URL**: `https://github.com/nordcloud/mco-ibm-cloud`
  - **Enable GitHub Issues**: &#9745;
  - **Track deployment of code changes**: &#9745;

- Click **Create Integration**.

## Add Delivery Pipeline Integration

### Configure Integration

- From the Tool Integrations list, select **Delivery Pipeline** and enter the details.

    - **Pipeline name**: `<pipeline-name>`
    - **Pipeline type**: `Tekton`

- Click **Create Integration**.

### Configure Tekton Repository

- Go to the toolchain, select **Overview** and in **Delivery pipelines** section click the created pipeline name. As the pipeline is not yet configured, you should be automatically moved to **Settings**.

- In the pipeline's settings, select **Definitions** and click **Add**. Enter github repozitory details that provides tekton pipeline definition.

  - **Repository**: `mco-ibm-cloud (https://github.com/nordcloud/mco-ibm-cloud.git)`
  - **Input type**: `Branch`
  - **Branch**: `<branch-name>`
  - **Path**: `.tekton`

- Click **Add**, then **Save**.

### Configure Workers

- In the pipeline's settings, select **Workers** and enter the details.

  - **Worker**: `IBM Managed workers`

- Click **Save**.

### Configure Input Variables

- In the pipeline's settings, select **Environment Properties**. By clicking `Add` enter all required input variables.

  - **WORKSPACE_ID** [*Text value*]: `<workspace-id>`
  - **ibmcloud-api** [*Text value*]: `https://cloud.ibm.com`
  - **apikey** [*Secure value*]: `<ibm-api-key>`
  - **git-token** [*Secure value*]: `<git-token>`
  - **icr-pull-secret** [*Secure value*]: `<base64-encode-dockerconfigjson>`
  - **enable-automatic-plan-apply** [*Text value*]: `true`
  - **pipeline-debug** [*Enumeration*]: `0`

### Configure Commit Trigger

- Go to the toolchain, select **Overview** and in **Delivery pipelines** section click the created pipeline name.

- Click **Add** and select **Git Repository**. Enter the details.

  - **Trigger name**: `github-ci`
  - **EventListener**: `github-ci-listener (https://github.com/nordcloud/mco-ibm-cloud.git)`
  - **Worker**: `Inherited from Pipeline Configuration`
  - **Limit concurrent runs**: &#9745;
  - **Max concurrent runs**: `1`
  - **Repository**: `mco-ibm-cloud (https://github.com/nordcloud/mco-ibm-cloud.git)`
  - **Input type**: `Branch`
  - **Branch**: `<branch-name>`
  - **When commit is pushed**: &#9745;

- Click **Add**.

### Configure Manual Trigger

- Go to the toolchain, select **Overview** and in **Delivery pipelines** section click the created pipeline name.

- Click **Add** and select **Manual**. Enter the details.

  - **Trigger name**: `manual`
  - **EventListener**: `manual-listener (https://github.com/nordcloud/mco-ibm-cloud.git)`
  - **Worker**: `Inherited from Pipeline Configuration`
  - **Limit concurrent runs**: &#9745;
  - **Max concurrent runs**: `1`

- Click **Add**.

## Add Other Tool (Schematics) Integration

> [!NOTE]
> This is an optional, "dummy" integration that only points to a schematics workspace managed by the pipeline.


- From the Tool Integrations list, select **Other Tool** and enter the details.

  - **Tool name**: `Schematics`
  - **Lifecycle phase**: `MANAGE`
  - **Icon URL**: `https://cloud.ibm.com/schematics/img/schematics-icon-f5c6503990.svg`
  - **Documentation URL**: `https://cloud.ibm.com/docs/schematics?topic=schematics-about-schematics`
  - **Tool instance name**: `IBM Cloud Schematics workspace`
  - **Tool instance URL**: `/schematics/workspaces/<workspace-id>`
  - **Description**: `Terraform-as-a-Service`

- Click **Create Integration**.
