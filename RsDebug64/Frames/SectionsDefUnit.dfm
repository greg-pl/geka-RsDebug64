object SectionsDefFrame: TSectionsDefFrame
  Left = 0
  Top = 0
  Width = 395
  Height = 189
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 395
    Height = 189
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      395
      189)
    object Label1: TLabel
      Left = 10
      Top = 5
      Width = 104
      Height = 16
      Caption = 'Sections definition'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object SectionsListMemo: TMemo
      Left = 175
      Top = 8
      Width = 205
      Height = 167
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        '.text'
        '')
      TabOrder = 1
    end
    object SelSectionModeBox: TRadioGroup
      Left = 3
      Top = 39
      Width = 166
      Height = 105
      Caption = 'Work mode'
      ItemIndex = 0
      Items.Strings = (
        'OFF'
        'Is in section (White List)'
        'Isn'#39't in section (Black List)')
      TabOrder = 0
    end
  end
end
