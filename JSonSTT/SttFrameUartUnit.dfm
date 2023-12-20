inherited SttFrameUart: TSttFrameUart
  Width = 379
  Height = 140
  ParentFont = False
  ExplicitWidth = 379
  ExplicitHeight = 140
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 71
    Height = 16
    Caption = 'Port number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 46
    Width = 51
    Height = 16
    Caption = 'Boudrate'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 24
    Top = 76
    Width = 32
    Height = 16
    Caption = 'Parity'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 24
    Top = 106
    Width = 95
    Height = 16
    Caption = 'Count of data bit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 4
    Top = 4
    Width = 370
    Height = 134
    Anchors = [akLeft, akTop, akRight]
  end
  object ComNrBox: TComboBox
    Left = 128
    Top = 13
    Width = 145
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object BoudRateBox: TComboBox
    Left = 128
    Top = 43
    Width = 145
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object ParityBox: TComboBox
    Left = 128
    Top = 73
    Width = 145
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object BitCntBox: TComboBox
    Left = 128
    Top = 103
    Width = 145
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
end
