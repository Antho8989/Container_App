This is a documentation on the conatainer App project
Repo : Container App Environment
Script : Terraform
Use Case : This is used to create the needed resources for a container app to operate with. {This resources can be reused for multiple container apps}
Resources : Resource group, Log Analytics, Container Registry and Container Environment

Steps
1. Configure the require pipeline.yml file located in the github workflows which includes the 
    a. customer_name 
    b. customer_prefix
    c. location (East US, Central US, e.t.c.)
    d. Environment Name (Dev, Sandbox or Prod)

2. Configure the following secrets in the settings on Github Repo {https://docs.github.com/en/actions/security-guides/encrypted-secrets}

    subscription_id:      ${{ secrets.subscription_id }}
    client_id:            ${{ secrets.client_id }}
    client_secret:        ${{ secrets.client_secret }}
    tenant_id:            ${{ secrets.tenant_id }}

3. Run the Github actions and the resources would be created alongside a sample "Hello World" Container App.

