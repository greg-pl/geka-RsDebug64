inherited SttFrameFloat: TSttFrameFloat
  Width = 365
  Height = 56
  ExplicitWidth = 365
  ExplicitHeight = 56
  object SttFloatEdit: TLabeledEdit
    Left = 12
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 69
    EditLabel.Height = 18
    EditLabel.Caption = 'SttFloatEdit'
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
    OnExit = SttFloatEditExit
    OnKeyPress = SttFloatEditKeyPress
  end
end
