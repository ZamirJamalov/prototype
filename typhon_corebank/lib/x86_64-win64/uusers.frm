object frmusers: Tfrmusers
  Left = 688
  Height = 454
  Top = 298
  Width = 632
  Caption = 'users'
  ClientHeight = 454
  ClientWidth = 632
  OnCreate = FormCreate
  LCLVersion = '6.2'
  object id: TLabeledEdit
    Left = 104
    Height = 23
    Top = 24
    Width = 141
    EditLabel.AnchorSideTop.Control = id
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = id
    EditLabel.AnchorSideBottom.Control = id
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 91
    EditLabel.Height = 15
    EditLabel.Top = 28
    EditLabel.Width = 10
    EditLabel.Caption = 'id'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 0
  end
  object session_: TLabeledEdit
    Left = 104
    Height = 23
    Top = 72
    Width = 141
    EditLabel.AnchorSideTop.Control = session_
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = session_
    EditLabel.AnchorSideBottom.Control = session_
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 58
    EditLabel.Height = 15
    EditLabel.Top = 76
    EditLabel.Width = 43
    EditLabel.Caption = 'session_'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 1
  end
  object login: TLabeledEdit
    Left = 104
    Height = 23
    Top = 120
    Width = 141
    EditLabel.AnchorSideTop.Control = login
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = login
    EditLabel.AnchorSideBottom.Control = login
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 74
    EditLabel.Height = 15
    EditLabel.Top = 124
    EditLabel.Width = 27
    EditLabel.Caption = 'login'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 2
  end
  object password: TLabeledEdit
    Left = 104
    Height = 23
    Top = 168
    Width = 141
    EditLabel.AnchorSideTop.Control = password
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = password
    EditLabel.AnchorSideBottom.Control = password
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 51
    EditLabel.Height = 15
    EditLabel.Top = 172
    EditLabel.Width = 50
    EditLabel.Caption = 'password'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 3
  end
  object wrong_attempt_count: TLabeledEdit
    Left = 104
    Height = 23
    Top = 216
    Width = 141
    EditLabel.AnchorSideTop.Control = wrong_attempt_count
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = wrong_attempt_count
    EditLabel.AnchorSideBottom.Control = wrong_attempt_count
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 74
    EditLabel.Height = 15
    EditLabel.Top = 220
    EditLabel.Width = 27
    EditLabel.Caption = 'WAC'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 4
  end
  object blocked_time: TLabeledEdit
    Left = 104
    Height = 23
    Top = 264
    Width = 141
    EditLabel.AnchorSideTop.Control = blocked_time
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = blocked_time
    EditLabel.AnchorSideBottom.Control = blocked_time
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 30
    EditLabel.Height = 15
    EditLabel.Top = 268
    EditLabel.Width = 71
    EditLabel.Caption = 'blocked_time'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 5
  end
  object email: TLabeledEdit
    Left = 104
    Height = 23
    Top = 312
    Width = 141
    EditLabel.AnchorSideTop.Control = email
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = email
    EditLabel.AnchorSideBottom.Control = email
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 72
    EditLabel.Height = 15
    EditLabel.Top = 316
    EditLabel.Width = 29
    EditLabel.Caption = 'email'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 6
  end
  object mob_phone: TLabeledEdit
    Left = 104
    Height = 23
    Top = 360
    Width = 141
    EditLabel.AnchorSideTop.Control = mob_phone
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = mob_phone
    EditLabel.AnchorSideBottom.Control = mob_phone
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 37
    EditLabel.Height = 15
    EditLabel.Top = 364
    EditLabel.Width = 64
    EditLabel.Caption = 'mob_phone'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 7
  end
  object logon_time: TLabeledEdit
    Left = 104
    Height = 23
    Top = 408
    Width = 141
    EditLabel.AnchorSideTop.Control = logon_time
    EditLabel.AnchorSideTop.Side = asrCenter
    EditLabel.AnchorSideRight.Control = logon_time
    EditLabel.AnchorSideBottom.Control = logon_time
    EditLabel.AnchorSideBottom.Side = asrBottom
    EditLabel.Left = 41
    EditLabel.Height = 15
    EditLabel.Top = 412
    EditLabel.Width = 60
    EditLabel.Caption = 'logon_time'
    EditLabel.ParentColor = False
    LabelPosition = lpLeft
    TabOrder = 8
  end
end