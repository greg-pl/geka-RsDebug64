inherited SttFrameStr: TSttFrameStr
  Width = 365
  Height = 56
  ExplicitWidth = 365
  ExplicitHeight = 56
  inherited BevelAll: TBevel
    Width = 365
    Height = 56
    ExplicitWidth = 365
    ExplicitHeight = 56
  end
  object SttStrEdit: TLabeledEdit
    Left = 12
    Top = 20
    Width = 341
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 57
    EditLabel.Height = 18
    EditLabel.Caption = 'SttStrEdit'
    EditLabel.Font.Charset = EASTEUROPE_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Arial Unicode MS'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnExit = SttStrEditExit
    OnKeyPress = SttStrEditKeyPress
  end
end
