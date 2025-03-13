@echo off
REM Batch script to validate a TEI XML file using Schematron with SchXslt.

REM Define paths (update these as needed)
set SCHXSLT_JAR="../tools/lib/schxslt-cli.jar"
set SCHEMATRON_FILE="tei-validation.sch"
set XML_FILE=%1
set REPORT_FILE="validation-report.xml"

REM Check if an XML file is provided
if "%XML_FILE%"=="" (
    echo Usage: validate-tei.bat input.xml
    exit /b 1
)

REM Run validation
echo Validating %XML_FILE%...
java -jar %SCHXSLT_JAR% -s %SCHEMATRON_FILE% -d %XML_FILE% -o %REPORT_FILE%

REM Check if validation succeeded
if %errorlevel% neq 0 (
    echo Validation failed!
    exit /b %errorlevel%
) else (
    echo Validation complete. See %REPORT_FILE% for results.
)

exit /b 0
