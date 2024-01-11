inherited SttFrameAddrIp: TSttFrameAddrIp
  Width = 379
  Height = 77
  ExplicitWidth = 379
  ExplicitHeight = 77
  inherited BevelAll: TBevel
    Width = 379
    Height = 77
    ExplicitWidth = 379
    ExplicitHeight = 77
  end
  object AddressIpEdit: TLabeledEdit
    Left = 124
    Top = 16
    Width = 121
    Height = 21
    EditLabel.Width = 64
    EditLabel.Height = 18
    EditLabel.Caption = 'Address IP'
    EditLabel.Font.Charset = EASTEUROPE_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Arial Unicode MS'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 0
    OnExit = AddressIpEditExit
    OnKeyPress = PortNrEditKeyPress
  end
  object PortNrEdit: TLabeledEdit
    Left = 124
    Top = 43
    Width = 121
    Height = 21
    EditLabel.Width = 71
    EditLabel.Height = 18
    EditLabel.Caption = 'Port number'
    EditLabel.Font.Charset = EASTEUROPE_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Arial Unicode MS'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 1
    OnExit = PortNrEditExit
    OnKeyPress = PortNrEditKeyPress
  end
end
