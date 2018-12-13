Function Get-ExtrahopTags{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop Tags
        .DESCRIPTION
        This function allows you to retrieve all tags, a specific tag, or all the devices for a tag.
        .EXAMPLE
        Get-ExtrahopTags -apiKey $apiKey -appliance 'Command Appliance'
        .EXAMPLE
        Get-ExtrahopTags -apiKey $apiKey -appliance 'Command Appliance' -id 11
        .EXAMPLE
        Get-ExtrahopTags -apiKey $apiKey -appliance 'Command Appliance' -id 11 -devices $devices
        .EXAMPLE
        Get-ExtrahopTags -apiKey $apiKey -appliance 'Command Appliance' -id 11 -devices $devices -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$id,

        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$devices
    )
    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $Endpoint = '/tags'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    #region Build URI
    switch ($PsCmdlet.ParameterSetName)
    {
        'All' {
            $URI = $Root + $Endpoint
        }

        'ByID' {
            $URI = $Root + $Endpoint + '/' + $ID
        }
        
        'Devices' {
            $URI = $Root + $Endpoint + '/' + $ID + '/' + 'devices'
        }
    }

    #endregion
    Write-Host "Retrieving Tags from $appliance @ $Uri"
    $Tags = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $Tags
}

Function New-ExtrahopTag{
    <#
        .SYNOPSIS
        Function to create a new Extrahop Tag
        .DESCRIPTION
        This function allows you to create a new tag on an appliance.
        .EXAMPLE
        New-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -name 'APITest'
        .EXAMPLE
        New-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -name 'APITest' -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$name,
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert
    )

    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $Endpoint = '/tags'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    $Body = @{
        "name" = "$name"
    } | ConvertTo-JSON

    Write-Host "Creating Tag on $appliance"
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $body -ErrorAction Stop
}

Function Add-ExtrahopTagToDevices{
    <#
        .SYNOPSIS
        Function to add an Existing Tag to a device(s)
        .DESCRIPTION
        This function allows you to create a new tag on an appliance.
        .EXAMPLE
        Add-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -name 'APITest'
        .EXAMPLE
        Add-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -name 'APITest' -devices $Devices
        .EXAMPLE
        Add-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -name 'APITest' -devices $Devices -AllowSelfSignedcert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$name,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [array]$devices
    )
    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $Endpoint = '/tags'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    $array = $devices | ConvertTo-JSON
    #region body
    $Body = @"
{
    "assign" : $array
}
"@
    #endregion
    Write-Host "Creating Tag on $appliance"
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $body -ErrorAction Stop
}

Function Remove-ExtrahopTag{
    <#
        .SYNOPSIS
        Function to remove Extrahop Tags
        .DESCRIPTION
        This function allows you to remove a specific tag entirely or from one or more devices.
        .EXAMPLE
        Remove-ExtrahopTag -apiKey $apiKey -appliance 'Command Appliance' -id 11
        .EXAMPLE
        Remove-ExtrahopTag -apiKey $apiKey -appliance 'Command Appliance' -id 11 -devices $devices
        .EXAMPLE
        Remove-ExtrahopTag -apiKey $apiKey -appliance 'Command Appliance' -id 11 -devices $devices -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$id,

        [Parameter(Mandatory=$True,ParameterSetName = 'Devices')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$devices
    )
    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $Endpoint = '/tags'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    switch ($PsCmdlet.ParameterSetName){
        'ByID' {
            $URI = $Root + $Endpoint + '/' + $ID
        }

        'Devices' {
            $URI = $Root + $Endpoint + '/' + $ID + '/' + 'devices'
        }
    }

    Write-Host "Retrieving Tags from $appliance @ $Uri"
    $Tags = Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
    Return $Tags
}

Function Edit-ExtrahopTag{
    <#
        .SYNOPSIS
        Function to edit the name of an Existing Tag
        .DESCRIPTION
        This function allows you to change the name of a tag on an appliance.
        .EXAMPLE
        Edit-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -newTagName 'APITest' -id 11
        .EXAMPLE
        Edit-ExtrahopTag -apiKey $apiKey -appliance "Command Appliance" -newTagName 'APITest' -id 11 -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$newTagName,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$id
    )
    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $Endpoint = '/tags'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint + '/' + $id
    #region body
    $Body = @"
{
    "name" : $name
}
"@
    #endregion
    Write-Host "Renaming Tag {id:$id} to $name on $appliance"
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $body -ErrorAction Stop
}