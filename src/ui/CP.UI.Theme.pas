unit CP.UI.Theme;

interface

uses
  Vcl.Graphics;

const
  // Brand & Accent (from theme.py)
  COLOR_ACCENT         = $1ED953; // #D9531E (Safety Orange in BGR: $1E, $53, $D9)
  COLOR_ACCENT_HOVER   = $0CC241; // #C2410C
  COLOR_ACCENT_LIGHT   = $EDF7FF; // #FFF7ED
  COLOR_ACCENT_BORDER  = $74BAFD; // #FDBA74

  // Neutral & Surfaces
  COLOR_CHARCOAL       = $1B1818; // #18181B
  COLOR_CHARCOAL_HOVER = $2A2727; // #27272A
  COLOR_BG             = $F7F5F4; // #F4F5F7
  COLOR_PANEL          = $FFFFFF; // #FFFFFF
  COLOR_PANEL_ALT      = $FCFAF8; // #F8FAFC
  COLOR_BORDER         = $F0E8E2; // #E2E8F0
  COLOR_BORDER_STRONG  = $E1D5CB; // #CBD5E1

  // Typography Colors
  COLOR_TEXT_PRIMARY   = $1B1818; // #18181B
  COLOR_TEXT_MUTED     = $5B5252; // #52525B
  COLOR_TEXT_HINT      = $7A7171; // #71717A
  COLOR_TEXT_ON_DARK   = $FCFAF8; // #F8FAFC

  // Status Indicators
  COLOR_SUCCESS        = $4AA316; // #16A34A
  COLOR_SUCCESS_BG     = $F5FDEC; // #ECFDF5
  COLOR_WARNING        = $0677D9; // #D97706
  COLOR_WARNING_BG     = $EBFBFF; // #FFFBEB
  COLOR_ERROR          = $2626DC; // #DC2626
  COLOR_ERROR_BG       = $F2F2FE; // #FEF2F2

  FONT_FAMILY          = 'Segoe UI';

implementation

end.
