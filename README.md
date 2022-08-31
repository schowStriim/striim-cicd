# Striim CI/CD Repository - Business Development
### The purpose of this CI/CD pipeline is to deploy PoC infrastructure/resources to all cloud providers (AWS, Azure, and Google Cloud).

1) Deploys Striim images to all cloud providers.
2) Deploys Striim server to AWS as an EC2 instance with the latest image attached.
3) Deploys instance scheduler infrastructure to AWS.
4) Defines the CI/CD pipeline using Github Actions tools.

### How to use this CI/CD pipeline:
1) To deploy a new image version to all cloud provider:
  - Click on 'Actions' tab.
  - Select 'Image builds pipeline' on the left panel.
  - Click on 'Run Workflow' dropdown, select 'main' branch to get the latest changes and then click on 'Run workflow' button.
