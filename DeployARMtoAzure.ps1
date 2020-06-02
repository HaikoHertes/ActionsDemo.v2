$templates = Get-ChildItem -Path "arm\" -Filter "template.json" -File -Recurse 
ForEach($template in $templates)
{   
    # Create RG if not allready existing
    $RGName = Split-Path $template.DirectoryName -Leaf
    $Location = Get-Content -Path "$($template.DirectoryName)\location.txt"
    $Tags = @{}
    
    If(Test-Path -Path "$($template.DirectoryName)\tags.txt")
    {
        $Tags = Get-Content "$($template.DirectoryName)\tags.txt" -Raw | ConvertFrom-StringData
        #(Get-Content "$($template.DirectoryName)\tags.txt" -Raw | ConvertFrom-StringData).GetType()
    }



    Get-AzResourceGroup -Name $RGName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent)
    {
        # ResourceGroup doesn't exist
        Write-Host "RG $RGName does not exist..."
        Write-Host "Location should be $Location"
        
        New-AzResourceGroup `
            -Name $RGName `
            -Location $Location `
            -Tags $Tags
    }
    else
    {
        # ResourceGroup exist
        Write-Host "RG $RGName does exist..."
        Write-Host "Location should be $Location"
        
    }
    New-AzResourceGroupDeployment `            -ResourceGroupName $RGName `            -TemplateFile "$($template.DirectoryName)\template.json" `            -TemplateParameterFile "$($template.DirectoryName)\parameters.json" `
            -Tag $tags

    
}