object EditTypeItemForm: TEditTypeItemForm
  Left = 727
  Top = 413
  Width = 333
  Height = 238
  Caption = 'EditTypeItemForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 281
    Height = 145
  end
  object Label1: TLabel
    Left = 40
    Top = 56
    Width = 72
    Height = 16
    Caption = 'Nazwa typu '
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 40
    Top = 120
    Width = 121
    Height = 16
    Caption = 'Spos'#243'b wy'#347'wietlania'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 72
    Top = 88
    Width = 94
    Height = 16
    Caption = 'Ilo'#347#263' powt'#243'rze'#324' '
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object NameEdit: TLabeledEdit
    Left = 120
    Top = 24
    Width = 153
    Height = 21
    EditLabel.Width = 43
    EditLabel.Height = 16
    EditLabel.Caption = 'Nazwa '
    EditLabel.Font.Charset = EASTEUROPE_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Arial'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 0
  end
  object TypeNameBox: TComboBox
    Left = 120
    Top = 56
    Width = 153
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 1
    Text = 'TypeNameBox'
  end
  object DisplayTypeBox: TComboBox
    Left = 176
    Top = 120
    Width = 97
    Height = 21
    Style = csDropDownList
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 3
  end
  object OkBtn: TButton
    Left = 128
    Top = 164
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 4
    OnClick = OkBtnClick
  end
  object CancelBtn: TButton
    Left = 216
    Top = 164
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object RepeatEdit: TSpinEdit
    Left = 183
    Top = 86
    Width = 89
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 2
    Value = 1
  end
end
