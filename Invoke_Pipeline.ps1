$file_path = Get-Content -Path "<path-of-the-file>/dummy_data.json" | ConvertFrom-Json

$count=0
$resourceType= $file_path.resources.properties.resourceType

$user=""            # Providing with the user name
$pipelineName=""    # Providing with the pipeline name
$pipelineId=""      # Providing with the pipeline ID
$token =""          #ADO Pipeline PAT Token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))
$orgName =""        # Providing with the organisation name
$projName =""       # Providing with the project name, E.g:-storage-account
$BuildPipelineUrl = "https://dev.azure.com/$orgName/$projName/_apis/pipelines?api-version=7.0"

    $BuildPipelineInfo = (Invoke-RestMethod -Uri $BuildPipelineUrl -Method Get -UseDefaultCredential -Headers @{Authorization="Basic {0}" -f $base64AuthInfo})
    foreach ($singleBuildPipelineInfo in $BuildPipelineInfo.value) {
        $pipelineName=$singleBuildPipelineInfo.name
        $pipelineId=$singleBuildPipelineInfo.id
    }

$resource_type = $file_path.resources
foreach ($number in $resource_type)
{ 
    $resource_type_name = $file_path.resources[$count].name

    $resource_type_in_file = $file_path.resources[$count].properties.resourceType

    $all_resource_type = $file_path.resources[$count].properties.resourceType

 if($resource_type_name -eq $resource_type_in_file -And $resource_type_in_file -eq $all_resource_type)
  {    

    if($resource_type_in_file -eq $pipelineName)
    {

      Write-Host "Storage account call" #Calling the ADO pipeline

      $url = "https://dev.azure.com/$orgName/$projName/_apis/pipelines/$pipelineId/runs?api-version=7.0-preview"

$body = @{

   resources = @{

        repositories = @{

            self = @{

                 refName = "refs/heads/main"

            }

        }
   }

} | ConvertTo-Json

$response = Invoke-RestMethod -Method Post -Uri $url -Headers @{Authorization = "Basic $base64AuthInfo"} -ContentType "application/json" -Body $body

Write-Host $response

# Pipeline Status
# $response1 = [PSCustomObject] @{

#    status = "Pipeline triggered successfully."

# }  


    }
  }

    $count++

}