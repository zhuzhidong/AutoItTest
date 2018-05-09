*** Setting ***
Documentation   Tests the AutoItLibrary by using various AutoIt keywords on the GUI of the Windows Calculator application.
Suite Setup     Start Calculator
Suite Teardown  Stop Calculator
Test Setup      Clear Calculator
Library         AutoItLibrary   ${OUTPUTDIR}    10      ${True}
Library         Collections
Library         String
Variables       CalculatorGUIMap.py

*** Test Cases ***
Integer Addition
    [Documentation]     Get "The Answer" by addition.
    Click Buttons       4 1 + 1 =
    Win Wait            计算器     42
    ${Ans} =            Get Answer
    Should Be Equal As Numbers  ${Ans}  42

Integer Subtraction
    [Documentation]     Get "The Answer" by substraction.
    Click Buttons       4 5 - 3 =
    Win Wait            计算器     42
    ${Ans} =            Get Answer
    Should Be Equal As Numbers  ${Ans}  42

Integer Multiplication
    [Documentation]     Get "The Answer" by multiplication.
    Click Buttons       6 * 7 =
    Win Wait            计算器     42
    ${Ans} =            Get Answer
    Should Be Equal As Numbers  ${Ans}  42

Integer Division
    [Documentation]     Get "The Answer" by division.
    Click Buttons       5 4 6 / 1 3 =
    Win Wait            计算器     42
    ${Ans} =            Get Answer
    Should Be Equal As Numbers  ${Ans}  42

Hex Addition
    [Documentation]     Test Hex addition.
    [Setup]             Set Hex Mode
    Send                DE01F100
    Send                {+}
    Comment             AutoIt Send Function: {!} {#} {SPACE} {ENTER} and so on
    Comment             Not include - * / =
    Send                ABCDEF
    Send                =
    Win Wait            计算器     DEADBEEF
    ${Ans} =            Get Answer
    Should Be Equal As Strings  ${Ans}  DEADBEEF

Hex Subtraction
    [Documentation]     Test Hex subtraction.
    [Setup]             Set Hex Mode
    Clip Put            DF598CDE
    Select Calculator Menu Item     Edit Paste
    Win Wait            计算器     DF598CDE
    Send                -
    Clip Put            ABCDEF
    Select Calculator Menu Item     Edit Paste
    Win Wait            计算器     ABCDEF
    Send                =
    Win Wait            计算器     DEADBEEF
    ${Ans} =            Get Answer
    Should Be Equal As Strings  ${Ans}  DEADBEEF

Test Screen Capture On FAIL
    [Documentation]     Test that a screenshot is taken and included in the report file when an AutoItLibrary keyword fails.\n
    ...                 This test will always fail.
    [TAgs]              ExpectedFAIL
    [Setup]             Set Hex Mode
    Send                DE01F100
    Send                {+}
    Send                ABCDEF
    Send                =
    Win Wait            计算器     DEADBEAT    3

*** keywords ***
Clear Calculator
    [Documentation]     Click the Clear button in the Windows Calculator
    Win Active          计算器
    Click Button        Clear

Start Calculator
    [Documentation]     Start the Windows Calculator application and set the default settings that the rest of the tests expect.
    Run                 calc.exe
    Wait For Active Window     计算器
    Get Calculator Version
    Select Calculator Menu Item     View Scientific
    Wait For Active Window          计算器     度
    Comment     We want "Digit Grouping" off but there's no way to examine the check beside the menu item.
    ...         So we need to try recognizing some displayed digits to see if its on or off and then change it if necessary.
    send        12345
    ${Result}   ${ErrMsg} =     Run Keyword And Ignore Error    Win Wait
    ...         计算器     12345   3
    Run Keyword If  "${Result}" == "FAIL"   Select Calculator Menu Item     View Digit Grouping
    Win Wait        计算器     12345
    Click Button    Clear

Stop Calculator
    [Documentation]     Shut down the Windows Calculator application
    Win Active                      计算器
    Select Calculator Menu Item     Exit

Click Button
    [Arguments]         ${ButtonText}
    [Documentation]     Click a button by its text name, using the Calculator GUI Map.
    ${ButtonName} =     Get From Dictionary     ${GUIMAP}   ${ButtonText}
    Comment             Library Collections
    Control Click       计算器    ${EMPTY}    ${ButtonName}

Click Buttons
    [Arguments]         ${ButtonNames}
    [Documentation]     Click a sequence of buttons by their text names, using the Calculator GUI Map.\n Button text names should be separated by white space.
    @{Buttons} =        Split String        ${ButtonNames}
    Comment             Library String
    :FOR    ${ButtonName}   IN      @{Buttons}
    \       Click Button    ${ButtonName}

Select Calculator Menu Item
    [Arguments]     ${MenuItem}
    [Documentation]     The Windows Calculator application doesn't really use a Windows GUI Menu to implement its menus.
    ...                 Therefore AutoIt can't see the menus as menu GUI objects. The only way to access the Calculator menus is via the ALT key sequences.
    ...                 In Win XP the Calculator menu ALT key letters are underlined, and thus available, all the time.
    ...                 Microsoft, in their wisdom, changed this in Win Vista so that you have to press the ALT key and "wait a bit" before the ALT key letters are underlined on the GUI.
    ...                 When they're not underlined, they don't work. Since AutoIt can send ALT key sequences VERY FAST,
    ...                 a sequence such as !VS (ALT+V+S) doesn't work on Win Vista, while it does work on Win XP.
    ...                 To get around this problem, and to make menu item selection more "tester friendly" we provide this keyword.
    ...                 It takes the name of a menu item as defined in the MENUMAP dictionary in the CalculatorGUIMap.py file.
    ...                 The MENUMAP dictionary items translate the application oriented menu name into the sequence of ALT keys to access that menu item.
    ...                 To make this work on Win XP and Win Vista, this keyword sends the ALT key first, waits a bit, then sends the sequence of keys from the MENUMAP.
    ...                 Complicated, but welcome to the wierd world of Windows GUI testing!
    ${AltKeys} =    Get From Dictionary     ${MENUMAP}      ${MenuItem}
    Comment         Library Collections
    Send            {ALTDOWN}
    Sleep           1
    Send            ${AltKeys}
    Send            {ALTUP}

Get Calculator Version
    [Documentation]     Get the version of the Windows Calculator. Version 5.1 is WinXP, Version 6.1 is Win7.\n Set the suite variables to match the found version.
    Send                {ALTDOWN}
    Sleep               1
    Send                ha
    Send                {ALTUP}
    Win Wait Active     关于“计算器”    版本
    ${WinText} =        Control Get Text    关于“计算器”    版本
    ...                 Static3
    ${WinText2} =       Run Keyword If      "版本" not in "${WinText}"   Control Get Text
    ...                 关于“计算器”         版本     Static4
    ${WinText} =        Set Variable If    "版本" in "${WinText2}"      ${WinText2}
    ...                 ${WinText}
    Run Keyword If      "版本" not in "${Wintext}"   Fail    Cannot find Calculator version
    ${GUIMAP} =         Set Variable If     "5.1" in "${WinText}"   ${GUIMAP_51}
    ${GUIMAP} =         Set Variable If     "6.0" in "${WinText}"   ${GUIMAP_60}
    ...                 ${GUIMAP}
    ${GUIMAP} =         Set Variable If     "6.1" in "${WinText}"   ${GUIMAP_61}
    ...                 ${GUIMAP}
    Run Keyword If      ${GUIMAP} == None   Fail    Calculator version not supported: ${WinText}
    Set Suite Variable  ${GUIMAP}
    ${MENUMAP} =        Set Variable If     "5.1" in "${WinText}"   ${MENUMAP_51}
    ${MENUMAP} =        Set Variable If     "6.0" in "${WinText}"   ${MENUMAP_60}
    ...                 ${MENUMAP}
    ${MENUMAP} =        Set Variable If     "6.1" in "${WinText}"   ${MENUMAP_61}
    ...                 ${MENUMAP}
    Set Suite Variable  ${MENUMAP}
    Control Click       关于“计算器”    版本   Button1

Set Hex Mode
    [Documentation]     Put the calculator in Hex arithmetic Dword mode
    Select Calculator Menu Item     View Hex
    Click Buttons   Hex Dword
    Sleep   1 sec

Get Answer
    [Documentation]     Get the answer via the clipboard, since the control is not accessible in the 6.1 version (it used to be "Edit1" in the 5.1 version).
    Select Calculator Menu Item     Edit Copy
    ${Answer} =     Clip Get
    [Return]    ${Answer}

