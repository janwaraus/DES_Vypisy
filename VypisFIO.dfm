object fmMain: TfmMain
  Left = 512
  Top = 41
  Width = 1468
  Height = 1192
  Caption = 'Na'#269'ten'#237', oprava a ulo'#382'en'#237' bankovn'#237'ho v'#253'pisu'
  Color = clBtnFace
  Constraints.MinHeight = 721
  Constraints.MinWidth = 1312
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    1452
    1154)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHlavicka: TLabel
    Left = 111
    Top = 2
    Width = 115
    Height = 16
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '...'
    Color = clMoneyGreen
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlBottom
  end
  object asgMain: TAdvStringGrid
    Left = 110
    Top = 26
    Width = 863
    Height = 508
    Cursor = crDefault
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 8
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 5
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    OnClick = asgMainClick
    OnKeyUp = asgMainKeyUp
    HoverRowCells = [hcNormal, hcSelected]
    OnGetCellColor = asgMainGetCellColor
    OnGetAlignment = asgMainGetAlignment
    OnCanEditCell = asgMainCanEditCell
    OnCellsChanged = asgMainCellsChanged
    ActiveCellFont.Charset = DEFAULT_CHARSET
    ActiveCellFont.Color = clWindowText
    ActiveCellFont.Height = -11
    ActiveCellFont.Name = 'Tahoma'
    ActiveCellFont.Style = [fsBold]
    ColumnHeaders.Strings = (
      ''
      #268#225'stka'
      'VS'
      'SS'
      #268'. '#250#269'tu'
      'Text'
      'Datum'
      'pozn.'
      '')
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
    FixedColWidth = 67
    FixedRowHeight = 20
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
    SortSettings.DefaultFormat = ssAutomatic
    Version = '7.4.2.0'
    ColWidths = (
      67
      82
      78
      22
      132
      135
      64
      167)
  end
  object pnBottom: TPanel
    Left = 0
    Top = 1008
    Width = 1452
    Height = 146
    Align = alBottom
    TabOrder = 1
    object lblNalezeneDoklady: TLabel
      Left = 10
      Top = 6
      Width = 102
      Height = 13
      Caption = 'Doklady podle VS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object asgNalezeneDoklady: TAdvStringGrid
      Left = -1
      Top = 24
      Width = 812
      Height = 105
      Cursor = crDefault
      ColCount = 9
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 7
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      HoverRowCells = [hcNormal, hcSelected]
      OnGetAlignment = asgNalezeneDokladyGetAlignment
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      ColumnHeaders.Strings = (
        #268#237'slo dokladu'
        'Datum'
        'Firma'
        'P'#345'edpis'
        'Zaplaceno'
        'Dobropis.'
        'Nezaplaceno'
        'ID Dokladu')
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
      FixedColWidth = 89
      FixedRowHeight = 20
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
      SortSettings.DefaultFormat = ssAutomatic
      Version = '7.4.2.0'
      ColWidths = (
        89
        69
        158
        66
        65
        65
        78
        74
        110)
    end
    object chbVsechnyDoklady: TCheckBox
      Left = 254
      Top = 4
      Width = 103
      Height = 17
      Caption = 'v'#353'echny doklady'
      TabOrder = 1
      OnClick = chbVsechnyDokladyClick
    end
  end
  object pnRight: TPanel
    Left = 979
    Top = 0
    Width = 473
    Height = 1008
    Align = alRight
    TabOrder = 2
    object lblPrechoziPlatbyZUctu: TLabel
      Left = 9
      Top = 10
      Width = 129
      Height = 13
      Caption = 'P'#345'echoz'#237' platby z '#250#269'tu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbPocetPlateb: TLabel
      Left = 333
      Top = 8
      Width = 60
      Height = 13
      Caption = 'Po'#269'et plateb'
    end
    object lblPrechoziPlatbySVs: TLabel
      Left = 5
      Top = 217
      Width = 120
      Height = 13
      Caption = 'P'#345'echoz'#237' platby s VS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Memo1: TMemo
      Left = 6
      Top = 406
      Width = 435
      Height = 27
      TabOrder = 0
    end
    object asgPredchoziPlatby: TAdvStringGrid
      Left = 4
      Top = 28
      Width = 417
      Height = 183
      Cursor = crDefault
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 8
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 1
      HoverRowCells = [hcNormal, hcSelected]
      OnGetAlignment = asgPredchoziPlatbyGetAlignment
      OnButtonClick = asgPredchoziPlatbyButtonClick
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      ColumnHeaders.Strings = (
        ''
        'VS'
        #268'astka'
        'Datum'
        'Firma')
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
      FixedColWidth = 28
      FixedRowHeight = 20
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
      SortSettings.DefaultFormat = ssAutomatic
      Version = '7.4.2.0'
      ColWidths = (
        28
        72
        81
        64
        161)
    end
    object asgPredchoziPlatbyVs: TAdvStringGrid
      Left = 5
      Top = 233
      Width = 444
      Height = 169
      Cursor = crDefault
      ColCount = 4
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 8
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 2
      HoverRowCells = [hcNormal, hcSelected]
      OnGetAlignment = asgPredchoziPlatbyVsGetAlignment
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      ColumnHeaders.Strings = (
        'Bank. '#250#269'et'
        #268'astka'
        'Datum'
        'Firma')
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
      FixedColWidth = 137
      FixedRowHeight = 20
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
      SortSettings.DefaultFormat = ssAutomatic
      Version = '7.4.2.0'
      ColWidths = (
        137
        82
        65
        150)
    end
    object editPocetPredchPlateb: TEdit
      Left = 402
      Top = 5
      Width = 13
      Height = 21
      TabOrder = 3
      Text = '7'
    end
    object Memo2: TMemo
      Left = 13
      Top = 448
      Width = 436
      Height = 665
      Lines.Strings = (
        'Memo2')
      TabOrder = 4
    end
  end
  object pnLeft: TPanel
    Left = 0
    Top = 0
    Width = 109
    Height = 1008
    Align = alLeft
    TabOrder = 3
    object lbZobrazit: TLabel
      Left = 8
      Top = 96
      Width = 38
      Height = 13
      Caption = 'Zobrazit'
    end
    object Label1: TLabel
      Left = 8
      Top = 616
      Width = 74
      Height = 13
      Caption = 'ID radku vypisu'
    end
    object Label2: TLabel
      Left = 8
      Top = 664
      Width = 52
      Height = 13
      Caption = 'ID dokladu'
    end
    object btnNacti: TButton
      Left = 22
      Top = 18
      Width = 65
      Height = 21
      Caption = '&Na'#269'ti GPC'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnNactiClick
    end
    object btnZapisDoAbry: TButton
      Left = 22
      Top = 188
      Width = 65
      Height = 21
      Caption = '&Do Abry'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnZapisDoAbryClick
    end
    object editVstupniSoubor: TEdit
      Left = 22
      Top = 388
      Width = 73
      Height = 21
      TabOrder = 2
      Text = 'vypis_t5.gpc'
    end
    object btnSparujPlatby: TButton
      Left = 12
      Top = 338
      Width = 75
      Height = 17
      Caption = 'Sp'#225'ruj platby'
      TabOrder = 3
      OnClick = btnSparujPlatbyClick
    end
    object btnReconnect: TButton
      Left = 24
      Top = 306
      Width = 65
      Height = 25
      Caption = 'Reconnect'
      TabOrder = 4
      OnClick = btnReconnectClick
    end
    object Button2: TButton
      Left = 6
      Top = 362
      Width = 97
      Height = 17
      Caption = 'Uka'#382' sp'#225'rov'#225'n'#237
      TabOrder = 5
      OnClick = Button2Click
    end
    object chbZobrazitBezproblemove: TCheckBox
      Left = 8
      Top = 118
      Width = 93
      Height = 17
      Caption = 'bezprobl'#233'mov'#233
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = chbZobrazitBezproblemoveClick
    end
    object chbZobrazitDebety: TCheckBox
      Left = 8
      Top = 152
      Width = 65
      Height = 17
      Caption = 'debety'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = chbZobrazitDebetyClick
    end
    object chbZobrazitStandardni: TCheckBox
      Left = 8
      Top = 134
      Width = 93
      Height = 17
      Caption = 'standardn'#237
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = chbZobrazitStandardniClick
    end
    object btnBold: TButton
      Left = 16
      Top = 248
      Width = 75
      Height = 25
      Caption = 'btnBold'
      TabOrder = 9
    end
    object btnNajdiPNP: TButton
      Left = 8
      Top = 512
      Width = 75
      Height = 25
      Caption = 'Oprav PNP'
      TabOrder = 10
      OnClick = btnNajdiPNPClick
    end
    object btnNactiVypis: TButton
      Left = 8
      Top = 560
      Width = 75
      Height = 25
      Caption = 'NactiPNP'
      TabOrder = 11
      OnClick = btnNactiVypisClick
    end
    object btnNactiRadekVypisu: TButton
      Left = 8
      Top = 704
      Width = 97
      Height = 25
      Caption = 'zm'#283'nRadekVypisu'
      TabOrder = 12
      OnClick = btnNactiRadekVypisuClick
    end
    object Edit1: TEdit
      Left = 8
      Top = 632
      Width = 97
      Height = 21
      TabOrder = 13
      Text = '4MPD000101'
    end
    object Edit2: TEdit
      Left = 8
      Top = 680
      Width = 97
      Height = 21
      TabOrder = 14
      Text = 'GNET000101'
    end
  end
  object asgPNP: TAdvStringGrid
    Left = 112
    Top = 544
    Width = 855
    Height = 457
    Cursor = crDefault
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    ColCount = 10
    Ctl3D = True
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 2
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goColSizing, goEditing]
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 4
    HoverRowCells = [hcNormal, hcSelected]
    OnButtonClick = asgPNPButtonClick
    ActiveCellFont.Charset = DEFAULT_CHARSET
    ActiveCellFont.Color = clWindowText
    ActiveCellFont.Height = -11
    ActiveCellFont.Name = 'MS Sans Serif'
    ActiveCellFont.Style = [fsBold]
    ActiveCellColor = 15387318
    ColumnHeaders.Strings = (
      ' doklad v'#253'pis'
      ' '#269#225'stka'
      ' z'#225'kazn'#237'k'
      ' text'
      ' radek vypisu'
      ' cislo faktury'
      ' id faktury'
      ''
      ' vs faktury')
    ColumnSize.StretchColumn = 0
    ControlLook.FixedGradientFrom = clWhite
    ControlLook.FixedGradientTo = clSilver
    ControlLook.FixedGradientHoverFrom = 13619409
    ControlLook.FixedGradientHoverTo = 12502728
    ControlLook.FixedGradientHoverMirrorFrom = 12502728
    ControlLook.FixedGradientHoverMirrorTo = 11254975
    ControlLook.FixedGradientDownFrom = 8816520
    ControlLook.FixedGradientDownTo = 7568510
    ControlLook.FixedGradientDownMirrorFrom = 7568510
    ControlLook.FixedGradientDownMirrorTo = 6452086
    ControlLook.ControlStyle = csWinXP
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
    EnableHTML = False
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
    FixedColWidth = 86
    FixedRowHeight = 18
    FixedRowAlways = True
    FixedFont.Charset = EASTEUROPE_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'MS Sans Serif'
    FixedFont.Style = []
    FloatFormat = '%.2f'
    HoverButtons.Buttons = <>
    HoverButtons.Position = hbLeftFromColumnLeft
    Look = glTMS
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
    RowHeaders.Strings = (
      ' ')
    ScrollWidth = 16
    SearchFooter.ColorTo = 15790320
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
    SortSettings.DefaultFormat = ssAutomatic
    SortSettings.Column = 0
    SortSettings.Show = True
    VAlignment = vtaCenter
    Version = '7.4.2.0'
    ColWidths = (
      86
      64
      121
      119
      87
      89
      85
      64
      67
      68)
  end
  object dbAbra: TZConnection
    ControlsCodePage = cGET_ACP
    AutoEncodeStrings = False
    Port = 0
    Protocol = 'firebirdd-2.1'
    Left = 158
    Top = 142
  end
  object NactiGpcDialog: TOpenDialog
    Left = 228
    Top = 142
  end
  object qrAbra: TZQuery
    Connection = dbAbra
    Params = <>
    Left = 186
    Top = 142
  end
end
