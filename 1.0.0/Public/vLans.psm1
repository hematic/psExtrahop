Function Get-ExtrahopVlans{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop Vlans
        .DESCRIPTION
        This function allows you to retrieve all vlans or a specific vlan.
        .EXAMPLE
        Get-ExtrahopVlans -apiKey $apikey -appliance 'Command Appliance'
        .EXAMPLE
        Get-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -id 11
        .EXAMPLE
        Get-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -id 11 -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False, HelpMessage='Tag ID to return.')]
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
    $Endpoint = '/vlans'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    #region Build URI
    switch ($PsCmdlet.ParameterSetName)
    {
        'All' {
            $message = "Retrieving all vLans from $appliance @ $Uri"
            $URI = $Root + $Endpoint
        }

        'ByID' {
            $message = "Retrieving vLan {$id} from $appliance @ $Uri"
            $URI = $Root + $Endpoint + '/' + $ID
        }
    }

    #endregion
    Write-Host $message
    $vLans = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $vLans
}

Function Update-ExtrahopVlans{
    <#
        .SYNOPSIS
        Function to update an Extrahop Vlan.
        .DESCRIPTION
        This function allows you to update the friendly name or description of
        a specific vlan.
        .EXAMPLE
        Update-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -friendlyname "vLan 35 (Voice)"
        .EXAMPLE
        Update-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -description "Vlan is used for voip devices."
        .EXAMPLE
        Update-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -friendlyname "vLan 35 (Voice)" -description "Vlan is used for voip devices."
        .EXAMPLE
        Update-ExtrahopVlans -apiKey $apiKey -appliance 'Command Appliance' -friendlyname "vLan 35 (Voice)" -description "Vlan is used for voip devices." -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='Description')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [string]$id,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$false,ParameterSetName = 'FriendlyName')]
        [string]$description,

        [Parameter(Mandatory=$false,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$true,ParameterSetName = 'FriendlyName')]
        [string]$name
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
    $Endpoint = '/vlans'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint + "/" + $id
    switch ($PsCmdlet.ParameterSetName){
        'Description' {
            If($friendlyname){
                #region Body
                $Body = @"
{
    "description" : $description,
    "name" : $name
}
"@
                #endregion
            }
            Else{
                #region Body
                $Body = @"
{
    "description" : $description
}
"@
                #endregion
            }
        }

        'FriendlyName' {
            If($description){
                #region Body
                $Body = @"
{
    "description" : $description,
    "name" : $name
}
"@
                #endregion
            }
            Else{
                #region Body
                $Body = @"
{
    "name" : $name
}
"@
                #endregion
            }
        }
    }
    Write-Host "Retrieving vLan {$id} from $appliance @ $Uri"
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
}