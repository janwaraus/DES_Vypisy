object fmCustomers: TfmCustomers
  Left = 374
  Top = 132
  Width = 650
  Height = 134
  Caption = 'Z'#225'kazn'#237'ci v tabulce Customers'
  Color = clBtnFace
  Constraints.MinHeight = 134
  Constraints.MinWidth = 650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    642
    107)
  PixelsPerInch = 96
  TextHeight = 13
  object lbJmeno: TLabel
    Left = 10
    Top = 14
    Width = 37
    Height = 13
    Caption = 'Jm'#233'no'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbPrijmeni: TLabel
    Left = 168
    Top = 14
    Width = 92
    Height = 13
    Caption = 'P'#345#237'jmen'#237' / Firma'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbVS: TLabel
    Left = 378
    Top = 14
    Width = 77
    Height = 13
    Caption = 'VS / smlouva'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edJmeno: TEdit
    Left = 54
    Top = 10
    Width = 101
    Height = 21
    TabOrder = 0
    Text = '%'
    OnKeyUp = edJmenoKeyUp
  end
  object edPrijmeni: TEdit
    Left = 266
    Top = 10
    Width = 101
    Height = 21
    TabOrder = 1
    Text = '%'
    OnKeyUp = edPrijmeniKeyUp
  end
  object btNajdi: TButton
    Left = 564
    Top = 11
    Width = 65
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '&Najdi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = btNajdiClick
  end
  object asgCustomers: TAdvStringGrid
    Left = 0
    Top = 42
    Width = 642
    Height = 65
    Cursor = crDefault
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 6
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 3
    HoverRowCells = [hcNormal, hcSelected]
    OnGetAlignment = asgCustomersGetAlignment
    ActiveCellFont.Charset = DEFAULT_CHARSET
    ActiveCellFont.Color = clWindowText
    ActiveCellFont.Height = -11
    ActiveCellFont.Name = 'Tahoma'
    ActiveCellFont.Style = [fsBold]
    ColumnHeaders.Strings = (
      'Z'#225'kazn'#237'k'
      'Abrak'#243'd'
      'VS'
      'Smlouva'
      'Stav'
      'Fakturovat')
    ControlLook.FixedGradientHoverFrom = clGray
    ControlLook.FixedGradientHoverTo = clWhite
    ControlLook.FixedGradientDownFrom = clGray
    ControlLook.FixedGradientDownTo = clSilver
    ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
    ControlLook.DropDownHeader.Font.Color = clWindowText
    ControlLook.DropDownHeader.Font.Height = -11
    ControlLook.DropDownHeader.Font.Name = 'Tahoma'
    ControlLook.DropDownHeader.Font.Style = []
    ControlLook.DropDownHeader.Visible = True
    ControlLook.DropDownHeader.Buttons = <>
    ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
    ControlLook.DropDownFooter.Font.Color = clWindowText
    ControlLook.DropDownFooter.Font.Height = -11
    ControlLook.DropDownFooter.Font.Name = 'MS Sans Serif'
    ControlLook.DropDownFooter.Font.Style = []
    ControlLook.DropDownFooter.Visible = True
    ControlLook.DropDownFooter.Buttons = <>
    Filter = <>
    FilterDropDown.Font.Charset = DEFAULT_CHARSET
    FilterDropDown.Font.Color = clWindowText
    FilterDropDown.Font.Height = -11
    FilterDropDown.Font.Name = 'MS Sans Serif'
    FilterDropDown.Font.Style = []
    FilterDropDown.TextChecked = 'Checked'
    FilterDropDown.TextUnChecked = 'Unchecked'
    FilterDropDownClear = '(All)'
    FilterEdit.TypeNames.Strings = (
      'Starts with'
      'Ends with'
      'Contains'
      'Not contains'
      'Equal'
      'Not equal'
      'Clear')
    FixedColWidth = 185
    FixedRowHeight = 18
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'Tahoma'
    FixedFont.Style = [fsBold]
    FloatFormat = '%.2f'
    HoverButtons.Buttons = <>
    HoverButtons.Position = hbLeftFromColumnLeft
    PrintSettings.DateFormat = 'dd/mm/yyyy'
    PrintSettings.Font.Charset = DEFAULT_CHARSET
    PrintSettings.Font.Color = clWindowText
    PrintSettings.Font.Height = -11
    PrintSettings.Font.Name = 'MS Sans Serif'
    PrintSettings.Font.Style = []
    PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
    PrintSettings.FixedFont.Color = clWindowText
    PrintSettings.FixedFont.Height = -11
    PrintSettings.FixedFont.Name = 'MS Sans Serif'
    PrintSettings.FixedFont.Style = []
    PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
    PrintSettings.HeaderFont.Color = clWindowText
    PrintSettings.HeaderFont.Height = -11
    PrintSettings.HeaderFont.Name = 'MS Sans Serif'
    PrintSettings.HeaderFont.Style = []
    PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
    PrintSettings.FooterFont.Color = clWindowText
    PrintSettings.FooterFont.Height = -11
    PrintSettings.FooterFont.Name = 'MS Sans Serif'
    PrintSettings.FooterFont.Style = []
    PrintSettings.PageNumSep = '/'
    ScrollWidth = 16
    SearchFooter.FindNextCaption = 'Find &next'
    SearchFooter.FindPrevCaption = 'Find &previous'
    SearchFooter.Font.Charset = DEFAULT_CHARSET
    SearchFooter.Font.Color = clWindowText
    SearchFooter.Font.Height = -11
    SearchFooter.Font.Name = 'MS Sans Serif'
    SearchFooter.Font.Style = []
    SearchFooter.HighLightCaption = 'Highlight'
    SearchFooter.HintClose = 'Close'
    SearchFooter.HintFindNext = 'Find next occurrence'
    SearchFooter.HintFindPrev = 'Find previous occurrence'
    SearchFooter.HintHighlight = 'Highlight occurrences'
    SearchFooter.MatchCaseCaption = 'Match case'
    ShowDesignHelper = False
    SortSettings.DefaultFormat = ssAutomatic
    Version = '7.4.2.0'
    ColWidths = (
      185
      90
      81
      100
      90
      90)
  end
  object edVS: TEdit
    Left = 464
    Top = 10
    Width = 85
    Height = 21
    TabOrder = 4
    Text = '%'
    OnKeyUp = edVSKeyUp
  end
  object dbMain: TZConnection
    ControlsCodePage = cGET_ACP
    AutoEncodeStrings = False
    AfterConnect = dbMainAfterConnect
    HostName = 'test.iquest.cz'
    Port = 0
    Database = 'eurosignal'
    User = 'eurosignal'
    Password = 'ayQKeWSf9F'
    Protocol = 'mysql-5'
    Left = 72
    Top = 6
  end
  object qrMain: TZQuery
    Connection = dbMain
    SortType = stIgnored
    CachedUpdates = True
    ReadOnly = True
    SQL.Strings = (
      '')
    Params = <>
    ShowRecordTypes = [usUnmodified, usModified, usInserted, usDeleted]
    WhereMode = wmWhereAll
    Left = 100
    Top = 6
  end
end
