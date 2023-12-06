inherited UpLoadFileForm: TUpLoadFileForm
  VertScrollBar.Range = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'UpLoadFileForm'
  ClientHeight = 338
  ClientWidth = 387
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 16
    Top = 144
    Width = 38
    Height = 16
    Caption = 'Adres '
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object LabeledEdit1: TLabeledEdit [1]
    Left = 16
    Top = 112
    Width = 281
    Height = 21
    EditLabel.Width = 58
    EditLabel.Height = 13
    EditLabel.Caption = 'Nazwa pliku'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object TypeNameBox: TComboBox [2]
    Left = 64
    Top = 144
    Width = 153
    Height = 21
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 11
    Text = 'TypeNameBox'
  end
  object Button3: TButton [3]
    Left = 303
    Top = 176
    Width = 75
    Height = 25
    Caption = 'DownLoad'
    TabOrder = 6
  end
  object Button2: TButton [4]
    Left = 304
    Top = 144
    Width = 75
    Height = 25
    Caption = 'UpLoad'
    TabOrder = 5
  end
  object Button1: TButton [5]
    Left = 336
    Top = 112
    Width = 41
    Height = 17
    Caption = '...'
    TabOrder = 10
  end
  object LabeledEdit2: TLabeledEdit [6]
    Left = 144
    Top = 176
    Width = 113
    Height = 21
    EditLabel.Width = 125
    EditLabel.Height = 16
    EditLabel.Caption = 'Maksymalny rozmiar '
    EditLabel.Font.Charset = EASTEUROPE_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Arial'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 4
  end
  object CheckBox2: TCheckBox [7]
    Left = 8
    Top = 248
    Width = 153
    Height = 17
    Caption = 'Pozostaw w MENU'
    TabOrder = 9
  end
  object CheckBox1: TCheckBox [8]
    Left = 8
    Top = 224
    Width = 153
    Height = 17
    Caption = 'Widoczne okno'
    TabOrder = 8
  end
  object LabeledEdit3: TLabeledEdit [9]
    Left = 16
    Top = 16
    Width = 281
    Height = 21
    EditLabel.Width = 73
    EditLabel.Height = 13
    EditLabel.Caption = 'Nazwa operacji'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
  end
  inherited StatusBar: TStatusBar
    Top = 319
    Width = 387
  end
  inherited ToolBar1: TToolBar
    Width = 387
  end
  inherited ParamPanel: TPanel
    Width = 387
    Height = 44
  end
  inherited TreeImages: TImageList
    Left = 24
  end
end
