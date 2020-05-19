{..............................................................................}
{ Summary Remove Footprint Component not in CSV                                }
{ You need a component list (footprint ref CSV file, one column).              }
{ Only the names corresponding to the list will be kept in the library.        }
{..............................................................................}

{..............................................................................}
{..............................................................................}
Procedure GenerateReport(Report : TStringList);
Var
    Document : IServerDocument;
Begin
    Report.Insert(0,'PCB Library Alias Report');
    Report.Insert(1,'------------------------------');
    Report.SaveToFile('C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');

    Document := Client.OpenDocument('Text','C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');
    If Document <> Nil Then
        Client.ShowDocument(Document);
End;
{..............................................................................}

{..............................................................................}
Procedure RemoveFootprintNotInCsv;
Var
    StrList          : TStringList   ;
    FileName         : TDynamicString;
    CurrentLib      : IPcb_Library;
    LibComp         : IPcb_LibComponent;
    LibraryIterator : IPcb_Iterator;
    ReportInfo      : TStringList;
    CurName         : TString;
    NameOk          : Boolean;
    i               : Integer;
Begin

    If PcbServer = Nil Then Exit;
    CurrentLib := PcbServer.GetCurrentPcbLibrary;
    If CurrentLib = Nil Then ShowWarning('No PCBLib opened');

    // Create a TStringList object to store data
    ReportInfo := TStringList.Create;

    // Open file
    FileName := 'C:\Users\eveaporee\Desktop\list_footprints.csv';
    // check if file exists or not
    If Not(FileExists(FileName)) or (FileName = '') Then
    Begin
        ShowWarning('The footprint list file doesnt exist!');
        Exit;
    End;

    // get the library object for the library iterator.
    LibraryIterator := CurrentLib.LibraryIterator_Create;
    ReportInfo.Add('Component count: ');
    ReportInfo.Add(CurrentLib.ComponentCount);

    StrList := TStringList.Create;
    Try
        StrList.LoadFromFile(FileName);
       // Start library iteration
        LibComp := LibraryIterator.FirstPcbObject;
        While LibComp <> Nil Do
        Begin
            // Report stuff
            ReportInfo.Add(LibComp.Name);
            // Reset boolean
            NameOk := False;

            // Compare with CSV
            For i:=0 To StrList.Count-1 Do
            Begin
                If LibComp.Name = StrList[i] Then
                   Begin
                        NameOk := True;
                        ReportInfo.Add('Name OK');
                   End;
            End;

            // Action when name not found
            If not NameOK Then
            Begin
                 // Comment the following line if you want a dummy pass
                 CurrentLib.RemoveComponent(LibComp);
                 ReportInfo.Add('Removed');
            End;

            // Next library object
            LibComp := LibraryIterator.NextPcbObject;
        End;
        // End library iteration

    Finally
        StrList.Free;
    End;

    CurrentLib.RefreshView;
    ReportInfo.Add('New component count: ');
    ReportInfo.Add(CurrentLib.ComponentCount);
    GenerateReport(ReportInfo);
    ReportInfo.Free;
    Close;
End;
{..............................................................................}

