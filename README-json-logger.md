# JSON Logger

JSON Logger is a logging component that replaces the default Mule logger.  It outputs logs in JSON format.

By default JSON Logger includes many data points that make it easier to identify the application, the location in the code, and the transaction/event that the logged information comes from. In addition, the JSON data can be customized by adding payload and variable values from the Mule application.  

## Install Json-logger from Anypoint Exchange

1. In Anypoint Studio, right click on project name and scroll down to 'Properties' and click it.
2. In next window, click on 'Mule Project' and then click on 'Modules'.
3. Click green plus sign on right panel.
4. Click 'from Exchange'.
5. Log in to Exchange from this page, if not already logged in.
6. In the search bar, type 'JSON'.
7. Click on 'JSON Logger - Mule 4' and then click the 'Add >' button to the right of the box.
8. Click 'Finish'.
9. Click 'Apply and Close'.

## Building the json-logger fork project

In order to integrate JSON Logger with Navy FMP Anypoint Exchange, we forked [json-logger](https://github.com/mulesoft-consulting/json-logger/tree/mule4-v2.0.1/) on 7/29/2020. The only customization is the groupId in pom.xml.

- The forked repo is [here](https://bitbucket.org/navyfmp/json-logger/src/mule-4.x/)
- The built artifacts are [here](https://nexus.kube.navy.ms3-inc.com/service/rest/repository/browse/maven-releases/6ff73618-f380-4f93-b293-e1fcf4af8fa0). (Requires [VPN](https://twenty8.atlassian.net/wiki/spaces/NAV/pages/442171575/Developer+Workstation+VPN+Setup) access)

## Trouble Shooting

##### Issue
The first time building an application that uses json-logger, mvn throws error:

    Could not transfer artifact 6ff73618-f380-4f93-b293-e1fcf4af8fa0:json-logger:pom:2.0.1 from/to ms3_navy_nexus (https://nexus.kube.navy.ms3-inc.com/repository/central/): nexus.kube.navy.ms3-inc.com: nodename nor servname provided, or not known: Unknown host nexus.kube.navy.ms3-inc.com: nodename nor servname provided, or not known -> [Help 1]
##### Solution
Maven needs to access nexus.kube.navy.ms3-inc.com to download the json-logger jar.
You need to be connected to the [project VPN](https://twenty8.atlassian.net/wiki/spaces/NAV/pages/442171575/Developer+Workstation+VPN+Setup).
