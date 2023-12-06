object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 583
  ClientWidth = 854
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 112
    Width = 854
    Height = 471
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel3: TPanel
    Left = 489
    Top = 0
    Width = 225
    Height = 112
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitLeft = 408
    ExplicitTop = 59
    ExplicitHeight = 193
  end
  object Panel4: TPanel
    Left = 177
    Top = 0
    Width = 168
    Height = 112
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 2
    object Label4: TLabel
      Left = 21
      Top = 13
      Width = 76
      Height = 20
      Caption = 'Command'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object RCmdBtn: TButton
      Left = 22
      Top = 72
      Width = 75
      Height = 25
      Caption = 'RCmd'
      TabOrder = 0
      OnClick = RCmdBtnClick
    end
    object RCmdBox: TComboBox
      Left = 22
      Top = 39
      Width = 115
      Height = 21
      ItemIndex = 0
      TabOrder = 1
      Text = 'jtag_reset'
      Items.Strings = (
        'jtag_reset'
        'halt'
        'resume'
        'reset'
        'semihosting enable'
        'semihosting disable'
        '')
    end
  end
  object Panel5: TPanel
    Left = 345
    Top = 0
    Width = 144
    Height = 112
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 3
    ExplicitLeft = 489
    ExplicitTop = 8
    object Label3: TLabel
      Left = 13
      Top = 5
      Width = 76
      Height = 20
      Caption = 'ReadMem'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object ReadMemAdrEdit: TComboBox
      Left = 14
      Top = 31
      Width = 75
      Height = 21
      TabOrder = 0
      Text = '80004c0'
      Items.Strings = (
        '08000000'
        '08000dc0'
        '20000000')
    end
    object ReadMemCntEdit: TComboBox
      Left = 95
      Top = 31
      Width = 42
      Height = 21
      TabOrder = 1
      Text = '40'
      Items.Strings = (
        '40'
        '80'
        '100'
        '200'
        '400')
    end
    object SendTcpBtn: TButton
      Left = 14
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Send'
      TabOrder = 2
      OnClick = SendTcpBtnClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 177
    Height = 112
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 4
    ExplicitLeft = 1
    ExplicitTop = 1
    ExplicitHeight = 191
    object Label1: TLabel
      Left = 46
      Top = 6
      Width = 15
      Height = 20
      Caption = 'IP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 31
      Top = 38
      Width = 31
      Height = 20
      Caption = 'Port'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CloseTcpBtn: TButton
      Left = 89
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = CloseTcpBtnClick
    end
    object IpBox: TComboBox
      Left = 72
      Top = 8
      Width = 92
      Height = 21
      TabOrder = 1
      Text = '127.0.0.1'
    end
    object OpenTcpBtn: TButton
      Left = 8
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = OpenTcpBtnClick
    end
    object PortBox: TComboBox
      Left = 72
      Top = 40
      Width = 81
      Height = 21
      TabOrder = 3
      Text = '50001'
    end
  end
end
