*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop.OperatingSystem
Library             OperatingSystem
Library             RPA.PDF
Library             RPA.JSON
Library             RPA.Archive
Library             RPA.RobotLogListener
Library             Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Download .csv file
    Open the robot order website
    Fill the form using data from the .csv file
    Zip PDF files


*** Keywords ***
Download .csv file
    ${url}    Get Value From User
    ...    Please provide url for .csv file.
    ...    default_value=https://robotsparebinindustries.com/orders.csv
    Download    ${url}    overwrite=True

Open the robot order website
    ${secret}    Get Secret    robot order website
    Open Available Browser    ${secret}[url]    maximized=True

Fill, submit form for one order and take screenshot
    [Arguments]    ${order}
    Wait Until Page Contains Element    css:div.modal-content
    Click Button    OK
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath=//input[@type="number"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    Preview
    Wait Until Keyword Succeeds    2 min    500 ms    Make order
    ${screenshot}    RPA.Browser.Selenium.Screenshot
    ...    robot-preview-image
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png

Make order
    Click Button    Order
    Page Should Contain Element    id:receipt

Get PDF receipt
    [Arguments]    ${order}
    ${pdf}    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${pdf}    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf
    ${files}    Create List
    ...    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png
    Add Files To Pdf    ${files}
    ...    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf

Order another robot
    Click Button    order-another

Fill the form using data from the .csv file
    Get File    orders.csv
    ${orders}    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Fill, submit form for one order and take screenshot    ${order}
        Get PDF receipt    ${order}
        Order another robot
    END
    Close Browser

Zip PDF files
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts/    Receipts.zip
