*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.    Saves the order HTML receipt as a PDF file. Saves the screenshot of the ordered robot. Embeds the screenshot of the robot to the PDF receipt. Created ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop.OperatingSystem
Library             OperatingSystem
Library             RPA.PDF
Library             RPA.JSON
Library             RPA.Windows
Library             RPA.Archive
Library             RPA.RobotLogListener


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the robot order website
    Download .csv file
    Fill the form using data from the .csv file
    Zip PDF files
     

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True

Download .csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill and submit form for one order
    [Arguments]    ${order}
    Wait Until Page Contains Element    css:div.modal-content
    Click Button    OK
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath=//input[@type="number"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    Preview
    Click Button    order
    Set Wait Time    4
    ${button_order_visible}    Is Element Visible    order
    IF ${button_order_visible} == True    Click button    order
    Wait Until Element Is Visible    robot-preview-image
    ${screenshot}    RPA.Browser.Selenium.Screenshot
    ...    robot-preview-image
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png
    #Wait Until Element Is Visible    id:receipt
    ${pdf}    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${pdf}    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf
    ${files}    Create List
    ...    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png
    Add Files To Pdf    ${files}
    ...    ${OUTPUT_DIR}${/}receipts/${order}[Order number].pdf
    Click Button    order-another

Fill the form using data from the .csv file
    Get File    orders.csv
    ${orders}    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Fill and submit form for one order    ${order}
    END
    Close Browser

Zip PDF files
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts/    Receipts.zip
