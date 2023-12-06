object EditVarItemForm: TEditVarItemForm
  Left = 727
  Top = 356
  Width = 321
  Height = 259
  BorderIcons = [biSystemMenu]
  Caption = 'EditVarItemForm'
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
    Height = 161
  end
  object Label1: TLabel
    Left = 32
    Top = 80
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
    Top = 144
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
    Left = 48
    Top = 112
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
  object Label4: TLabel
    Left = 32
    Top = 18
    Width = 39
    Height = 16
    Caption = 'Nazwa'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 32
    Top = 50
    Width = 67
    Height = 16
    Caption = 'Adres (hex)'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object TypeNameBox: TComboBox
    Left = 112
    Top = 76
    Width = 169
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 2
    Text = 'TypeNameBox'
    OnKeyPress = SelectBoxKeyPress
  end
  object DisplayTypeBox: TComboBox
    Left = 168
    Top = 136
    Width = 113
    Height = 21
    Style = csDropDownList
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 4
    OnKeyPress = SelectBoxKeyPress
  end
  object OkBtn: TButton
    Left = 128
    Top = 180
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 5
    OnClick = OkBtnClick
    OnKeyPress = EditKeyPress
  end
  object CancelBtn: TButton
    Left = 216
    Top = 180
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
    OnKeyPress = EditKeyPress
  end
  object RepeatEdit: TSpinEdit
    Left = 168
    Top = 104
    Width = 113
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 3
    Value = 1
    OnKeyPress = EditKeyPress
  end
  object VarNameEdit: TEdit
    Left = 112
    Top = 16
    Width = 169
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'VarNameEdit'
    OnKeyPress = EditKeyPress
  end
  object VarAdresEdit: TEdit
    Left = 112
    Top = 48
    Width = 169
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'VarEdit'
    OnKeyPress = EditKeyPress
  end
end
