param (
    [Parameter(Mandatory=$true)][string]$functionName,
    [Parameter(Mandatory=$true)][string]$sourcePath,
    [Parameter(Mandatory=$true)][string]$accessKey,
    [Parameter(Mandatory=$true)][string]$secretAccessKey,
    [Parameter(Mandatory=$true)][string]$region,
    [Parameter(Mandatory=$true)][string]$environment
)


function DeleteZip ( $fullZipPath )
{
    if (Test-Path $fullZipPath)
    {
        write-host "Deleting $fullZipPath..." -NoNewline
        Remove-Item $fullZipPath -Force
        write-host "DONE!"
    }

}


function CreateZip ( $sourcePath, $fullZipPath )
{
    write-host "Zipping $sourcePath >> $fullZipPath..." -NoNewline
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($sourcePath, $fullZipPath)
    write-host "DONE!"
}


function UploadTOS3 ( $zipFile, $fullZipPath, $bucketName)
{
    write-host "uploading $zipFile to S3::$bucketName/$zipFile ..." -NoNewline
    Write-S3Object -BucketName $bucketName -Key $zipFile -File $fullZipPath
    write-host "DONE!"
}


function UpdateLambdaFunction ( $functionName, $bucketName, $zipFile, $region  )
{
    write-host "updating lambda function: $functionName ..." -NoNewline
    Update-LMFunctionCode -FunctionName $functionName -S3Bucket $bucketName -S3Key $zipFile -Region $region
    write-host "DONE!"
}

################### script entry point
$fullZipPath = "$PSScriptRoot\$functionName.zip"
$zipFile = "$functionName.zip"
$fullZipPath = "$PSScriptRoot\$functionName.zip" 
$bucketName = "$environment-lambdacode-uaa" #2nd and 3rd nodes of this don't change often enough to make params

DeleteZip $fullZipPath
CreateZip $sourcePath $fullZipPath

write-host "clearing previous AWS Sessions..." -NoNewline
Clear-AWSCredentials
Clear-AWSDefaults
Clear-AWSHistory
write-host "DONE!"

write-host "initializing AWS Session ..." -NoNewline
Initialize-AWSDefaults -AccessKey $accessKey  -SecretKey $secretAccessKey  -Region $region
write-host "DONE!"

UploadTOS3 $zipFile $fullZipPath $bucketName

UpdateLambdaFunction $functionName $bucketName $zipFile $region