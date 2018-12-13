# psExtrahop
PowerShell Module for Extrahop

![](https://github.com/hematic/Storage/raw/master/CurrentExtrahopAPICoverage.PNG)

The image above shows the current API coverage for this module. There may be some minor updates before christmas but for the most part this is in a "finished" state before the holidays. Of course if you find any bugs or want improvements please raise an issue.

The end goal of this module is to provide total API coverage. I am aware there is amodule out there for Extrahop made by one of the technicians at the company. Its great work, and me choosing to make this is in no way a slight against that work. I needed to make this for two major reasons.

1. That module uses classes which are not available for all of my users do to version limitations.
2. That module has scant documentation and is pretty complicated to use if you arent use to the class sctructure.

This module is designed to be more "user friendly" with typical powershell function names for each individual API call.

There is an option for those of you who use self Signed certificates as well. Every command has the flag -AllowselfSignedCert which will allow invoke command to process these calls correctly.

I hope this helps some other people get comfortable with using Extrahop!