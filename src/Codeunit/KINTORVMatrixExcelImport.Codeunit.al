codeunit 50108 "KINTO RV Matrix Excel Import"
{
    Permissions = tabledata "KINTO RV Matrix" = RIMD;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ImportErr: Label 'No data found in the Excel file. Please check the file format.';
        ImportSuccessMsg: Label 'Successfully imported %1 RV Matrix entries.';
        MissingItemErr: Label 'Item No. %1 not found in the Item table. Import aborted.';
        DuplicateErr: Label 'Duplicate entry found for Item %1, Usage Type %2, Has Implement %3, Effective Date %4, Max Mileage %5, Max Age %6.';
        FileFilterTxt: Label 'Excel Files (*.xlsx)|*.xlsx';
        DialogTitleTxt: Label 'Select Excel File to Import';

    trigger OnRun()
    begin
        ImportRVMatrixFromExcel();
    end;

    procedure ImportRVMatrixFromExcel()
    var
        FileManagement: Codeunit "File Management";
        ServerFileName: Text;
        InputStream: InStream;
        FileName: Text;
    begin
        //     // Select file
        //     FileName := FileManagement.GetFileName(FileManagement.UploadFile(DialogTitleTxt, FileFilterTxt));
        //     if FileName = '' then exit;

        //     ServerFileName := FileManagement.UploadFileSilent(InputStream);
        //     if ServerFileName = '' then exit;

        //     ReadExcelSheet(InputStream);
        //     ProcessRVMatrixData();
    end;

    procedure ImportRVMatrixFromStream(var InputStream: InStream; FileName: Text)
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        TempExcelBuffer.OpenBookStream(InputStream, FileName);
        TempExcelBuffer.ReadSheet();

        ProcessRVMatrixData();
    end;

    local procedure ReadExcelSheet(var InputStream: InStream)
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        TempExcelBuffer.OpenBookStream(InputStream, 'RVMatrixImport.xlsx');
        TempExcelBuffer.ReadSheet();
    end;

    local procedure ProcessRVMatrixData()
    var
        RVMatrix: Record "KINTO RV Matrix";
        Item: Record Item;
        RowNo: Integer;
        MaxRow: Integer;
        ImportedCount: Integer;
        ItemNo: Code[20];
        UsageType: Enum "KINTO Usage Type";
        HasImplement: Boolean;
        EffectiveDate: Date;
        MaxMileage: Decimal;
        MaxAge: Integer;
        TabulatedAge: Integer;
        ResidualValuePct: Decimal;
        StatusOption: Option;
        MSRPRecord: Boolean;
        CellValue: Text;
    begin
        // Expected Excel format (row 1 = headers):
        // Col A: Item No.
        // Col B: Usage Type (Normal/Mixed/Severe)
        // Col C: Has Implement (TRUE/FALSE)
        // Col D: Effective Start Date
        // Col E: Max Mileage
        // Col F: Max Age
        // Col G: Tabulated Age
        // Col H: Residual Value %
        // Col I: Status (Active/Inactive/Blocked)
        // Col J: MSRP Record (TRUE/FALSE)

        MaxRow := GetLastRow();

        if MaxRow <= 1 then
            Error(ImportErr);

        ImportedCount := 0;

        for RowNo := 2 to MaxRow do begin
            // Read Item No.
            CellValue := GetCellValue(RowNo, 1);
            if CellValue = '' then
                continue; // Skip empty rows

            ItemNo := CopyStr(CellValue, 1, MaxStrLen(ItemNo));

            // Validate Item exists
            if not Item.Get(ItemNo) then
                Error(MissingItemErr, ItemNo);

            // Read Usage Type
            CellValue := GetCellValue(RowNo, 2);
            case CellValue of
                'Normal':
                    UsageType := UsageType::Normal;
                'Mixed':
                    UsageType := UsageType::Mixed;
                'Severe':
                    UsageType := UsageType::Severe;
                else
                    UsageType := UsageType::Normal;
            end;

            // Read Has Implement
            CellValue := GetCellValue(RowNo, 3);
            HasImplement := (CellValue = 'TRUE') or (CellValue = 'Yes') or (CellValue = '1');

            // Read Effective Start Date
            CellValue := GetCellValue(RowNo, 4);
            if CellValue <> '' then
                Evaluate(EffectiveDate, CellValue, 9)
            else
                EffectiveDate := Today;

            // Read Max Mileage
            CellValue := GetCellValue(RowNo, 5);
            if CellValue <> '' then
                Evaluate(MaxMileage, CellValue)
            else
                MaxMileage := 0;

            // Read Max Age
            CellValue := GetCellValue(RowNo, 6);
            if CellValue <> '' then
                Evaluate(MaxAge, CellValue)
            else
                MaxAge := 0;

            // Read Tabulated Age
            CellValue := GetCellValue(RowNo, 7);
            if CellValue <> '' then
                Evaluate(TabulatedAge, CellValue)
            else
                TabulatedAge := 0;

            // Read Residual Value %
            CellValue := GetCellValue(RowNo, 8);
            if CellValue <> '' then
                Evaluate(ResidualValuePct, CellValue)
            else
                continue; // Skip if no RV value

            // Read Status
            CellValue := GetCellValue(RowNo, 9);
            case CellValue of
                'Active':
                    StatusOption := 0;
                'Inactive':
                    StatusOption := 1;
                'Blocked':
                    StatusOption := 2;
                else
                    StatusOption := 0;
            end;

            // Read MSRP Record
            CellValue := GetCellValue(RowNo, 10);
            MSRPRecord := (CellValue = 'TRUE') or (CellValue = 'Yes') or (CellValue = '1');

            // Check for duplicates
            RVMatrix.SetRange("Item No.", ItemNo);
            RVMatrix.SetRange("Usage Type", UsageType);
            RVMatrix.SetRange("Has Implement", HasImplement);
            RVMatrix.SetRange("Effective Start Date", EffectiveDate);
            RVMatrix.SetRange("Max Mileage", MaxMileage);
            RVMatrix.SetRange("Max Age", MaxAge);
            if RVMatrix.FindFirst() then
                Error(DuplicateErr, ItemNo, UsageType, HasImplement, EffectiveDate, MaxMileage, MaxAge);

            // Insert new record
            RVMatrix.Init();
            RVMatrix."Item No." := ItemNo;
            RVMatrix."Usage Type" := UsageType;
            RVMatrix."Has Implement" := HasImplement;
            RVMatrix."Effective Start Date" := EffectiveDate;
            RVMatrix."Max Mileage" := MaxMileage;
            RVMatrix."Max Age" := MaxAge;
            RVMatrix."Tabulated Age" := TabulatedAge;
            RVMatrix."Residual Value %" := ResidualValuePct;
            RVMatrix.Status := StatusOption;
            RVMatrix."MSRP Record" := MSRPRecord;
            RVMatrix."Created Date" := Today;
            RVMatrix."Modified Date" := Today;
            RVMatrix.Insert(true);

            ImportedCount += 1;
        end;

        Message(ImportSuccessMsg, ImportedCount);
    end;

    local procedure GetCellValue(RowNo: Integer; ColNo: Integer): Text
    begin
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure GetLastRow(): Integer
    var
        MaxRow: Integer;
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRow := TempExcelBuffer."Row No."
        else
            MaxRow := 0;
        exit(MaxRow);
    end;

    procedure DownloadTemplate()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        OutStream: OutStream;
        InputStream: InStream;
        FileName: Text;
    begin
        // Generate a template Excel file for RV Matrix import
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Item No.', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Usage Type', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Has Implement', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Effective Start Date', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Max Mileage', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Max Age', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tabulated Age', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Residual Value %', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Status', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('MSRP Record', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);

        // Add sample row
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('CC-XRE', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Normal', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('FALSE', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(Format(Today, 0, '<Day,2>/<Month,2>/<Year4>'), false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn('20000', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('12', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('12', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('87.81', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Active', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('FALSE', false, '', false, true, false, '', TempExcelBuffer."Cell Type"::Text);

        // TempExcelBuffer.CreateBook('RVMatrixTemplate', 'RV Matrix');
        TempExcelBuffer.WriteSheet('RV Matrix Template', '', '');
        TempExcelBuffer.CloseBook();

        FileName := 'RVMatrix_Template.xlsx';
        // TempExcelBuffer.SetReadFilter('');
        // TempExcelBuffer.OpenBook();
        TempExcelBuffer.ReadSheet();

        DownloadFromStream(InputStream, 'Download RV Matrix Template', '', '', FileName);
    end;
}