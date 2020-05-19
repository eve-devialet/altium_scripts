{..............................................................................}
{ Summary Remove Component not in CSV                                          }
{ You need a component list (Sch name CSV file, one column).                   }
{ Only the names corresponding to the list will be kept in the library.        }
{                                                                              }
{..............................................................................}

{..............................................................................}
{..............................................................................}
Procedure GenerateReport(Report : TStringList);
Var
    Document : IServerDocument;
Begin
    Report.Insert(0,'SCH Library Report');
    Report.Insert(1,'------------------------------');
    Report.SaveToFile('C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');

    Document := Client.OpenDocument('Text','C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');
    If Document <> Nil Then
        Client.ShowDocument(Document);
End;
{..............................................................................}

{..............................................................................}
Procedure RemoveComponentNotInCsv;
Var
    StrList          : TStringList   ;
    FileName         : TDynamicString;
    CurrentLib      : ISch_Library;
    LibComp         : ISch_Component;
    LibraryIterator : ISch_Iterator;
    ReportInfo      : TStringList;
    CurName         : TString;
    NameOk          : Boolean;
    i               : Integer;
Begin

    If SchServer = Nil Then Exit;
    CurrentLib := SchServer.GetCurrentSchDocument;
    If CurrentLib = Nil Then Exit;

  // check if the document is a schematic library and if not
    // exit.
    If CurrentLib.ObjectID <> eSchLib Then
    Begin
         ShowError('Please open schematic library.');
         Exit;
    End;

    // Create a TStringList object to store data
    ReportInfo := TStringList.Create;

    // Open file
    FileName := 'C:\Users\eveaporee\Desktop\list_schems.csv';
    // check if file exists or not
    If Not(FileExists(FileName)) or (FileName = '') Then
    Begin
        ShowWarning('The component list file doesnt exist!');
        Exit;
    End;

    // get the library object for the library iterator.
    LibraryIterator := CurrentLib.SchLibIterator_Create;
    // Note MkSet function to create a set compatible with the
    // Scripting engine since sets not supported.
    LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));

    StrList := TStringList.Create;
    Try
        StrList.LoadFromFile(FileName);
       // Start library iteration
        LibComp := LibraryIterator.FirstSchObject;
        ReportInfo.Add('Start loop');
        While LibComp <> Nil Do
        Begin
            // Report stuff
            ReportInfo.Add(LibComp.LibReference);
            // Reset boolean
            NameOk := False;

            // Compare with CSV
            For i:=0 To StrList.Count-1 Do
            Begin
                If LibComp.LibReference = StrList[i] Then
                   Begin
                        NameOk := True;
                        ReportInfo.Add('Name OK');
                   End;
            End;

            // Action when name not found
            If not NameOK Then
            Begin
                 // Comment the following line if you want a dummy pass
                 //CurrentLib.RemoveComponent(LibComp);
                 ReportInfo.Add('Removed');
            End;

            // Next library object
            LibComp := LibraryIterator.NextSchObject;
        End;
        // End library iteration

    Finally
        StrList.Free;
        // we are finished fetching symbols of the current library.
        CurrentLib.SchIterator_Destroy(LibraryIterator);
    End;


    // Refresh library.
    CurrentLib.GraphicallyInvalidate;

    GenerateReport(ReportInfo);
    ReportInfo.Free;
End;
{..............................................................................}

