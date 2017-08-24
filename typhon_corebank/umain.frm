object frmMain: TfrmMain
  Left = 662
  Height = 585
  Top = 376
  Width = 987
  Caption = 'frmMain'
  ClientHeight = 585
  ClientWidth = 987
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  LCLVersion = '6.2'
  WindowState = wsMaximized
  object TreeView1: TTreeView
    Left = 0
    Height = 585
    Top = 0
    Width = 225
    Align = alLeft
    ReadOnly = True
    TabOrder = 0
    OnClick = TreeView1Click
    OnMouseDown = TreeView1MouseDown
    Options = [tvoAutoItemHeight, tvoHideSelection, tvoKeepCollapsedNodes, tvoReadOnly, tvoShowButtons, tvoShowLines, tvoShowRoot, tvoToolTips, tvoThemedDraw]
  end
  object Splitter1: TSplitter
    Left = 225
    Height = 585
    Top = 0
    Width = 15
  end
  object Panel1: TPanel
    Left = 240
    Height = 585
    Top = 0
    Width = 747
    Align = alClient
    Anchors = [akTop, akLeft, akBottom]
    Caption = 'Panel1'
    ClientHeight = 585
    ClientWidth = 747
    TabOrder = 2
    object Panel2: TPanel
      Left = 1
      Height = 39
      Top = 1
      Width = 745
      Align = alTop
      Caption = 'Panel2'
      ClientHeight = 39
      ClientWidth = 745
      TabOrder = 0
      Visible = False
      object btnNew: TBitBtn
        Left = 1
        Height = 37
        Top = 1
        Width = 100
        Align = alLeft
        Caption = 'New'
        OnClick = btnNewClick
        TabOrder = 0
      end
      object btnRefresh: TBitBtn
        Left = 501
        Height = 37
        Top = 1
        Width = 106
        Align = alLeft
        Caption = 'Refresh'
        TabOrder = 1
      end
      object btnExport: TBitBtn
        Left = 401
        Height = 37
        Top = 1
        Width = 100
        Align = alLeft
        Caption = 'Export Data'
        TabOrder = 2
      end
      object btnView: TBitBtn
        Left = 301
        Height = 37
        Top = 1
        Width = 100
        Align = alLeft
        Caption = 'View'
        TabOrder = 3
      end
      object btnDelete: TBitBtn
        Left = 201
        Height = 37
        Top = 1
        Width = 100
        Align = alLeft
        Caption = 'Delete'
        TabOrder = 4
      end
      object btnUpdate: TBitBtn
        Left = 101
        Height = 37
        Top = 1
        Width = 100
        Align = alLeft
        Caption = 'Update'
        TabOrder = 5
      end
    end
    object PageControl1: TPageControl
      Left = 1
      Height = 544
      Top = 40
      Width = 745
      Align = alClient
      TabOrder = 1
    end
  end
end
