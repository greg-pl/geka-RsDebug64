object EditSectionsDlg: TEditSectionsDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 225
  ClientWidth = 384
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  DesignSize = (
    384
    225)
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 302
    Top = 191
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 221
    Top = 191
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  inline SectionsDefFrame: TSectionsDefFrame
    Left = 8
    Top = 8
    Width = 369
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 369
    ExplicitHeight = 177
    inherited Panel1: TPanel
      Width = 369
      Height = 177
      ExplicitLeft = -48
      ExplicitTop = -40
      inherited SectionsListMemo: TMemo
        Width = 179
        Height = 155
        ExplicitWidth = 179
        ExplicitHeight = 155
      end
    end
  end
end
