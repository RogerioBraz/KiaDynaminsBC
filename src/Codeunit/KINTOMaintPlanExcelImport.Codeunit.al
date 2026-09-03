codeunit 50109 "KINTO Maint. Plan Excel Import"
{

    Permissions = tabledata "KINTO Maintenance Plan Header" = RIMD,
                  tabledata "KINTO Maintenance Plan Line" = RIMD;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ImportSuccessMsg: Label 'Successfully imported Maintenance Plan %1 with %2 lines.';
        FileFilterTxt: Label 'Excel Files (*.xlsx)|*.xlsx';
        DialogTitleTxt: Label 'Select Maintenance Plan Excel File';
        NoExcelDataErr: Label 'The maintenance plan was not imported because the Excel file has no data rows after the header. Select a file with maintenance data and try again.';
        InvalidDecimalValueErr: Label 'The maintenance plan was not imported because row %1, column %2 contains the invalid value %3. Enter a valid number in the Excel file and try again.';

    procedure ImportMaintenancePlanFromExcel(PlanID: Code[20]; Description: Text[100]; DiscountPct: Decimal)
    var
        InputStream: InStream;
        FileName: Text;
    begin
        FileName := '';
        if not UploadIntoStream(DialogTitleTxt, '', FileFilterTxt, FileName, InputStream) then
            exit;

        ReadExcelSheet(InputStream, FileName);
        ProcessMaintenancePlanData(PlanID, Description, DiscountPct);
    end;

    local procedure ReadExcelSheet(var InputStream: InStream; FileName: Text)
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(InputStream, FileName);
        TempExcelBuffer.ReadSheet();
    end;

    local procedure ProcessMaintenancePlanData(PlanID: Code[20]; Description: Text[100]; DiscountPct: Decimal)
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        RowNo: Integer;
        MaxRow: Integer;
        ImportedLines: Integer;
        KMInterval: Decimal;
        LaborCost: Decimal;
        PartsCost: Decimal;
        TotalCost: Decimal;
        DiscountedCost: Decimal;
        CellValue: Text;
    begin
        // Expected Excel format (row 1 = headers):
        // Col A: KM Interval
        // Col B: Labor Cost
        // Col C: Parts Cost
        // Col D: Total Cost (optional — calculated if empty)

        MaxRow := GetLastRow();
        if MaxRow <= 1 then
            Error(NoExcelDataErr);

        // Create or update header
        if not MaintHeader.Get(PlanID) then begin
            MaintHeader.Init();
            MaintHeader."Plan ID" := PlanID;
            MaintHeader.Description := Description;
            MaintHeader."Discount %" := DiscountPct;
            MaintHeader.Status := MaintHeader.Status::Active;
            MaintHeader.Insert(true);
        end;

        // Delete existing lines
        MaintLine.SetRange("Plan ID", PlanID);
        MaintLine.DeleteAll();

        ImportedLines := 0;

        for RowNo := 2 to MaxRow do begin
            // KM Interval
            CellValue := GetCellValue(RowNo, 1);
            if CellValue = '' then continue;
            EvaluateDecimal(KMInterval, CellValue, RowNo, 'KM Interval');

            // Labor Cost
            CellValue := GetCellValue(RowNo, 2);
            if CellValue <> '' then
                EvaluateDecimal(LaborCost, CellValue, RowNo, 'Labor Cost')
            else
                LaborCost := 0;

            // Parts Cost
            CellValue := GetCellValue(RowNo, 3);
            if CellValue <> '' then
                EvaluateDecimal(PartsCost, CellValue, RowNo, 'Parts Cost')
            else
                PartsCost := 0;

            // Total Cost
            CellValue := GetCellValue(RowNo, 4);
            if CellValue <> '' then
                EvaluateDecimal(TotalCost, CellValue, RowNo, 'Total Cost')
            else
                TotalCost := LaborCost + PartsCost;

            // Discounted Cost
            DiscountedCost := TotalCost * (1 - DiscountPct / 100);

            // Insert line
            MaintLine.Init();
            MaintLine."Plan ID" := PlanID;
            MaintLine."KM Interval" := KMInterval;
            MaintLine."Labor Cost" := LaborCost;
            MaintLine."Parts Cost" := PartsCost;
            MaintLine."Maintenance Cost" := TotalCost;
            MaintLine."Discounted Cost" := DiscountedCost;
            MaintLine.Insert(true);

            ImportedLines += 1;
        end;

        Message(ImportSuccessMsg, PlanID, ImportedLines);
    end;

    local procedure EvaluateDecimal(var DecimalValue: Decimal; CellValue: Text; RowNo: Integer; ColumnName: Text[50])
    begin
        if not Evaluate(DecimalValue, CellValue) then
            Error(InvalidDecimalValueErr, RowNo, ColumnName, CellValue);
    end;

    local procedure GetCellValue(RowNo: Integer; ColNo: Integer): Text
    begin
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure GetLastRow(): Integer
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            exit(TempExcelBuffer."Row No.")
        else
            exit(0);
    end;
}