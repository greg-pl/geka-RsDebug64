object ProgressForm: TProgressForm
  Left = 717
  Top = 289
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 106
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 389
    Height = 106
    Align = alClient
  end
  object InfoLabel: TLabel
    Left = 16
    Top = 16
    Width = 361
    Height = 20
    Alignment = taCenter
    AutoSize = False
    Caption = 'InfoLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object ProgressBar: TProgressBar
    Left = 16
    Top = 48
    Width = 361
    Height = 16
    Min = 0
    Max = 100
    TabOrder = 0
  end
  object BreakBtn: TButton
    Left = 160
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Przerwij'
    TabOrder = 1
    OnClick = BreakBtnClick
  end
  object WakeUpTimer: TTimer
    OnTimer = WakeUpTimerTimer
    Left = 344
    Top = 8
  end
end
