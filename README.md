# Cognito_app-migration-using-terraform

## Objective
I created an Amazon Cognito user pool and now I want to change the standard attributes required for user registration, But I am unable change standard user pool attributes after a user pool is created. Instead, created a new user pool with the attributes that you want to require for user registration. Then, migrate existing users to the new user pool by using an AWS Lambda function as a user migration trigger.

Clone the Project and navigate to the folder "cognito-app" and run the below command.
```t
python -m http.server 
```
the code will run on the PORT 8000,open the Browser and run the Below url
```t
localhost:8000
```
you will get the output as shown in below image.

![Screenshot (95)](https://user-images.githubusercontent.com/120295902/235646615-444e1946-0323-4395-9fac-0d55266d13d6.png)

after that go to the UserPool1 folder and navigate to the main file and run the command
```t
terraform init
```
then, use need to use the below command to validate the file
```t
terraform validate
```
and terraform plan will generate execution plan, showing you what actions will be taken without actuallay performing planned actions.
```t
terraform plan
```
after perform below command to deploy the application in aws and '--auto-approve' applying changes without having to interactively type 'yes' to the plan.
```t
terraform apply --auto-approve
```
in the output you will get a user pool id and client id in the output of terraform, take that value enter in the UserPool2 folder Program1.py file and apply the same commands as we did above.
