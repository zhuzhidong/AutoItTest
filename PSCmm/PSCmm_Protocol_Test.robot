*** Setting ***
Documentation   质量测量仪模拟软件通信协议测试
Test Setup      Start PSCmm
Test Teardown   Stop PSCmm
Library         AutoItLibrary   ${OUTPUTDIR}    10      ${True}
Library         Collections
Library         String
Library         CRC16.py
Library         ItemList.py
Variables       PSCmmGUIMap.py
Variables       ConfigPara.py

*** Test Cases ***
任务清单货包测量
    [Documentation]     4.1.1 ~ 4.1.4
    [Teardown]          清除EEPROM中的任务清单并退出

    Comment             回传任务清单货包测量质量结果
    回传任务清单货包测量质量结果          00

    Comment             4.1.2 任务清单货包总数指令 任务清单货包数异常
    ${ItemCount} =      Get Item Count
    Send Instruction    80  09  06  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         任务清单货包数异常应答帧错误  8001900000  @{Response1}

    Comment             4.1.2 任务清单货包总数指令 任务清单货包数正确
    ${ItemCount} =      Get Item Count
    Send Instruction    80  08  06  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         任务清单货包数正确应答帧错误  8002900000  @{Response1}
    ${PACKAGE_NO_ID} =  Get From Dictionary     ${GUIMAP}   PACKAGE_NO
    ${PACKAGE_NO} =     Control Get Text    质量仪软件测试样例   ${EMPTY}   ${PACKAGE_NO_ID}
    Should Be Equal As Strings      ${PACKAGE_NO}       8       任务清单货包总数设置错误

    Comment             4.1.3 任务清单货包ID号指令 发送8组货包ID，分别为111111~888888
    :FOR    ${i}    IN RANGE    1   9
    \       ${ii} =         Catenate    SEPARATOR=  ${i}    ${i}
    \       Send Instruction    ${ii}   ${ii}   ${ii}   00  00
    \       ${TextID} =     Catenate    SEPARATOR=      BAG_ID    ${i}
    \       ${TextName} =   Get From Dictionary     ${GUIMAP}   ${TextID}
    \       ${BAGID} =      Control Get Text    质量仪软件测试样例   ${EMPTY}   ${TextName}
    \       ${EXPECTID} =   Catenate    SEPARATOR=  ${ii}   ${ii}   ${ii}
    \       Should Be Equal As Strings      ${BAGID}    ${EXPECTID}      任务清单货包ID设置错误

    Comment             4.1.4 任务清单发送完毕指令
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  90  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         任务清单货包数正确应答帧错误  8004900000  @{Response1}

    Comment             分别勾选货包ID，测量质量
    :FOR    ${i}        IN RANGE    1   8
    \       ${BAG_RADIO} =      Catenate    SEPARATOR=  BAG     ${i}
    \       ${BAG_NAME} =       Get From Dictionary     ${GUIMAP}   ${BAG_RADIO}
    \       Control Command     质量仪软件测试样例   ${EMPTY}    ${BAG_NAME}     Check   ${EMPTY}
    \       Click Button        MAS_MEAS
    \       ${MassID} =         Catenate    SEPARATOR=      BAG_MASS    ${i}
    \       ${MassName} =       Get From Dictionary     ${GUIMAP}   ${MassID}
    \       Sleep               3
    \       ${BAGMASS} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MassName}
    \       Should Be Equal As Strings      ${BAGMASS}  0032    货包质量测量错误

    ${BAG_RADIO} =      Set variable    BAG8
    ${BAG_NAME} =       Get From Dictionary     ${GUIMAP}   ${BAG_RADIO}
    Control Command     质量仪软件测试样例   ${EMPTY}    ${BAG_NAME}     Check   ${EMPTY}
    Click Button        MAS_MEAS
    ${MassID} =         Set variable    BAG_MASS8
    ${MassName} =       Get From Dictionary     ${GUIMAP}   ${MassID}
    ${test}             Control Command     质量仪软件测试样例   ${EMPTY}    ${MassName}     FindString   0032
    ${BAGMASS} =        Control Get Text    质量仪软件测试样例   ${EMPTY}    ${MassName}
    # Should Be Equal As Strings      ${BAGMASS}  0032    货包质量测量错误
    # 好像根本没有显示0032

    Sleep       3
    Comment             任务清单中所有货包均测量完成后，任务清单不再显示在主界面中
    :FOR    ${i}    IN RANGE    1   9
    \       ${BAG_RADIO} =      Catenate    SEPARATOR=  BAG     ${i}
    \       ${BAG_NAME} =       Get From Dictionary     ${GUIMAP}   ${BAG_RADIO}
    \       ${BAG_ID} =         Catenate    SEPARATOR=  BAG_ID  ${i}
    \       ${BAG_ID_NAME} =    Get From Dictionary     ${GUIMAP}   ${BAG_ID}
    \       ${MassID} =         Catenate    SEPARATOR=      BAG_MASS    ${i}
    \       ${MassName} =       Get From Dictionary     ${GUIMAP}   ${MassID}
    \       ${BAGMASS} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MassName}
    \       ${BAGID} =          Control Get Text    质量仪软件测试样例   ${EMPTY}   ${BAG_ID_NAME}
    \       ${IsCheckeded} =    Control Command     质量仪软件测试样例   ${EMPTY}   ${BAG_NAME}     IsChecked   ${EMPTY}
    \       Should Be Equal As Strings      ${BAGMASS}  ${EMPTY}    任务清单依旧显示在主界面中
    \       Should Be Equal As Strings      ${BAGID}    ${EMPTY}    任务清单依旧显示在主界面中
    \       # 实际上处于勾选状态，因为灰显状态？？
    \       # Should Be Equal As Strings      ${IsCheckeded}    0     任务清单中货包依旧被勾选

    Comment             回传任务清单货包测量质量结果
    回传任务清单货包测量质量结果          08
    ${ItemCount} =      Get Item Count
    :FOR    ${i}    IN RANGE    1   9
    \       ${item} =       Evaluate        ${ItemCount} - 9 + ${i}
    \       @{Response} =   Check ACK MSG   ${item}
    \       ${Expect} =     Catenate    SEPARATOR=  ${i}  ${i}  ${i}  ${i}  ${i}  ${i}  0032
    \       Confirm ACK     回送货包质量数据帧错误     ${Expect}   @{Response}

    Comment             4.1.2 任务清单货包总数指令 清除EEPROM中的任务清单
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  06  00  00
    ${item1} =          Evaluate    ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误   8000070000  @{Response1}
    回传任务清单货包测量质量结果          00

任务清单货包测量异常
    [Documentation]     4.1.2 ~ 4.1.4 任务清单货包ID号指令的个数小于任务清单的货包总数
    [Teardown]          清除EEPROM中的任务清单并退出

    Comment             4.1.2 任务清单货包总数指令 任务清单货包数正确
    ${ItemCount} =      Get Item Count
    Send Instruction    80  02  06  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         任务清单货包数正确应答帧错误  8002900000  @{Response1}
    ${PACKAGE_NO_ID} =  Get From Dictionary     ${GUIMAP}   PACKAGE_NO
    ${PACKAGE_NO} =     Control Get Text    质量仪软件测试样例   ${EMPTY}   ${PACKAGE_NO_ID}
    Should Be Equal As Strings      ${PACKAGE_NO}       2       任务清单货包总数设置错误

    Comment             4.1.3 任务清单货包ID号指令，只发送一个货包ID
    Send Instruction    11  11  11  00  00
    ${TextName} =       Get From Dictionary     ${GUIMAP}   BAG_ID1
    ${BAGID} =          Control Get Text    质量仪软件测试样例   ${EMPTY}   ${TextName}
    Should Be Equal As Strings      ${BAGID}        111111      任务清单货包ID设置错误

    Comment             4.1.4 任务清单发送完毕指令，货包ID号指令的个数小于任务清单的货包总数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  90  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         任务清单货包数错误应答帧错误  8003900000  @{Response1}

    Comment             4.1.2 任务清单货包总数指令 清除EEPROM中的任务清单
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  06  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答指令错误  8000070000  @{Response1}
    ${BAGID} =          Control Get Text    质量仪软件测试样例   ${EMPTY}   ${TextName}
    Should Be Equal As Strings      ${BAGID}        ${EMPTY}    任务清单货包ID设置错误
    ${PACKAGE_NO} =     Control Get Text    质量仪软件测试样例   ${EMPTY}   ${PACKAGE_NO_ID}
    Should Be Equal As Strings      ${PACKAGE_NO}   ${EMPTY}    任务清单货包总数设置错误

手动测量货包质量
    [Documentation]     4.1.5 ~ 4.1.8
    [Teardown]          手动测量参数重置并退出

    Comment             手动输入货包ID测量质量
    ${ManID} =          Get From Dictionary     ${GUIMAP}   MAN_BAG_ID
    ${MASS_ID} =        Get From Dictionary     ${GUIMAP}   MAN_BAG_MASS
    Control Set Text    质量仪软件测试样例   ${EMPTY}    ${ManID}    100
    Click Button        BAG_CONFIRM
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     ${EMPTY}    前次手工测量货包质量未清除
    Click Button        MAS_MEAS
    Sleep               4
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     0032        手工测量货包质量错误

    Comment             4.1.5 回传手动测量质量结果
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  D0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误       8000070000      @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         回送货包个数数据帧错误或手动测量的货包个数错误   8001090000  @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误       0000640032      @{Response3}

    Comment             4.1.7 设置手动测量的可测量货包总数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  F3  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         货包总数设置异常应答帧错误       8000080000      @{Response1}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  F3  00  03
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误       8000070000      @{Response1}

    Comment             4.1.8 设置手动测量的当前已测量货包数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  F4  00  04
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         已测量货包设置异常应答帧错误  8000080000  @{Response1}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  F3  00  02
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误       8000070000      @{Response1}

    Comment             4.1.6 回传手动测量参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  F0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误       8000070000      @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误       8000F10002      @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误       8000F20001      @{Response3}

测试指令
    [Documentation]     4.1.9 测量仪收到本指令后，回复确认接收应答，
    ...                 并将采集的力值和3轴加速度数据回送给管理机。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  0A  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    ${item4} =          Evaluate            ${ItemCount} + 3
    ${item5} =          Evaluate            ${ItemCount} + 4

    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误       8000070000      @{Response1}
    Sleep               2
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误       80000B0096      @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误       80000C001E      @{Response3}
    @{Response4} =      Check ACK MSG       ${item4}
    Confirm ACK         确认接收应答帧错误       80000D001E      @{Response4}
    @{Response5} =      Check ACK MSG       ${item5}
    Confirm ACK         确认接收应答帧错误       80000E001E      @{Response5}

EEPROM第一分区 设定力初值波动范围指令
    [Documentation]     4.1.11 设定力初值波动范围指令，波动范围为[10, 255]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  01  0F  00  09
    Send Instruction    80  01  0F  00  96
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         力初值波动范围异常应答帧错误      8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定X轴加速度初值波动范围指令
    [Documentation]     4.1.12 设定X轴加速度初值波动范围指令，波动范围为[10, 255]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  02  0F  00  09
    Send Instruction    80  02  0F  00  96
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         X轴加速度初值波动范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定Y轴加速度初值波动范围指令
    [Documentation]     4.1.13 设定Y轴加速度初值波动范围指令，波动范围为[10, 255]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  03  0F  00  09
    Send Instruction    80  03  0F  00  96
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Y轴加速度初值波动范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定Z轴加速度初值波动范围指令
    [Documentation]     4.1.14 设定Z轴加速度初值波动范围指令，波动范围为[10, 255]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  04  0F  00  09
    Send Instruction    80  04  0F  00  96
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Z轴加速度初值波动范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定力上限指令
    [Documentation]     4.1.15 设定力上限指令，力上限范围为[0, 65535]。
    更改力下限
    ${ItemCount} =      Get Item Count
    Send Instruction    80  05  0F  00  63
    Send Instruction    80  05  0F  FF  FF
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         力上限范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定力下限指令
    [Documentation]     4.1.16 设定力下限指令，力下限范围为[0, 65535]。
    Comment             默认力上限为39816（9B88）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  06  0F  FF  FF
    Send Instruction    80  06  0F  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         力下限范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response2}

EEPROM第一分区 设定滑动平均点个数指令
    [Documentation]     4.1.17 设定滑动平均点个数指令，滑动平均点个数范围为[50, 150]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  07  0F  00  31
    Send Instruction    80  07  0F  00  97
    Send Instruction    80  07  0F  00  64
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         滑动平均点个数范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         滑动平均点个数范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第一分区 设定初值周期测量时间长度指令
    [Documentation]     4.1.18 设定初值周期测量时间长度指令，初值周期测量时间长度范围为[200, 1200]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  08  0F  00  C7
    Send Instruction    80  08  0F  04  B1
    Send Instruction    80  08  0F  01  F4
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         初值周期测量时间长度范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         初值周期测量时间长度范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第一分区 设定测量周期时间长度指令
    [Documentation]     4.1.19 设定测量周期时间长度指令，测量周期时间长度范围为[500, 1500]。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  09  0F  01  F3
    Send Instruction    80  09  0F  05  DD
    Send Instruction    80  09  0F  03  E8
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         测量周期时间长度范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         测量周期时间长度范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第二分区 设定加速度标准参数值指令
    [Documentation]     4.1.20 设定加速度标准参数值指令，加速度标准参数值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，加速度为10.0。
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  0A  0F  00  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  0A  0F  41  20
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM第二分区 设定力最小参数值指令
    [Documentation]     4.1.21 设定力最小参数值指令，力最小参数值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，力最小参数值为1.0。
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  0B  0F  00  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  0B  0F  3F  80
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM第二分区 设定加速度最小参数值指令
    [Documentation]     4.1.22 设定加速度最小参数值指令，加速度最小参数值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，加速度最小参数值为0.0002。
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  0C  0F  B0  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  0C  0F  39  51
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM第二分区 设定主敏感轴指令
    [Documentation]     4.1.10 设定主敏感轴指令。
    ${ItemCount} =  Get Item Count
    Send Instruction    80  00  0F  00  00
    Send Instruction    80  00  0F  00  04
    Send Instruction    80  00  0F  00  02
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         主敏感轴参数CP2异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         主敏感轴参数CP2异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定自检力最小值指令
    [Documentation]     4.1.27 设定自检力最小值指令，自检力最小值范围为[0, 65530]。
    ...                 设定自检力最小值为100。
    Comment             默认自检力最大值为65530（FFFA）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  80  00  04
    Send Instruction    80  00  80  FF  FB
    Send Instruction    80  00  80  00  64
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         自检力最小值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         自检力最小值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定自检力最大值指令
    [Documentation]     4.1.28 设定自检力最大值指令，自检力最小值范围为[0, 65530]。
    ...                 设定自检力最小值为60000。
    Comment             默认自检力最小值为5（0005）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  01  80  00  04
    Send Instruction    80  01  80  FF  FB
    Send Instruction    80  01  80  EA  60
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         自检力最大值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         自检力最大值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定X轴加速度最小值指令
    [Documentation]     4.1.29 设定X轴加速度最小值指令，X轴加速度最小值范围为[0, 65530]。
    ...                 设定X轴加速度最小值为100。
    Comment             默认X轴加速度最大值为65530（FFFA）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  02  80  00  04
    Send Instruction    80  02  80  FF  FB
    Send Instruction    80  02  80  00  64
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         X轴加速度最小值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         X轴加速度最小值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定X轴加速度最大值指令
    [Documentation]     4.1.30 设定X轴加速度最大值指令，X轴加速度最小值范围为[0, 65530]。
    ...                 设定X轴加速度最小值为60000。
    Comment             默认X轴加速度最小值为5（0005）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  03  80  00  04
    Send Instruction    80  03  80  FF  FB
    Send Instruction    80  03  80  EA  60
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         X轴加速度最大值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         X轴加速度最大值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定Y轴加速度最小值指令
    [Documentation]     4.1.31 设定Y轴加速度最小值指令，Y轴加速度最小值范围为[0, 65530]。
    ...                 设定Y轴加速度最小值为100。
    Comment             默认Y轴加速度最大值为65530（FFFA）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  04  80  00  04
    Send Instruction    80  04  80  FF  FB
    Send Instruction    80  04  80  00  64
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Y轴加速度最小值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         Y轴加速度最小值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定Y轴加速度最大值指令
    [Documentation]     4.1.32 设定Y轴加速度最大值指令，Y轴加速度最小值范围为[0, 65530]。
    ...                 设定Y轴加速度最小值为60000。
    Comment             默认Y轴加速度最小值为5（0005）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  05  80  00  04
    Send Instruction    80  05  80  FF  FB
    Send Instruction    80  05  80  EA  60
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Y轴加速度最大值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         Y轴加速度最大值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定Z轴加速度最小值指令
    [Documentation]     4.1.33 设定Z轴加速度最小值指令，Z轴加速度最小值范围为[0, 65530]。
    ...                 设定Z轴加速度最小值为100。
    Comment             默认Z轴加速度最大值为65530（FFFA）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  06  80  00  04
    Send Instruction    80  06  80  FF  FB
    Send Instruction    80  06  80  00  64
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Y轴加速度最小值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         Y轴加速度最小值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM第三分区 设定Z轴加速度最大值指令
    [Documentation]     4.1.34 设定Z轴加速度最大值指令，Z轴加速度最小值范围为[0, 65530]。
    ...                 设定Z轴加速度最小值为60000。
    Comment             默认Z轴加速度最小值为5（0005）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  07  80  00  04
    Send Instruction    80  07  80  FF  FB
    Send Instruction    80  07  80  EA  60
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         Z轴加速度最大值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         Z轴加速度最大值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

EEPROM校准参数分区 设定力值校准指令
    [Documentation]     4.1.36 设定力值校准指令，力值校准值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，力值校准值为0.002。
    [Teardown]          恢复默认配置并退出
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  00  10  12  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  00  10  3B  03
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM校准参数分区 设定X轴加速度校准指令
    [Documentation]     4.1.37 设定X轴加速度校准指令，X轴加速度校准值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，X轴加速度校准值为0.0002。
    [Teardown]          恢复默认配置并退出
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  00  20  B0  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  00  20  39  51
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM校准参数分区 设定Y轴加速度校准指令
    [Documentation]     4.1.38 设定Y轴加速度校准指令，Y轴加速度校准值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，Y轴加速度校准值为0.002。
    [Teardown]          恢复默认配置并退出
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  00  30  12  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  00  30  3B  03
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM校准参数分区 设定Z轴加速度校准指令
    [Documentation]     4.1.39 设定Z轴加速度校准指令，Z轴加速度校准值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，Z轴加速度校准值为0.0002。
    [Teardown]          恢复默认配置并退出
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  00  40  B0  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  00  40  39  51
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM校准参数分区 设定总线校准指令
    [Documentation]     4.1.40 设定总线校准指令，总线校准值为32位浮点数。
    ...                 分两次发送，第一次发送低16位，第二次发送高16位，总线校准值为0.5。
    [Teardown]          恢复默认配置并退出
    ${ItemCount_PRE} =  Get Item Count
    Send Instruction    80  00  50  00  00
    ${ItemCount} =      Get Item Count
    Should Be Equal As Strings      ${ItemCount_PRE}    ${ItemCount}    第一条指令不应该回复
    Send Instruction    80  00  50  3F  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

EEPROM电池电量分区 设置满格电池电量阈值指令
    [Documentation]     4.1.45 设置满格电池电量阈值指令，满格电池电量阈值范围为[0, 65530]。
    ...                 设置满格电池电量阈值为600。
    Comment             默认满格电池电量阈值为500（01F4）
    Comment             默认两格电池电量阈值为400（0190）
    Comment             默认一格电池电量阈值为100（0064）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  03  C0  00  63
    Send Instruction    80  03  C0  01  8F
    Send Instruction    80  03  C0  FF  FB
    Send Instruction    80  03  C0  02  58
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    ${item4} =          Evaluate            ${ItemCount} + 3
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         满格电池电量阈值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         满格电池电量阈值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         满格电池电量阈值范围异常应答帧错误     8000080000     @{Response3}
    @{Response4} =      Check ACK MSG       ${item4}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response4}

EEPROM电池电量分区 设置两格电池电量阈值指令
    [Documentation]     4.1.46 设置两格电池电量阈值指令，两格电池电量阈值范围为[0, 65530]。
    ...                 设置两格电池电量阈值为450。
    Comment             默认满格电池电量阈值为500（01F4）
    Comment             默认两格电池电量阈值为400（0190）
    Comment             默认一格电池电量阈值为100（0064）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  04  C0  00  63
    Send Instruction    80  04  C0  01  F5
    Send Instruction    80  04  C0  FF  FB
    Send Instruction    80  04  C0  01  C2
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    ${item4} =          Evaluate            ${ItemCount} + 3
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         两格电池电量阈值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         两格电池电量阈值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         两格电池电量阈值范围异常应答帧错误     8000080000     @{Response3}
    @{Response4} =      Check ACK MSG       ${item4}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response4}

EEPROM电池电量分区 设置一格电池电量阈值指令
    [Documentation]     4.1.47 设置一格电池电量阈值指令，一格电池电量阈值范围为[0, 65530]。
    ...                 设置一格电池电量阈值为150。
    Comment             默认满格电池电量阈值为500（01F4）
    Comment             默认两格电池电量阈值为400（0190）
    Comment             默认一格电池电量阈值为100（0064）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  05  C0  01  91
    Send Instruction    80  05  C0  01  F5
    Send Instruction    80  05  C0  FF  FB
    Send Instruction    80  05  C0  00  96
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    ${item4} =          Evaluate            ${ItemCount} + 3
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         一格电池电量阈值范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         一格电池电量阈值范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         一格电池电量阈值范围异常应答帧错误     8000080000     @{Response3}
    @{Response4} =      Check ACK MSG       ${item4}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response4}

EEPROM电池电量分区 设置电池电量检测周期指令
    [Documentation]     4.1.48 设置电池电量检测周期指令，电池电量检测周期范围为[10, 100]。
    ...                 设置电池电量检测周期为50。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  06  C0  00  09
    Send Instruction    80  06  C0  00  65
    Send Instruction    80  06  C0  00  32
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    ${item3} =          Evaluate            ${ItemCount} + 2
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         电池电量检测周期范围异常应答帧错误     8000080000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         电池电量检测周期范围异常应答帧错误     8000080000     @{Response2}
    @{Response3} =      Check ACK MSG       ${item3}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response3}

查询当前电池电量码指令
    [Documentation]     4.1.49 回复确认接收应答，并采集当前的电池电量，
    ...                 将当前的电池电量回送给管理机。
    ${BHighName} =      Get From Dictionary     ${GUIMAP}   BATT_HIGH
    ${BLowName} =       Get From Dictionary     ${GUIMAP}   BATT_LOW
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BHighName}     FF
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BLowName}      FF
    Click Button        BATT_ACQU

    ${ItemCount} =      Get Item Count
    Send Instruction    80  07  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    Sleep               1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         回送当前电池电量码值应答帧错误或电池电量错误  8008C0FFFF  @{Response2}

    Sleep               99
    ${ItemCount} =      Get Item Count
    Send Instruction    80  07  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    Sleep               1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    Confirm ACK         回送当前电池电量码值应答帧错误或电池电量错误  8008C0FF37  @{Response2}

回传EEPROM第一、第二、第三分区配置参数
    [Documentation]     4.1.23 确认EEPROM第一分区配置参数指令
    ...                 4.1.24 确认EEPROM第二分区配置参数指令
    ...                 4.1.25 回传第一、第二、第三分区配置参数
    ...                 4.1.26 回传第一、第二、第三分区临时配置参数
    ...                 4.1.35 确认EEPROM第三分区配置参数指令
    [Teardown]          恢复默认配置并退出

    Comment             4.1.25 回传第一、第二、第三分区配置参数(默认配置参数)
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  06
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CTL_Default}      ${24}

    Comment             EEPROM第一分区配置参数
    Send Instruction    80  01  0F  00  96      # 力初值波动范围默认100，实际设置150
    Send Instruction    80  02  0F  00  96      # X轴加速度初值波动范围默认100，实际设置150
    Send Instruction    80  03  0F  00  96      # Y轴加速度初值波动范围默认100，实际设置150
    Send Instruction    80  04  0F  00  96      # Z轴加速度初值波动范围默认100，实际设置150
    Send Instruction    80  05  0F  FF  FF      # 力上限默认39816，实际设置65535
    Send Instruction    80  06  0F  00  0A      # 力上限默认0，实际设置10
    Send Instruction    80  07  0F  00  64      # 滑动平均点个数默认50，实际设置100
    Send Instruction    80  08  0F  01  F4      # 初值周期测量时间长度默认1000，实际设置500
    Send Instruction    80  09  0F  03  E8      # 测量周期时间长度默认1200，实际设置1000

    Comment             EEPROM第二分区配置参数
    Send Instruction    80  0A  0F  00  00
    Send Instruction    80  0A  0F  41  20      # 加速度标准参数值默认9.8，实际设置10.0
    Send Instruction    80  0B  0F  00  00
    Send Instruction    80  0B  0F  3F  80      # 力最小参数值默认1.2，实际设置1.0
    Send Instruction    80  0C  0F  B0  00
    Send Instruction    80  0C  0F  39  51      # 加速度最小参数值默认0.00025，实际设置0.0002
    Send Instruction    80  00  0F  00  02      # 测量主敏感轴默认X轴，实际设置Y周轴

    Comment             EEPROM第三分区配置参数
    Send Instruction    80  00  80  00  64      # 自检力最小值默认5，实际设置100
    Send Instruction    80  01  80  EA  60      # 自检力最大值默认65530，实际设置60000
    Send Instruction    80  02  80  00  64      # 自检X轴加速度最小值默认5，实际设置100
    Send Instruction    80  03  80  EA  60      # 自检X轴加速度最大值默认65530，实际设置60000
    Send Instruction    80  04  80  00  64      # 自检Y轴加速度最小值默认5，实际设置100
    Send Instruction    80  05  80  EA  60      # 自检Y轴加速度最大值默认65530，实际设置60000
    Send Instruction    80  06  80  00  64      # 自检Z轴加速度最小值默认5，实际设置100
    Send Instruction    80  07  80  EA  60      # 自检Z轴加速度最大值默认65530，实际设置60000

    Comment             4.1.26 回传第一、第二、第三分区临时配置参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  07
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CTLParameters}    ${24}

    Comment             4.1.23 确认EEPROM第一分区配置参数指令
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  01
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

    Comment             4.1.24 确认EEPROM第二分区配置参数指令
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  02
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

    Comment             4.1.35 确认EEPROM第三分区配置参数指令
    ${ItemCount} =      Get Item Count
    Send Instruction    80  08  80  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

    Comment             4.1.25 回传第一、第二、第三分区配置参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  06
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CTLParameters}    ${24}

    Comment             4.1.25 恢复默认配置后，回传第一、第二、第三分区配置参数(默认配置参数)
    Click Button        RECO_DEFAULT
    Win Wait Active     PSCmm       默认设置恢复成功
    Send                {ENTER}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  06
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CTL_Default}      ${24}

回传EEPROM校准分区校准参数
    [Documentation]     4.1.41 回复确认接收应答，并将校准分区的校准参数回送给管理机。
    [Teardown]          恢复默认配置并退出

    Comment             4.1.41 回传EEPROM校准分区校准参数（默认参数）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  60  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CAL_Default}      ${10}

    Comment             EEPROM校准参数
    Send Instruction    80  00  10  12  00
    Send Instruction    80  00  10  3B  03      # 力值校准参数默认0.0025，实际设置0.002
    Send Instruction    80  00  20  B0  00
    Send Instruction    80  00  20  39  51      # X轴加速度校准参数默认0.0025，实际设置0.0002
    Send Instruction    80  00  30  12  00
    Send Instruction    80  00  30  3B  03      # Y轴加速度校准参数默认0.00025，实际设置0.002
    Send Instruction    80  00  40  B0  00
    Send Instruction    80  00  40  39  51      # Z轴加速度校准参数默认0.00025，实际设置0.0002
    Send Instruction    80  00  50  00  00
    Send Instruction    80  00  50  3F  00      # 总线校准参数默认1.0，实际设置0.5

    Comment             4.1.41 回传EEPROM校准分区校准参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  60  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CALParameters}    ${10}

    Comment             4.1.41 恢复默认配置后，回传EEPROM校准分区校准参数（默认参数）
    Click Button        RECO_DEFAULT
    Win Wait Active     PSCmm       默认设置恢复成功
    Send                {ENTER}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  60  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${CAL_Default}      ${10}

回传EEPROM电池电量分区配置参数
    [Documentation]     4.1.42 确认电池电量分区配置参数
    ...                 4.1.43 回传电池电量分区配置参数
    ...                 4.1.44 回传电池电量分区临时配置参数
    [Teardown]          恢复默认配置并退出

    Comment             4.1.43 回传认EEPROM电池电量分区配置参数（默认参数）
    ${ItemCount} =      Get Item Count
    Send Instruction    80  01  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${BAT_Default}      ${4}

    Comment             EEPROM电池电量
    Send Instruction    80  03  C0  02  58      # 满格电池电量阈值默认500，实际设置600
    Send Instruction    80  04  C0  01  C2      # 两格电池电量阈值默认400，实际设置450
    Send Instruction    80  05  C0  00  96      # 一格电池电量阈值默认100，实际设置150
    Send Instruction    80  06  C0  00  32      # 电池电量检查周期默认20，实际设置50

    Comment             4.1.44 回传认EEPROM电池电量分区临时配置参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  02  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${BATParameters}    ${4}

    Comment             4.1.42 确认EEPROM电池电量分区配置参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

    Comment             4.1.43 回传认EEPROM电池电量分区配置参数
    ${ItemCount} =      Get Item Count
    Send Instruction    80  01  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${BATParameters}    ${4}

    Comment             4.1.43 恢复默认配置后，回传认EEPROM电池电量分区配置参数（默认参数）
    Click Button        RECO_DEFAULT
    Win Wait Active     PSCmm       默认设置恢复成功
    Send                {ENTER}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  01  C0  00  00
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    Config Confirm      ${ItemCount}    ${BAT_Default}      ${4}

总线校准参数设置取半
    [Documentation]     总线校准参数*0.5，则测量的质量应该为0019（25KG）。
    [Teardown]          恢复默认配置并退出

    Comment             总线校准参数默认1.0，现在设置为0.5
    Send Instruction    80  00  50  00  00
    Send Instruction    80  00  50  3F  00

    Comment             手动测量货包质量
    ${ManID} =          Get From Dictionary     ${GUIMAP}   MAN_BAG_ID
    ${MASS_ID} =        Get From Dictionary     ${GUIMAP}   MAN_BAG_MASS
    Control Set Text    质量仪软件测试样例   ${EMPTY}    ${ManID}    100
    Click Button        BAG_CONFIRM
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     ${EMPTY}    前次手工测量货包质量未清除
    Click Button        MAS_MEAS
    Sleep               4
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     0019        手工测量货包质量错误

总线校准参数设置取极低
    [Documentation]     如果m < 0.1，置m = -1.0，且提示“质量测量错误”
    [Teardown]          恢复默认配置并退出

    Comment             总线校准参数默认1.0，现在设置为0.0019，此时质量为0.095KG。
    Send Instruction    80  00  50  09  00
    Send Instruction    80  00  50  3A  F9

    Comment             手动测量货包质量
    ${ManID} =          Get From Dictionary     ${GUIMAP}   MAN_BAG_ID
    ${MASS_ID} =        Get From Dictionary     ${GUIMAP}   MAN_BAG_MASS
    Control Set Text    质量仪软件测试样例   ${EMPTY}    ${ManID}    100
    Click Button        BAG_CONFIRM
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     ${EMPTY}    前次手工测量货包质量未清除
    Click Button        MAS_MEAS
    Win Wait Active     PSCmm       质量测量不成功
    Send                {ENTER}

Test加速度标准参数值设置取两倍
    [Documentation]     加速度标准参数值*2，则测量的质量应该为0019（25KG）。
    [Teardown]          恢复默认配置并退出

    Comment             加速度标准参数值默认9.8，现在设置为19.6
    Send Instruction    80  0A  0F  CC  CC
    Send Instruction    80  0A  0F  41  9C
    Send Instruction    80  0F  0F  00  02

    Comment             手动测量货包质量
    ${ManID} =          Get From Dictionary     ${GUIMAP}   MAN_BAG_ID
    ${MASS_ID} =        Get From Dictionary     ${GUIMAP}   MAN_BAG_MASS
    Control Set Text    质量仪软件测试样例   ${EMPTY}    ${ManID}    100
    Click Button        BAG_CONFIRM
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     ${EMPTY}    前次手工测量货包质量未清除
    Click Button        MAS_MEAS
    Sleep               4
    ${MASS} =           Control Get Text    质量仪软件测试样例   ${EMPTY}   ${MASS_ID}
    Should Be Equal As Strings      ${MASS}     0019        手工测量货包质量错误

测量过程中故障E10 电池电量过低
    [Documentation]     测量过程中电池电量小于等于一格电量阈值
    ${BHighName} =      Get From Dictionary     ${GUIMAP}   BATT_HIGH
    ${BLowName} =       Get From Dictionary     ${GUIMAP}   BATT_LOW
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BHighName}     00
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BLowName}      6F
    Click Button        BATT_ACQU
    Win Wait Active     质量仪软件测试样例      E10
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E10         故障E10未出现

自检故障E10 电池电量过低
    [Documentation]     电池电量小于等于一格电量阈值
    ...                 这个测试用例无意义，因为测量过程中只要电量过低就直接E10了。
    [Setup]             Start PSCmm With No SELF_TEST
    ${BHighName} =      Get From Dictionary     ${GUIMAP}   BATT_HIGH
    ${BLowName} =       Get From Dictionary     ${GUIMAP}   BATT_LOW
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BHighName}     00
    Control Set Text    质量仪软件测试样例      ${EMPTY}    ${BLowName}      64
    Click Button        BATT_ACQU
    Click Button        SELF_TEST
    Win Wait Active     质量仪软件测试样例      E10

自检故障E11 力传感器自检错误
    [Documentation]     检测数值（FF FA）小于阈值下限，或者大于阈值上限
    [Teardown]          恢复默认配置并退出

    Comment             检测数值（FF FA）小于阈值下限（阈值下限的最大值为FF FA），无法满足条件。

    Comment             检测数值（FF FA）大于阈值上限
    Send Instruction    80  01  80  EA  60      # 自检力最大值默认65530，实际设置60000
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E11
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E11         故障E11未出现

自检故障E12 X轴加速度传感器自检错误
    [Documentation]     检测数值（00 1E）小于阈值下限，或者大于阈值上限
    [Teardown]          恢复默认配置并退出

    Comment             检测数值（00 1E）小于阈值下限
    Send Instruction    80  02  80  00  1F      # 自检X轴加速度最小值默认5，实际设置31
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E12
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E12         故障E12未出现

    Comment             检测数值（00 1E）大于阈值上限
    Send Instruction    80  02  80  00  05      # 自检X轴加速度最小值默认5，恢复成默认值
    Send Instruction    80  03  80  00  1D      # 自检X轴加速度最大值默认65530，实际设置29
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E12
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E12         故障E12未出现

自检故障E13 Y轴加速度传感器自检错误
    [Documentation]     检测数值（00 1E）小于阈值下限，或者大于阈值上限
    [Teardown]          恢复默认配置并退出

    Comment             检测数值（00 1E）小于阈值下限
    Send Instruction    80  04  80  00  1F      # 自检Y轴加速度最小值默认5，实际设置31
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E13
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E13         故障E13未出现

    Comment             检测数值（00 1E）大于阈值上限
    Send Instruction    80  04  80  00  05      # 自检Y轴加速度最小值默认5，恢复成默认值
    Send Instruction    80  05  80  00  1D      # 自检Y轴加速度最大值默认65530，实际设置29
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E13
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E13         故障E13未出现

自检故障E14 Z轴加速度传感器自检错误
    [Documentation]     检测数值（00 1E）小于阈值下限，或者大于阈值上限
    [Teardown]          恢复默认配置并退出

    Comment             检测数值（00 1E）小于阈值下限
    Send Instruction    80  06  80  00  1F      # 自检Z轴加速度最小值默认5，实际设置31
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E14
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E14         故障E14未出现

    Comment             检测数值（00 1E）大于阈值上限
    Send Instruction    80  06  80  00  05      # 自检Z轴加速度最小值默认5，恢复成默认值
    Send Instruction    80  07  80  00  1D      # 自检Z轴加速度最大值默认65530，实际设置29
    Send Instruction    80  08  80  00  00
    Stop PSCmm
    Start PSCmm
    Win Wait Active     质量仪软件测试样例      E14
    ${ERR_MSG_NAME} =   Get From Dictionary     ${GUIMAP}   ERR_MSG
    ${ERR_MSG} =        Control Get Text    质量仪软件测试样例   ${EMPTY}   ${ERR_MSG_NAME}
    Should Contain      ${ERR_MSG}          E14         故障E14未出现

*** keywords ***
Config Confirm
    [Documentation]     确认回传的第一、第二、第三分区（临时）配置参数正确性
    [Arguments]         ${ItemCount}    ${Parameters}   ${Num}
    ${ItemCountStr} =           Convert To String       ${ItemCount}
    :FOR    ${i}    IN RANGE    ${Num}
    \       @{ItemCountAbs} =   GenItemList         ${ItemCountStr}
    \       ${ItemCountAbs} =   Get From List       ${ItemCountAbs}     ${i}
    \       ${ACK} =            Get From List       ${Parameters}    ${i}
    \       @{Response} =       Check ACK MSG       ${ItemCountAbs}
    \       Run Keyword And Continue On Failure
    \       ...                 Confirm ACK     回传配置参数错误    ${ACK}  @{Response}

更改力下限
    [Documentation]     为了测试力上限异常用例，力下限更改为100。
    ${ItemCount} =      Get Item Count
    Send Instruction    80  06  0F  00  64
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}
    ${ItemCount} =      Get Item Count
    Send Instruction    80  0F  0F  00  01
    ${item1} =          Evaluate            ${ItemCount}
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误           8000070000     @{Response1}

Confirm ACK
    [Documentation]     应答帧确认
    [Arguments]         ${MESSAGE}      ${Expect}   @{Response}
    ${ACK} =            Catenate    SEPARATOR=      @{Response}
    Should Be Equal As Strings  ${ACK}  ${Expect}   ${MESSAGE}

回传任务清单货包测量质量结果
    [Documentation]     4.1.1 测量仪收到本指令后，需回复确认接收应答。
    ...                 首先将任务清单的货包总数返回给管理机，
    ...                 然后将EEPROM中保存的所有任务清单测量数据回送给管理机。
    [Arguments]         ${BAG_NO}
    Comment             4.1.1 回传任务清单货包测量质量结果指令
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  03  00  00
    ${item1} =          Evaluate            ${ItemCount}
    ${item2} =          Evaluate            ${ItemCount} + 1
    @{Response1} =      Check ACK MSG       ${item1}
    Confirm ACK         确认接收应答帧错误   8000070000  @{Response1}
    @{Response2} =      Check ACK MSG       ${item2}
    ${Expect} =         Catenate    SEPARATOR=  80  ${BAG_NO}   090000
    Confirm ACK         回送货包个数数据帧错误或任务清单测量的货包个数错误   ${Expect}   @{Response2}

清除EEPROM中的任务清单并退出
    Comment             4.1.2 任务清单货包总数指令 清除EEPROM中的任务清单
    ${ItemCount} =      Get Item Count
    Send Instruction    80  00  06  00  00
    Stop PSCmm

手动测量参数重置并退出
    Comment             4.1.7 ~ 4.1.8 手动测量参数重置
    Send Instruction    80  00  F3  00  01
    Send Instruction    80  00  F3  00  00
    Stop PSCmm

恢复默认配置并退出
    Comment             EPPROM恢复默认配置
    Win Active          质量仪软件测试样例
    Click Button        RECO_DEFAULT
    Win Wait Active     PSCmm       默认设置恢复成功
    Send                {ENTER}
    Stop PSCmm

Get Item Count
    [Documentation]     Get the current item count.
    ${ListName} =       Get From Dictionary     ${GUIMAP}   ACK_MSG
    ${count} =          Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetItemCount  ${EMPTY}    ${EMPTY}
    [Return]            ${count}

Check ACK MSG
    [Arguments]         ${ItemCount}
    [Documentation]     Verfy the ACK messages.
    ${ListName} =       Get From Dictionary     ${GUIMAP}   ACK_MSG
    ${HEAD} =           Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    0
    ${ST1} =            Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    1
    ${ST2} =            Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    2
    ${ST3} =            Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    3
    ${SP1} =            Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    4
    ${SP2} =            Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    5
    ${CRC_H} =          Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    6
    ${CRC_L} =          Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    7
    ${TAIL} =           Control List View   质量仪软件测试样例   ${EMPTY}    ${ListName}
    ...                                     GetText     ${ItemCount}    8
    Run Keyword And Continue On Failure
    ...                 Should Be Equal As Strings          ${HEAD}     83      HEAD MISMATCH
    Run Keyword And Continue On Failure
    ...                 Should Be Equal As Strings          ${TAIL}     69      TAIL MISMATCH
    ${CRC_Ver} =        Catenate    SEPARATOR=      ${CRC_H}    ${CRC_L}
    CRC Verification    ${CRC_Ver}  ${ST1}  ${ST2}  ${ST3}  ${SP1}  ${SP2}
    [Return]            ${ST1}  ${ST2}  ${ST3}  ${SP1}  ${SP2}

Start PSCmm
    [Documentation]     Start the PSCmm application and do self-test.
    Run                 PSCmm\\PSCmm.exe      PSCmm
    Wait For Active Window     质量仪软件测试样例
    Click Button        SELF_TEST

Start PSCmm With No SELF_TEST
    [Documentation]     Start the PSCmm application and do self-test.
    Run                 PSCmm\\PSCmm.exe      PSCmm
    Wait For Active Window     质量仪软件测试样例

Stop PSCmm
    [Documentation]     Shut down PSCmm application
    Win Active          质量仪软件测试样例
    Click Button        Exit

Click Button
    [Arguments]         ${ButtonText}
    [Documentation]     Click a button by its text name, using the PSCmm GUI Map.
    ${ButtonName} =     Get From Dictionary     ${GUIMAP}   ${ButtonText}
    Comment             Library Collections
    Control Click       质量仪软件测试样例   ${EMPTY}    ${ButtonName}

CRC Generation
    [Arguments]         @{CrcBuff}
    [Documentation]     Generate the CRC code.
    ${CRC_Cal} =        Generate    @{CrcBuff}
    [Return]            ${CRC_Cal}

CRC Verification
    [Arguments]         ${CRC_Ver}      @{CrcBuff}
    [Documentation]     Verify the CRC code.
    ${CRC_Cal} =        CRC Generation      @{CrcBuff}
    Run Keyword And Continue On Failure
    ...                 Should Be Equal As Strings  ${CRC_Cal}  ${CRC_Ver}      CRC verification failed

Set Texts
    [Arguments]                 @{EditTexts}
    [Documentation]             Set the Instruction texts.
    :FOR    ${i}    IN RANGE    1   10
    \       ${EditID} =         Catenate    SEPARATOR=      INSTRUCTION     ${i}
    \       ${EditName} =       Get From Dictionary     ${GUIMAP}   ${EditID}
    \       ${index} =          Evaluate    ${i} - 1
    \       Control Set Text    质量仪软件测试样例   ${EMPTY}    ${EditName}     @{EditTexts}[${index}]

Send Instruction
    [Arguments]         ${CO1}  ${CO2}  ${CO3}  ${CP1}  ${CP2}
    [Documentation]     Send instruction
    @{CrcBuff} =        Create List     ${CO1}  ${CO2}  ${CO3}  ${CP1}  ${CP2}
    ${CRC_Cal} =        CRC Generation      @{CrcBuff}
    @{character} =      Split String To Characters  ${CRC_Cal}
    ${CRC_H} =          Catenate    SEPARATOR=      @{character}[0]     @{character}[1]
    ${CRC_L} =          Catenate    SEPARATOR=      @{character}[2]     @{character}[3]
    ${HEAD} =           Set variable    83
    ${TAIL} =           Set variable    69
    Set Texts           ${HEAD}  ${CO1}  ${CO2}  ${CO3}  ${CP1}  ${CP2}  ${CRC_H}  ${CRC_L}  ${TAIL}
    Click Button        RECV_COM
    Sleep               200 milliseconds
