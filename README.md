How to copy and use this repo for your own purposes

Variables you will want to pay attention to:
 - AWS login credentials for terraform user
 - GitHub Personal Access Token for setting github secrets
 - The website domain of your new application

Register with Amazon AWS
Make a service account in AWS IAM named terraform
Assign a policy with the permissions:
  allS3
  allCloudfront
  allRoute53
Generate a service key for the user terraform

Register with GitHub
Make a repo in the github account
Make github secrets for terraform service key as AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
Modify these source files being sure to replace the website domain!
Push these files to your new repo
Merge PR into development branch

-- Continuous Integration will now provision infrastrucure, build source code, and deploy application

Merge PR into production from development

-- application is now deployed to production

Congratulations, you will now be a dev ops expert one day maybe?!



General principals to make your future life easier in devops

- Development and production deployments are treated as isolate entities. They do not share servers, accounts, access, or have any overlap other than the source code they are made from.
- Docker is leveraged for both local development and deployment buildtime. This means you do not need to install any tooling on your system as the developer, other than docker-compose. And that means if it runs on your machine, it has an incredibly high likelyhood of running on someone else's machine.
- Webpack can be replaced with any other fancy web thingy you choose, or just use webpack. The modern way to write html is to not write it I suppose; Enter webpack.
- Terraform provides repeatable infrastructure setup, which is super important if you want to retain value in developing infrastructure.
