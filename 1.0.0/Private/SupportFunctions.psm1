Function Get-ExtrahopHeaders{
    <#
        .SYNOPSIS
        Function to create the Extrahop Headers
        .DESCRIPTION
        This function extracts the code for header creation from each individual function for cleanliness purposes.
        .EXAMPLE
        New-ExtrahopHeaders -apiKey $apiKey
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [String]$apiKey = ''
    )
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('Authorization',("ExtraHop apikey=$apiKey"))
    $Headers.Add('Accept','application/json')

    Return $headers
}