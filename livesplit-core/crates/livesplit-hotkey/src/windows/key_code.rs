use std::str::FromStr;

#[repr(u8)]
#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone, serde::Serialize, serde::Deserialize)]
pub enum KeyCode {
    LButton = 0x01,
    RButton = 0x02,
    Cancel = 0x03,
    MButton = 0x04,
    XButton1 = 0x05,
    XButton2 = 0x06,
    Back = 0x08,
    Tab = 0x09,
    Clear = 0x0C,
    Return = 0x0D,
    Shift = 0x10,
    Control = 0x11,
    Menu = 0x12,
    Pause = 0x13,
    Capital = 0x14,
    Kana = 0x15,
    Junja = 0x17,
    Final = 0x18,
    Kanji = 0x19,
    Escape = 0x1B,
    Convert = 0x1C,
    NonConvert = 0x1D,
    Accept = 0x1E,
    ModeChange = 0x1F,
    Space = 0x20,
    Prior = 0x21,
    Next = 0x22,
    End = 0x23,
    Home = 0x24,
    Left = 0x25,
    Up = 0x26,
    Right = 0x27,
    Down = 0x28,
    Select = 0x29,
    Print = 0x2A,
    Execute = 0x2B,
    Snapshot = 0x2C,
    Insert = 0x2D,
    Delete = 0x2E,
    Help = 0x2F,
    D0 = 0x30,
    D1 = 0x31,
    D2 = 0x32,
    D3 = 0x33,
    D4 = 0x34,
    D5 = 0x35,
    D6 = 0x36,
    D7 = 0x37,
    D8 = 0x38,
    D9 = 0x39,
    A = 0x41,
    B = 0x42,
    C = 0x43,
    D = 0x44,
    E = 0x45,
    F = 0x46,
    G = 0x47,
    H = 0x48,
    I = 0x49,
    J = 0x4A,
    K = 0x4B,
    L = 0x4C,
    M = 0x4D,
    N = 0x4E,
    O = 0x4F,
    P = 0x50,
    Q = 0x51,
    R = 0x52,
    S = 0x53,
    T = 0x54,
    U = 0x55,
    V = 0x56,
    W = 0x57,
    X = 0x58,
    Y = 0x59,
    Z = 0x5A,
    LeftWin = 0x5B,
    RightWin = 0x5C,
    Apps = 0x5D,
    Sleep = 0x5F,
    NumPad0 = 0x60,
    NumPad1 = 0x61,
    NumPad2 = 0x62,
    NumPad3 = 0x63,
    NumPad4 = 0x64,
    NumPad5 = 0x65,
    NumPad6 = 0x66,
    NumPad7 = 0x67,
    NumPad8 = 0x68,
    NumPad9 = 0x69,
    Multiply = 0x6A,
    Add = 0x6B,
    Separator = 0x6C,
    Subtract = 0x6D,
    Decimal = 0x6E,
    Divide = 0x6F,
    F1 = 0x70,
    F2 = 0x71,
    F3 = 0x72,
    F4 = 0x73,
    F5 = 0x74,
    F6 = 0x75,
    F7 = 0x76,
    F8 = 0x77,
    F9 = 0x78,
    F10 = 0x79,
    F11 = 0x7A,
    F12 = 0x7B,
    F13 = 0x7C,
    F14 = 0x7D,
    F15 = 0x7E,
    F16 = 0x7F,
    F17 = 0x80,
    F18 = 0x81,
    F19 = 0x82,
    F20 = 0x83,
    F21 = 0x84,
    F22 = 0x85,
    F23 = 0x86,
    F24 = 0x87,
    NumLock = 0x90,
    Scroll = 0x91,
    LeftShift = 0xA0,
    RightShift = 0xA1,
    LeftControl = 0xA2,
    RightControl = 0xA3,
    LeftMenu = 0xA4,
    RightMenu = 0xA5,
    BrowserBack = 0xA6,
    BrowserForward = 0xA7,
    BrowserRefresh = 0xA8,
    BrowserStop = 0xA9,
    BrowserSearch = 0xAA,
    BrowserFavorites = 0xAB,
    BrowserHome = 0xAC,
    VolumeMute = 0xAD,
    VolumeDown = 0xAE,
    VolumeUp = 0xAF,
    MediaNextTrack = 0xB0,
    MediaPrevTrack = 0xB1,
    MediaStop = 0xB2,
    MediaPlayPause = 0xB3,
    LaunchMail = 0xB4,
    LaunchMediaSelect = 0xB5,
    LaunchApp1 = 0xB6,
    LaunchApp2 = 0xB7,
    Oem1 = 0xBA,
    OemPlus = 0xBB,
    OemComma = 0xBC,
    OemMinus = 0xBD,
    OemPeriod = 0xBE,
    Oem2 = 0xBF,
    Oem3 = 0xC0,
    Oem4 = 0xDB,
    Oem5 = 0xDC,
    Oem6 = 0xDD,
    Oem7 = 0xDE,
    Oem8 = 0xDF,
    Oem102 = 0xE2,
    ProcessKey = 0xE5,
    Packet = 0xE7,
    Attn = 0xF6,
    CrSel = 0xF7,
    ExSel = 0xF8,
    ErEof = 0xF9,
    Play = 0xFA,
    Zoom = 0xFB,
    NoName = 0xFC,
    Pa1 = 0xFD,
    OemClear = 0xFE,
}

impl FromStr for KeyCode {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        use self::KeyCode::*;
        Ok(match s {
            "LButton" => LButton,
            "RButton" => RButton,
            "Cancel" => Cancel,
            "MButton" => MButton,
            "XButton1" => XButton1,
            "XButton2" => XButton2,
            "Back" => Back,
            "Tab" => Tab,
            "Clear" => Clear,
            "Return" => Return,
            "Shift" => Shift,
            "Control" => Control,
            "Menu" => Menu,
            "Pause" => Pause,
            "Capital" => Capital,
            "Kana" => Kana,
            "Junja" => Junja,
            "Final" => Final,
            "Kanji" => Kanji,
            "Escape" => Escape,
            "Convert" => Convert,
            "NonConvert" => NonConvert,
            "Accept" => Accept,
            "ModeChange" => ModeChange,
            "Space" => Space,
            "Prior" => Prior,
            "Next" => Next,
            "End" => End,
            "Home" => Home,
            "Left" => Left,
            "Up" => Up,
            "Right" => Right,
            "Down" => Down,
            "Select" => Select,
            "Print" => Print,
            "Execute" => Execute,
            "Snapshot" => Snapshot,
            "Insert" => Insert,
            "Delete" => Delete,
            "Help" => Help,
            "D0" => D0,
            "D1" => D1,
            "D2" => D2,
            "D3" => D3,
            "D4" => D4,
            "D5" => D5,
            "D6" => D6,
            "D7" => D7,
            "D8" => D8,
            "D9" => D9,
            "A" => A,
            "B" => B,
            "C" => C,
            "D" => D,
            "E" => E,
            "F" => F,
            "G" => G,
            "H" => H,
            "I" => I,
            "J" => J,
            "K" => K,
            "L" => L,
            "M" => M,
            "N" => N,
            "O" => O,
            "P" => P,
            "Q" => Q,
            "R" => R,
            "S" => S,
            "T" => T,
            "U" => U,
            "V" => V,
            "W" => W,
            "X" => X,
            "Y" => Y,
            "Z" => Z,
            "LeftWin" => LeftWin,
            "RightWin" => RightWin,
            "Apps" => Apps,
            "Sleep" => Sleep,
            "NumPad0" => NumPad0,
            "NumPad1" => NumPad1,
            "NumPad2" => NumPad2,
            "NumPad3" => NumPad3,
            "NumPad4" => NumPad4,
            "NumPad5" => NumPad5,
            "NumPad6" => NumPad6,
            "NumPad7" => NumPad7,
            "NumPad8" => NumPad8,
            "NumPad9" => NumPad9,
            "Multiply" => Multiply,
            "Add" => Add,
            "Separator" => Separator,
            "Subtract" => Subtract,
            "Decimal" => Decimal,
            "Divide" => Divide,
            "F1" => F1,
            "F2" => F2,
            "F3" => F3,
            "F4" => F4,
            "F5" => F5,
            "F6" => F6,
            "F7" => F7,
            "F8" => F8,
            "F9" => F9,
            "F10" => F10,
            "F11" => F11,
            "F12" => F12,
            "F13" => F13,
            "F14" => F14,
            "F15" => F15,
            "F16" => F16,
            "F17" => F17,
            "F18" => F18,
            "F19" => F19,
            "F20" => F20,
            "F21" => F21,
            "F22" => F22,
            "F23" => F23,
            "F24" => F24,
            "NumLock" => NumLock,
            "Scroll" => Scroll,
            "LeftShift" => LeftShift,
            "RightShift" => RightShift,
            "LeftControl" => LeftControl,
            "RightControl" => RightControl,
            "LeftMenu" => LeftMenu,
            "RightMenu" => RightMenu,
            "BrowserBack" => BrowserBack,
            "BrowserForward" => BrowserForward,
            "BrowserRefresh" => BrowserRefresh,
            "BrowserStop" => BrowserStop,
            "BrowserSearch" => BrowserSearch,
            "BrowserFavorites" => BrowserFavorites,
            "BrowserHome" => BrowserHome,
            "VolumeMute" => VolumeMute,
            "VolumeDown" => VolumeDown,
            "VolumeUp" => VolumeUp,
            "MediaNextTrack" => MediaNextTrack,
            "MediaPrevTrack" => MediaPrevTrack,
            "MediaStop" => MediaStop,
            "MediaPlayPause" => MediaPlayPause,
            "LaunchMail" => LaunchMail,
            "LaunchMediaSelect" => LaunchMediaSelect,
            "LaunchApp1" => LaunchApp1,
            "LaunchApp2" => LaunchApp2,
            "Oem1" => Oem1,
            "OemPlus" => OemPlus,
            "OemComma" => OemComma,
            "OemMinus" => OemMinus,
            "OemPeriod" => OemPeriod,
            "Oem2" => Oem2,
            "Oem3" => Oem3,
            "Oem4" => Oem4,
            "Oem5" => Oem5,
            "Oem6" => Oem6,
            "Oem7" => Oem7,
            "Oem8" => Oem8,
            "Oem102" => Oem102,
            "ProcessKey" => ProcessKey,
            "Packet" => Packet,
            "Attn" => Attn,
            "CrSel" => CrSel,
            "ExSel" => ExSel,
            "ErEof" => ErEof,
            "Play" => Play,
            "Zoom" => Zoom,
            "NoName" => NoName,
            "Pa1" => Pa1,
            "OemClear" => OemClear,
            _ => return Err(()),
        })
    }
}
