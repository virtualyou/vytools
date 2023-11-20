# Anypoint Studio #
Anypoint Studio is the IDE for daily Mulesoft development activities.
This README outlines how to install Anypoint Studio,
and how to load and run various API projects.

##### Anypoint 7 #####
Official download page: https://www.mulesoft.com/lp/dl/studio
This project was developed using Anypoint 7 and Mule 4.2

###### Windows
Example download link: https://mule-studio.s3.amazonaws.com/7.4.1-U1/AnypointStudio-for-win-64bit-7.4.1-201911261732.zip
Unzip into, eg: `C:\apps\anypoint-studio-7.4.1`
Sample startup:
    C:\apps\anypoint-studio-7.4.1\AnypointStudio.exe -data "C:\projects"-vm "%JAVA_HOME%\bin\javaw.exe"

##### Import projects into Anypoint Studio
    File > Import...
        Anypoint Studio
            Anypoint Studio project from File System
                Project Root: <path>/cdx-mule-domain
                (uncheck Copy project into workspace)

Repeat for each:
- `cdx-commons`
- `sabrs-sapi`
- `sabrs-validation-api`
- `sabrs-papi`
- `sabrs-xapi`
- `sabrs-legacy-soap`

##### Define your Application Launcher
The launcher will startup the applications of the domain together as a running stack.

    cdx-mule-domain (right-click)
        Run As > Mule Application (configure)
            Arguments
                VM arguments
                    -Dorg.mule.runtime.core.internal.processor.LoggerMessageProcessor=INFO
Note - The default for the last property is INFO, this just makes it easy to set it to DEBUG as needed.

##### Running MUnit test suites
    sabrs-sapi (right-click)
        MUnit > Run Tests
    sabrs-validation-api (right-click)
        MUnit > Run Tests
    sabrs-papi (right-click)
        MUnit > Run Tests
    sabrs-xapi (right-click)
        MUnit > Run Tests
    sabrs-legacy-soap (right-click)
        MUnit > Run Tests
And similar for other API groupings, such as advana-*

It is also useful to define *Working set(s)* that exclude .git and target directory contents.
This can be done from the Search dialog. For example:

    Search > Search
        Working set: [Choose]
            [New...]
                Resource
                [Next>]
                    Working set name: cdx-mule-domain
                    ☒ cdx-mule-domain
                        ☐ .git
                        ☒ src
                        ☐ target
                        ☒ .classapth
                              :
                    [Finish]

##### Memory configurations

Java launcher memory requirements (
These go in the "VM arguments" section in the "Arguments" tab

|  apps   | -XX:MaxMetaspaceSize=                 |
| ------- | ------------------------------------- |
| 1-2     | 256m (eg, smartlh)                    |
| 3-4     | 384m (eg, monitoring)                 |
| several | 512m (eg, advana)                     |
| 10+     | 1024m (eg, smarts + smartlh + sabrgl) |


##### Trouble Shooting

###### Issue
Getting 503 error, with no log messages in the Console.
###### Solution 1
CDX applications use API Auto-discovery.
This is controlled by the `<api-gateway` tag in global.xml of each application.
In order to run these apps successfully in Anypoint Studio, you need to disable the Gatekeeper.

    Run configuration
        Program arguments
            -Danypoint.platform.gatekeeper=disabled
###### Solution 2
Alternately, provided a Client ID & Client Secret. (These do NOT need to be valid to prevent the 503 errors.)

    Preferences
        Anypoint Studio
            API Manager
                Environment Credentials

Note that if the credentials are not valid, the authentication will be retried periodically,
resulting in a harmless error message in the Console.

###### Issue
When launching app(s), pop-up appears:
  "There is a Mule runtime version mismatch between the projects configuration and launch configuration"
###### Solution
If the `app.runtime` version in the pom.xml has been changed recently, all Studio launchers need to be updated:

    Run Configurations...
      General
        Target Server Runtime

If the desired version is not in the list of selectable runtimes, click [Install Runtimes], and select the desired Mule Server Runtime.
A restart of Anypoint Studio will be necessary for the newly installed runtime to become available for use.

###### Issue
An app responds with a 503, with no output in the log console
###### Solution 1
This can be caused by low memory.
Specify this option in the VM arguments of the Run Configuration, eg:
-XX:MaxMetaspaceSize=512m
###### Solution 2
This can also be caused by missing Credentials.
Specify Client Id and Client Secret in Preferences > Anypoint Studio > API Manager.
The values do not need to be valid ones to prevent this error.
