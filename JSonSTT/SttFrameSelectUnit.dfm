inherited SttFrameSelect: TSttFrameSelect
  Height = 56
  ExplicitHeight = 56
  inherited BevelAll: TBevel
    Height = 56
    ExplicitHeight = 56
  end
  object SttLabel: TLabel
    Left = 12
    Top = 4
    Width = 31
    Height = 18
    Caption = 'Label'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Unicode MS'
    Font.Style = []
    ParentFont = False
  end
  object SttComboBox: TComboBox
    Left = 12
    Top = 24
    Width = 189
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'SttComboBox'
    OnChange = SttComboBoxChange
  end
end
