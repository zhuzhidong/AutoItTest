# AutoItTest

Calculator是AutoItLibrary官方示例，重写成.robot文件并修复其中错误。

PSCmm是质量仪模拟软件，完成编写了接口测试部分的测试用例。PSCmm/PSCmm目录下有软件执行文件、配置文件和相应文档。

robotframework-autoitlibrary-1.2.1是将官方autoitlibrary库修改成Python3版本，替换PIL库为Pillow库。

## 依赖环境

* Python 32bit
* robotframework库
* Pillow库
* pywin32库

PSCmm示例只能使用Python 32bit，因为质量仪软件应答消息控件是SysListView32控件，导致需要32bit的AutoItX3.dll才可以获取到控件内容，即应答消息，所以在安装AutoItLibrary时需要拷贝32bit的AutoItX3.dll，这需要Python是32bit的版本。

其余的控件在32bit和64bit下都正常，深层原因不明。

## 执行用例

运行示例文件夹*RunTests.bat*即可运行用例，生成测试报告。