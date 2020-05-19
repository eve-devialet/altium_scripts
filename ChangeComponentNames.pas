{..............................................................................}
{ Iterate through a schematic library and replace component names by           }
{ the content of a parameter field, here "ID_DEVIALET"                         }
{                                                                              }
{..............................................................................}

{..............................................................................}
Procedure GenerateReport(Report : TStringList);
Var
    Document : IServerDocument;
Begin
    Report.Insert(0,'Schematic Library Alias Report');
    Report.Insert(1,'------------------------------');
    Report.SaveToFile('C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');

    Document := Client.OpenDocument('Text','C:\Users\eveaporee\Documents\Altium\lib_elec\LibraryReport.txt');
    If Document <> Nil Then
        Client.ShowDocument(Document);
End;
{..............................................................................}

{..............................................................................}
Procedure ChangeComponentNames;
Var
    CurrentLib      : ISch_Lib;
    LibraryIterator : ISch_Iterator;
    AnIndex         : Integer;
    i               : integer;
    LibComp         : ISch_Component;
    CopyComp         : ISch_Component;
    S               : TDynamicString;
    ReportInfo      : TStringList;
    NewName         : TDynamicString;
    PIterator       : ISch_Iterator;
    Parameter       : ISch_Parameter;
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

    // get the library object for the library iterator.
    LibraryIterator := CurrentLib.SchLibIterator_Create;

    // Note MkSet function to create a set compatible with the
    // Scripting engine since sets not supported.
    LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));

    // Create a TStringList object to store data
    ReportInfo := TStringList.Create;

    // use of Try / Finally / End exception block to
    // trap exceptions and exit gracefully.
    Try
        // find the aliases for the current library component.
        LibComp := LibraryIterator.FirstSchObject;
        While LibComp <> Nil Do
        Begin
            // Change description
            //LibComp.ComponentDescription := 'Tatatutu';
            // Report stuff
            LibComp.GetState_DatabaseLibraryKeys('PartNumber');
            NewName := ''; // Reset name

            ReportInfo.Add(LibComp.LibReference);
            ReportInfo.Add(' Design Item ID:' + LibComp.DesignItemID);

            // Parameters
            Try
                ReportInfo.Add(' New name:');

                PIterator := LibComp.SchIterator_Create;
                PIterator.AddFilter_ObjectSet(MkSet(eParameter));

                Parameter := PIterator.FirstSchObject;
                While Parameter <> Nil Do
                Begin
                    If Parameter.Name = 'ID_DEVIALET' Then
                    Begin
                         NewName := Parameter.CalculatedValueString;

                    End;

                    Parameter := PIterator.NextSchObject;
                End;
            Finally
                LibComp.SchIterator_Destroy(PIterator);
            End;
            // End parameters loop
            // Verify we found a new name:
            If NewName = '' Then
               Begin
                    NewName := LibComp.LibReference;
                    ReportInfo.Add(' NO NEW NAME FOUND');
               End;
            ReportInfo.Add(' ' + NewName);
            ReportInfo.Add('');

            // Actually change name
            LibComp.DesignItemId := NewName;
            LibComp.LibReference := NewName;
            //CopyComp := LibComp.Replicate();
            //CopyComp.LibReference := NewName;
            // obtain the next schematic symbol in the library
            LibComp := LibraryIterator.NextSchObject;
        End;


    Finally
        // we are finished fetching symbols of the current library.
        CurrentLib.SchIterator_Destroy(LibraryIterator);
    End;
    // Refresh library.
    CurrentLib.GraphicallyInvalidate;

    GenerateReport(ReportInfo);
    ReportInfo.Free;
End;
{..............................................................................}

{..............................................................................}
End.

// Synopsis
// --------
// This library iterator iterates through a schematic library and checks each component for its alias.
// A component might have variations for example different power consumption and switching speeds but have the
// same functionality. For example 74 series might have a 74LS and 74S variations.

// A good example to find aliases of library components is the 4 Port Serial Interface.SchLib file.
