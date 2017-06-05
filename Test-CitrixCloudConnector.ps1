<#
    .SYNOPSIS
        Tests connectivity for the Citrix Cloud Connector.

    .DESCRIPTION
        Reads ports and URLs required for outbound connectivity for the Citrix Cloud Connector. Tests each URL and returns a result for pass or fail.

    .NOTES
        Name: Test-CitrixCloudConnector.ps1
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .PARAMETER Xml
        The XML file that contains the details about the ports and URLs to test.

    .EXAMPLE
        .\Test-CitrixCloudConnector -Xml ".\Ccc-Tests.xml"

        Description:
        Tests the URLs listed in 'Ccc-Tests.xml' and returns the result.
#>
[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low", DefaultParameterSetName='Base')]
PARAM (
    [Parameter(ParameterSetName='Base', Mandatory=$True, Position=0, HelpMessage="The path to the XML document describing URLs and ports to test.")]
    [ValidateScript({ If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
    [string]$Xml
)

# Read the external XML file
Try {
    [xml]$xmlDocument = Get-Content -Path $Xml -ErrorVariable xmlReadError
}
Catch {
    Throw "Unable to read $Xml. $xmlReadError"
}

# Read the URLs into an array
$xmlURLs = (Select-Xml -XPath "/Tests/URLs" -Xml $xmlDocument).Node

# Read the port/s into an array
$xmlPorts = (Select-Xml -XPath "/Tests/Ports" -Xml $xmlDocument).Node

# Test each URL and output the result
ForEach ( $url in $xmlURLs.URL) {
    ForEach ($port in $xmlPorts.Port) {
        $result = Test-NetConnection -ComputerName $url -Port $port -InformationLevel Quiet
        If ($result) {
            Write-Host "Success: $($url):$port" -ForegroundColor Green
        } Else {
            Write-Host "Failed: $($url):$port" -ForegroundColor Red
        }
    }
}