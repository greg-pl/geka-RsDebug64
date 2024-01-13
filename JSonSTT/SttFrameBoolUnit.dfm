inherited SttFrameBool: TSttFrameBool
  Height = 36
  ExplicitHeight = 36
  inherited BevelAll: TBevel
    Height = 36
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 378
    ExplicitHeight = 36
  end
  object SttCheckBox: TCheckBox
    Left = 12
    Top = 10
    Width = 357
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    Caption = 'SttCheckBox'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = SttCheckBoxClick
  end
end
