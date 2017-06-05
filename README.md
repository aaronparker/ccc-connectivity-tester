# Citrix Cloud Connector Connectivity Tester
A PowerShell script to test connectivity to URLs required by the Citrix Cloud Connector.

URLs are documented at [Citrix Cloud - Internet Connectivity Requirements](http://docs.citrix.com/en-us/citrix-cloud/overview/requirements/internet-connectivity-requirements.html).

The script makes a simple test to the target URL using Test-NetConnection and returns a success or fail result. To use, run the script with the following command:

     .\Test-CitrixCloudConnector.ps1 -Xml .\ccc-tests.xml
