#  Programming Notes

This document is a list of general guidelines for working on Splitter.


## SF Symbols
- Use of SF Symbols is encouraged, but remember that macOS ≤ 10.15 doesn't support it, so there needs to be a fallback for that operating system
- When using a new SF Symbol, always check if the symbol name changed in a previous version, and fall back to it if necessary. 
	- DON'T force-unwrap an SF Symbol unless you're sure that the symbol name is the same on all supported versions of macOS
	- For example, `line.3.horizontal` was `line.horizontal.3` in macOS Big Sur. Since I had used the name `line.3.horizontal` force-unwrapped, the app would crash on Big Sur. (commit 69abc858dc6393a01e61b6732837258e17aec43c)
