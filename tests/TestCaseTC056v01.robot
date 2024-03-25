*** Settings ***

Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
Library    BuiltIn



*** Variables ***

${MyHostname}    demo6733
${MyRepositoryName}    TMPWEBV497TC056
# You must create the folder "MyFolderWorkspace" manually in the computer of Jenkins master, in case you test the script with the computer of Jenkins master
${MyFolderWorkspace}    C:/000/jenkins/workspace
${MyDirectoryDownload}    C:\\temp\\zDownload
${base_url_smtp_server}    http://localhost:8070

${MyPatient1FamilyName}    AZ127431
${MyPatient1FirstName}    ALBERT
${MyPatient1SeriesDescription}    CTOP127431

${MyPatient2FamilyName}    AZ138542
${MyPatient2FirstName}    ALBERT
${MyPatient2SeriesDescription}    CTOP138542
${MyPatient2BirthdateYYYY}    1956
${MyPatient2BirthdateMM}    12
${MyPatient2BirthdateDD}    28
${MyPatient2AccessionNumber}    CTEF138542

${MyPortNumber}    10000
#  Do not use the brackets to define the variable of bearer token
${bearerToken}    Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJJbnN0YWxsZXIiLCJuYW1lIjoiSW5zdGFsbGVyIiwiaXNzIjoiVGVsZW1pcyIsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxODYxOTIwMDAwfQ.pynnZ69Qx50wuz0Gh4lx-FHZznrcQkbMm0o-PLhb3S0

${MyBrowser1}    chrome
${MyBrowser2}    firefox
${MyBrowser3}    edge

${TmpWebAdministratorLogin}    telemis_webadmin
${TmpWebAdministratorPassword}    KEYCLOAKTastouk!

${TmpWebUser1Login}    anthony
${TmpWebUser1Password}    Videogames2024
${TmpWebUser1Email}    anthony@hospital8.com

${TmpWebUser2Login}    albert
${TmpWebUser2Password}    Videogames2024
${TmpWebUser2Email}    albert@hospital8.com

${TmpWebUser3Login}    mary
${TmpWebUser3Password}    Videogames2024
${TmpWebUser3Email}    mary@hospital8.com

# NOT USEFUL ${MyFolderResults}    results
${MyLogFile}    MyLogFile.log
${MyFolderCertificate}    security
${MyDicomPath}    C:/VER497TMP1/telemis/dicom

${MyEntityName1}    audit
${MyEntityPort1}    9940
${MyEntityName2}    dicomgate
${MyEntityPort2}    9920
${MyEntityName3}    hl7gate
${MyEntityPort3}    9930
${MyEntityName4}    patient
${MyEntityPort4}    9990
${MyEntityName5}    registry
${MyEntityPort5}    9960
${MyEntityName6}    repository
${MyEntityPort6}    9970
${MyEntityName7}    user
${MyEntityPort7}    9950
${MyEntityName8}    worklist
${MyEntityPort8}    9980

${VersionSiteManager}    4.1.2-228



*** Keywords ***

Remove The Previous Results
    [Documentation]    Delete the previous results and log files
    # Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/geckodriver*
    # Delete the previous screenshots
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/*.png
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/${MyLogFile}
    ${Time} =    Get Current Date
    Create file  ${MyFolderWorkspace}/${MyRepositoryName}/results/${MyLogFile}    ${Time}${SPACE}Start the tests \n
    # Remove DICOM files from dicomPath of TMAA
    Remove Files    ${MyDicomPath}/*.dcm
    Create Directory    ${MyDirectoryDownload}
    Remove Files    ${MyDirectoryDownload}\\*.zip


Check That Watchdog Is Running
    [Documentation]    Check that Watchdog is running
    create session    mysession    https://${MyHostname}:${MyPortNumber}/watchdog/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Watchdog
    [Documentation]    Check the version number of Watchdog
    create session    mysession    https://${MyHostname}:${MyPortNumber}/watchdog/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Watchdog ${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s
    # Should Contain    ${response.text}    ${VersionSiteManager}


Check That Site Manager Is Running
    [Documentation]    Check that Site Manager is running
    create session    mysession    https://${MyHostname}:${MyPortNumber}/site/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Site Manager
    [Documentation]    Check the version number of Site Manager
    create session    mysession    https://${MyHostname}:${MyPortNumber}/site/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Site Manager ${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s

    ${response} =    GET On Session    mysession    /identity    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    sitemanager
    Sleep    3s


Check That Telemis Entity Is Running
    [Documentation]    Check that Telemis Entity is running
    [Arguments]    ${MyEntityPort}
    create session    mysession    https://${MyHostname}:${MyEntityPort}/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Telemis Entity
    [Documentation]    Check the version number of entity
    [Arguments]    ${MyEntityName}    ${MyEntityPort}
    create session    mysession    https://${MyHostname}:${MyEntityPort}/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Telemis-${MyEntityName}${SPACE}${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s

    ${response} =    GET On Session    mysession    /identity    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    ${MyEntityName}
    Sleep    3s


Take My Screenshot
    ${MyCurrentDateTime} =    Get Current Date    result_format=%Y%m%d%H%M%S
    Log    ${MyCurrentDateTime}
    # Keyword of SeleniumLibrary, you do not need to use the library Screenshot
    Capture Page Screenshot    selenium-screenshot-${MyCurrentDateTime}.png
    Sleep    2s


Open My Site Manager
    Open Browser    https://${MyHostname}:10000/site    Chrome    options=add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Wait Until Element Is Visible    id=kc-login    timeout=15s
    Maximize Browser Window
    Sleep    2s
    Input Text    id=username    local_admin    clear=True
    Input Text    id=password    KEYCLOAKTastouk!    clear=True
    Sleep    2s
    Click Button    id=kc-login
    # Locator of Selenium IDE
    Wait Until Element Is Visible    xpath=//strong[contains(.,'Site Manager')]    timeout=15s
    Element Should Be Visible    xpath=//strong[contains(.,'Site Manager')]
    Sleep    2s


Log Out My User Session Of Site Manager
    Click Link    link:Sign out
    Wait Until Element Is Visible    id=kc-login    timeout=15s
    Element Should Be Visible    id=kc-login
    Sleep    2s


My User Opens Internet Browser And Connects To My TMP Web
    [Documentation]    The user opens Internet browser and then connects to the website of TMP Web
    [Arguments]    ${MyUserLogin}    ${MyUserPassword}
    Open Browser    https://${MyHostname}.telemiscloud.com/tmpweb/patients.app    Chrome    options=add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Wait Until Page Contains    TM-Publisher web    timeout=15s
    Maximize Browser Window
    Wait Until Element Is Visible    id=username    timeout=15s
    Wait Until Element Is Visible    id=password    timeout=15s
    Input Text    id=username    ${MyUserLogin}    clear=True
    Input Text    id=password    ${MyUserPassword}    clear=True
    Sleep    2s
    Click Button    id=kc-login
    Wait Until Page Contains    Telemis Media Publisher Web    timeout=15s
    Sleep    3s


Log Out My User Session Of TMP Web
    Click Link    link=Logout
    Wait Until Element Is Visible    xpath=//*[@id="doctor-button"]    timeout=15s
    Sleep    2s


Delete All My Email Messages In SMTP Server
    [Documentation]    Delete all the email messages in SMTP server
    Create Session    AppAccess    ${base_url_smtp_server}
    ${response} =    Delete On Session    AppAccess    /api/emails
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s



*** Test Cases ***

Test01
    [Documentation]    Reset the test results
    [Tags]    CRITICALITY LOW
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/*.png
    # Delete the study in TMP Web
    # Run  C:/Users/albert/Desktop/DELETE/zDelStudyRepublish2.bat
    Sleep    3s


Test02
    [Documentation]    Check and reset the folder of downloaded files
    [Tags]    CRITICALITY LOW
    Create Directory    C:\\temp
    ${ListOfDir} =    List Directories In Directory    C:\\temp
    # The line mentioned below is only for tests
    # Should Contain    ${ListOfDir}    zDownload
    ${NbrOfDir} =    Get Count    ${ListOfDir}    zDownload
    Log    The number of folder(s) is ${NbrOfDir}
    Run Keyword If    ${NbrOfDir} == 1    Remove Directory    ${MyDirectoryDownload}    recursive=True
    Directory Should Not Exist    ${MyDirectoryDownload}
    Create Directory    ${MyDirectoryDownload}
    ${NbrOfZip} =    Count Files In Directory    ${MyDirectoryDownload}
    Log    The number of zip file(s) is ${NbrOfZip}
    Should Be True    ${NbrOfZip} == 0


Test03
    [Documentation]    Test and check SMTP server
    [Tags]    CRITICALITY LOW
    Open Browser    http://localhost:8070/    Chrome    options=add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Maximize Browser Window
    Wait Until Page Contains    FakeSMTPServer    timeout=15s
    Wait Until Page Contains    Inbox    timeout=15s


Test04
    [Documentation]    Reset the list of email messages in SMTP server
    [Tags]    CRITICALITY LOW
    Delete All My Email Messages In SMTP Server
    Sleep    2s
    Go To    http://localhost:8070/
    Sleep    1s
    Close All Browsers


Test05
    [Documentation]    Open and access the website of TMP Web in anonymous mode
    [Tags]    CRITICALITY NORMAL
    # Check that the option "Ask where to save each file before downloading" is disabled in the settings of Chrome
    ${prefs} =    Create Dictionary    download.default_directory=${MyDirectoryDownload}
    Open Browser    https://${MyHostname}.telemiscloud.com/tmpweb/patient.html    chrome    options=add_experimental_option("prefs",${prefs});add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Maximize Browser Window
    Wait Until Page Contains    TM-Publisher web    timeout=15s
    Wait Until Element Is Visible    id=kc-locale-dropdown    timeout=15s


Test06
    [Documentation]    Select the language
    [Tags]    CRITICALITY LOW
    ${c} =    Get Element Count    id=kc-locale-dropdown
    Run Keyword If    ${c}>0    Click Element    id=kc-locale-dropdown
    # Sleep    2s
    # The keyword Select From List By Index/Label/Value does not work with the combo box of this web page
    Wait Until Element Is Visible    link=English    timeout=15s
    Element Should Be Visible    link=English
    Sleep    1s
    Click Element    link=English
    Mouse Over    id=id


Test07
    [Documentation]    Enter the keys in anonymous mode of TMP Web
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains    Unique exam    timeout=15s
    Wait Until Element Is Visible    id=id    timeout=15s
    Wait Until Element Is Visible    id=birthdate    timeout=15s
    Wait Until Element Is Visible    id=en    timeout=15s
    # Wait Until Page Contains    Access    timeout=15s
    Input Text    id=id    ${MyPatient2AccessionNumber}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=id    ${MyPatient2AccessionNumber}
    Input Text    id=birthdate    ${MyPatient2BirthdateYYYY}-${MyPatient2BirthdateMM}-${MyPatient2BirthdateDD}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=birthdate    ${MyPatient2BirthdateYYYY}-${MyPatient2BirthdateMM}-${MyPatient2BirthdateDD}
    Take My Screenshot
    Click Button    id=en


Test08
    [Documentation]    The web page shows the message "Documents are not available."
    [Tags]    CRITICALITY HIGH
    Wait Until Page Contains    Documents are not available.    timeout=15s
    Wait Until Page Contains    Email Address:    timeout=15s
    Wait Until Element Is Visible    id=userEmail    timeout=15s
    Wait Until Element Is Visible    id=republishActionButton    timeout=15s


Test09
    [Documentation]    The user enters the email address and then clicks the button "Republish documents"
    [Tags]    CRITICALITY HIGH
    Element Should Be Visible    id=userEmail
    Element Should Be Visible    id=republishActionButton
    Input Text    id=userEmail    ${TmpWebUser3Email}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=userEmail    ${TmpWebUser3Email}
    Click Button    id=republishActionButton
    # The application takes about 43s to publish the study again
    Wait Until Page Contains    Documents are being published    timeout=99s
    Sleep    19s
    Take My Screenshot


Test10
    [Documentation]    Once TMP Tool Web has published the study completely, check that the document is available on the web page
    [Tags]    CRITICALITY HIGH
    Wait Until Page Contains    ${MyPatient2BirthdateDD}-${MyPatient2BirthdateMM}-${MyPatient2BirthdateYYYY}    timeout=300s
    Wait Until Page Contains    Download the following study    timeout=15s
    Wait Until Element Is Visible    link=DCM    timeout=15s
    Wait Until Element Is Visible    link=JPG    timeout=15s
    Wait Until Element Is Visible    link=${MyPatient2SeriesDescription}    timeout=15s
    Wait Until Page Contains    Anonymous link:    timeout=15s
    Sleep    2s
    Take My Screenshot


Test11
    [Documentation]    Download JPG files from the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    # Check that the option "Ask where to save each file before downloading" is disabled in the settings of Chrome
    Wait Until Page Contains    Download the following study    timeout=15s
    Wait Until Element Is Visible    link=DCM    timeout=15s
    Wait Until Element Is Visible    link=JPG    timeout=15s
    Sleep    2s
    Click Link    link=JPG
    # The tool tip "The download has been lauched. Depending on the nimber ..." is too big and hides the button, it disappears after 6 seconds
    Sleep    6s


Test12
    [Documentation]    Check that downloading JPG files passed successfully
    [Tags]    CRITICALITY NORMAL
    Wait Until Created    ${MyDirectoryDownload}\\*.zip    timeout=240s
    Sleep    2s
    ${ListOfZip} =    List Files In Directory    ${MyDirectoryDownload}
    ${NbrOfZip} =    Count Files In Directory    ${MyDirectoryDownload}
    Should Be Equal As Numbers    ${NbrOfZip}    1
    # Reset the folder of downloaded files
    Remove File    ${MyDirectoryDownload}\\*.zip
    ${NbrOfZip} =    Count Files In Directory    ${MyDirectoryDownload}
    Should Be True    ${NbrOfZip} == 0


Test13
    [Documentation]    Download DICOM files from the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    Reload Page
    Wait Until Page Contains    Download the following study    timeout=15s
    Wait Until Element Is Visible    link=DCM    timeout=50s
    Element Should Be Visible    link=DCM
    Sleep    2s
    # Click the button "Copy link to clipboard"
    Click Button    css=.copy-link
    Sleep    2s
    Click Link    link=DCM


Test14
    [Documentation]    Check that downloading DCM files passed successfully
    [Tags]    CRITICALITY NORMAL
    Wait Until Created    ${MyDirectoryDownload}\\*.zip    timeout=240s
    Sleep    2s
    ${ListOfZip} =    List Files In Directory    ${MyDirectoryDownload}
    ${NbrOfZip} =    Count Files In Directory    ${MyDirectoryDownload}
    Should Be Equal As Numbers    ${NbrOfZip}    1


Test15
    [Documentation]    The user opens the series with the image viewer
    [Tags]    CRITICALITY NORMAL
    Element Should Be Visible    link=${MyPatient2SeriesDescription}
    Click Link    link=${MyPatient2SeriesDescription}
    Wait Until Page Contains    Non-diagnostic quality    timeout=19s
    Wait Until Element Is Visible    link=Full screen    timeout=15s
    Wait Until Page Contains    ${MyPatient2SeriesDescription}    timeout=15s
    Wait Until Element Is Visible    link=DICOM download    timeout=15s
    Wait Until Element Is Visible    link=JPEG download    timeout=15s
    Sleep    4s
    Take My Screenshot
    # Quit the website
    Wait Until Element Is Visible    link=Terminate    timeout=15s
    Click Link    link=Terminate
    Wait Until Element Is Visible    xpath=//*[@id="doctor-button"]    timeout=15s


Test16
    [Documentation]    The user receives the email message informing that the document is available in TMP Web
    [Tags]    CRITICALITY NORMAL
    Go To    http://localhost:8070/
    Wait Until Page Contains    FakeSMTPServer    timeout=15s
    Wait Until Page Contains    Inbox    timeout=15s
    Wait Until Page Contains    ${TmpWebUser3Email}    timeout=15s
    Wait Until Page Contains    Documents available online    timeout=15s
    # CSS of the field "Documents available online"
    Wait Until Element Is Visible    css=.MuiDataGrid-cell:nth-child(4) > .MuiDataGrid-cellContent    timeout=15s
    Sleep    1s
    Click Element    css=.MuiDataGrid-cell:nth-child(4) > .MuiDataGrid-cellContent
    Wait Until Page Contains    Your documents are now available online    timeout=15s
    Take My Screenshot


Test17
    [Documentation]    Shut down the browser and reset the cache
    [Tags]    CRITICALITY LOW
    Close All Browsers
