# Citrix Cloud

## Citrix Cloud Connector Connectivity Tester

A PowerShell script to test connectivity to URLs required by the Citrix Cloud Connector.

URLs are documented at [Citrix Cloud - Internet Connectivity Requirements](http://docs.citrix.com/en-us/citrix-cloud/overview/requirements/internet-connectivity-requirements.html).

The script makes a simple test to the target URL using Test-NetConnection and returns a success or fail result. To use, run the script with the following command:

     .\Test-CitrixCloudUrls.ps1

The result should like similar to the following:

```text
Result  Host                            Port
------  ----                            ----
Success cloud.com                       443
Success citrixdata.com                  443
Fail    citrixworkspacesapi.net         443
Success sharefile.com                   443
Fail    servicebus.windows.net          443
Success browser-release-a.azureedge.net 443
Success browser-release-b.azureedge.net 443
Fail    blob.core.windows.net           443
Fail    nssvc.net                       443
Fail    xendesktop.net                  443
Success citrix.com                      443
Success wem.cloud.com                   443
```