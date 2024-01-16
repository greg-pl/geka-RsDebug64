object EditVarItemForm: TEditVarItemForm
  Left = 727
  Top = 356
  BorderIcons = [biSystemMenu]
  Caption = 'EditVarItemForm'
  ClientHeight = 220
  ClientWidth = 305
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
    Left = 25
    Top = 81
    Width = 63
    Height = 16
    Caption = 'Type name'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 25
    Top = 137
    Width = 90
    Height = 16
    Caption = 'Display method'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 25
    Top = 110
    Width = 105
    Height = 16
    Caption = 'Count of repetition'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 25
    Top = 21
    Width = 34
    Height = 16
    Caption = 'Name'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 25
    Top = 53
    Width = 81
    Height = 16
    Caption = 'Addreds (hex)'
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
