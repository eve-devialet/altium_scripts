{..............................................................................}
{ Summary Set all pins to passive mode in a schematic library                  }
{                                                                              }
{..............................................................................}

{..............................................................................}
Var
  ReportInfo : TStringList;

{..............................................................................}

{..............................................................................}
Procedure SetAllPinsToPassive;
Var
  DocType       : WideString;
  SchComponent  : ISch_Component;
  SchLib        : ISch_Lib;
  SchDoc        : ISCh_Doc;
  SchIterator   : ISch_Iterator;
  Pin           : ISch_Pin;
  LibName       : TDynamicString;
  PinIterator   : ISch_Iterator;
  PinState      : TPinElectrical;
Begin
    If SchServer = Nil Then Exit;

    // Obtain the Client interface so can get the Kind property.
    DocType := UpperCase(Client.CurrentView.OwnerDocument.Kind);
    If DocType <> 'SCHLIB' Then
    Begin
        ShowWarning('This is not a Library document!');
        Exit;
    End;

    SchLib := SchServer.GetCurrentSchDocument;
    If SchLib = Nil Then Exit;

    // Create a TStringList object to store Pin data
    ReportInfo := TStringList.Create;
    ReportInfo.Clear;

    LibName := SchLib.DocumentName;
    LibName := ExtractFileName(LibName);
    ReportInfo.Add(LibName);

    // Create an iterator to look for components only
    SchIterator := SchLib.SchLibIterator_Create;
    SchIterator.AddFilter_ObjectSet(MkSet(eSchComponent));

    //Default pin state passive
    PinState := 4;

    Try
        SchComponent := SchIterator.FirstSchObject;
        While SchComponent <> Nil Do
        Begin
            // Look for Pins associated with this component.
            PinIterator := SchComponent.SchIterator_Create;
            PinIterator.AddFilter_ObjectSet(MkSet(ePin));
            ReportInfo.Add(SchComponent.LibReference);
            Try
                Pin := PinIterator.FirstSchObject;
                While Pin <> Nil Do
                Begin
                    ReportInfo.Add(' The Pin Designator: ' + Pin.Designator);

                    ReportInfo.Add(Pin.Getstate_Electrical);
                    Pin.Setstate_Electrical(PinState);

                    Pin := PinIterator.NextSchObject;
                End;
            Finally
                SchComponent.SchIterator_Destroy(PinIterator);
            End;

            ReportInfo.Add('');
            SchComponent := SchIterator.NextSchObject;
        End;
    Finally
        SchLib.SchIterator_Destroy(SchIterator);
    End;

    // Refresh library.
    SchLib.GraphicallyInvalidate;

    ReportInfo.Free;
End;
{..............................................................................}

{..............................................................................}

