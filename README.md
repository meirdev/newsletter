# Newsletter

An example of newsletter with Wing and AWS SES.

![Diagram](./assets/newsletter.svg)

## Configuration

Change the file `./wing/config.json`.

## Compile

```bash
cd wing
wing compile -t tf-aws main.w
```

## Deploy

Before you deploy the project, you need to manually create a new secret for your API key:

```bash
aws secretsmanager create-secret --name api-key --secret-string YOU-SECRET-KEY
```

Then:

```bash
cd wing/target/main.tfaws
terraform init
terraform apply
```
