# Vaultwarden Serverless 🚀

Welcome to the Vaultwarden Serverless project! This project leverages AWS Lambda, EFS, and serverless Postgres using Neon to provide a scalable and efficient password management solution. We also use Resend for SMTP to handle email notifications.

## Features ✨

- **AWS Lambda**: Serverless compute service that runs your code in response to events.
- **EFS**: Amazon Elastic File System for scalable file storage.
- **Neon**: Serverless Postgres database for reliable data storage.
- **Resend**: SMTP service for sending emails.

## Getting Started 🛠️

Follow these steps to get your Vaultwarden Serverless instance up and running.

### Prerequisites

- Docker
- Terraform
- Python 3 (available as `python3`)

### Deployment Steps

1. **Build the Vaultwarden Builder Docker Image** 🏗️

    ```sh
    make build
    ```

2. **Run the Docker Container** 🐳

    ```sh
    make run
    ```

3. **Initialize Terraform and update tfvars** 🌍

    ```sh
    make tf-init
    ```

    Update [terraform variables for your deployment](./infra/vault.tfvars)

4. **Plan the Terraform Deployment** 🗺️

    ```sh
    make tf-plan
    ```

5. **Apply the Terraform Deployment** 🚀

    ```sh
    make tf-apply
    ```

    AWS ACM will need you to verify your domain, go into the AWS console and [find your certificate](https://ap-southeast-2.console.aws.amazon.com/acm/home?region=ap-southeast-2#/certificates/list) take the CNAME name and remove your domain name from it. Then use this and your CNAME value for your DNS configuration.

    Once deployed terraform should output `api_gateway_cname_target`, add this value to your domain registrar settings with the name being the subdomain (or @ if no subdomain).

6. **Destroy the Terraform Deployment** 💣 (if needed)

    ```sh
    make tf-destroy
    ```

## Configure Resend for SMTP on Your Domain 📧

To configure Resend for SMTP, [follow these instructions](https://resend.com/docs/send-with-smtp)

## Makefile Commands

Refer to the [Makefile](./Makefile) for all the commands needed to build, run, and deploy the project.

Enjoy your new serverless password manager! 🎉
