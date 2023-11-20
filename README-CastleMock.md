# Castle Mock Setup

Castle Mock is used to mock SOAP services. Creating a Castle Mock mocked SOAP service will be different for developers and testers.

  The developer will have to create the service from scratch and then export the mocked service into the application's code repository.  The tester will import the mocked service from the code repository into a running instance of Castle Mock.

## For the Developer (create mock service):

1. Download [Castle Mock](https://castlemock.com/) or install it with Docker with the command:

   docker run -d -p 8080:8080 castlemock/castlemock

2. Goto localhost:8080/castlemock in your browser to find the Castle Mock dashboard login page.  Use 'admin' and 'admin' for username and password respectively.

3. Click "New Project" button.

4. Give the project any name and then change 'Project Type' to 'SOAP' and click "Create Project".

5. Click 'Upload', click 'WSDL', choose 'Choose Files' and go to src/main/resources directory of this system API and select wfnallo1.wsdl.  Then click "Upload Files".

6. Click on the 'WSBPWR01Port' link under 'Ports'.

7. Return to the Castle Mock dashboard and  click on the 'WSBPWR01Operation' link under 'Operations'.

8. Click on "Create Response" button.

9. Give any name to the Response.

10. Go to the src/main/resources/soap folder of the system API project and copy the contents of the example_soap_response.xml file and then paste it into the Body section of the Castle Mock page (overwrite existing XML).

11. Click "Create Response".

12. Click 'Projects' icon in top left corner.

13. Click box next to the project name.

14.  Click 'Export projects' button.  This will download the Castlemock project to your computer.

15. Move the download to the project root directory and rename it 'CastleMockProject.xml'.

## For the Developer (configure mock service):

1. On the Castlemock main page, click on the project name link.
2. Click on the port name link.
3. Copy the URLs for the "Address" and the "WSDL".
4. The URLs will be placed in a yaml file in the [cdx-configs](https://bitbucket.org/navyfmp/cdx-configs/src/local/) repository.  See [Property Management](https://twenty8.atlassian.net/wiki/spaces/NAV/pages/518651923/Property+Management) documentation for additional information.

## For the Tester:

1. Download [Castle Mock](https://castlemock.com/) or install it with Docker using the command:

   `docker run -d -p 8080:8080 castlemock/castlemock`

2. Goto `localhost:8080/castlemock` in your browser and the Castle Mock dashboard login page should come up.  Use 'admin' and 'admin' for username and password respectively.

3. Click the "Import Project" button.

4. Find the "Project Type" dropdown, click the downward arrow and select 'SOAP.'

5. Click 'Choose Files,' and then seek and select the 'CastleMockProject.xml' file from the application's root directory.

6. Click 'Upload Files.'
