# updateLambda.ps1
A helper function to make writing new AWS Lambda functions more efficient when developing in a Windows environment.

It automates the tedious process of deleting the previous local package.zip, creating a new local package.zip, uploading the .zip to s3, and updating the Lambda function to use the new code.
