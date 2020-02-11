//
//  GlobalKeybindPrefs.swift
//  Splitter
//
//  Created by Michael Berk on 1/13/20.
//  Uses code from https://dev.to/mitchartemis/creating-a-global-configurable-shortcut-for-macos-apps-in-swift-25e9
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation

class GlobalKeybindPreferences: Codable, CustomStringConvertible {
//    let function : Bool
    let control : Bool
    let command : Bool
    let shift : Bool
    let option : Bool
    let capsLock : Bool
    let carbonFlags : UInt32
    let characters : String?
    let keyCode : UInt32

	init (control: Bool, command: Bool, shift: Bool, option: Bool, capsLock: Bool, carbonFlags: UInt32, characters: String?, keyCode: UInt32) {
		self.control = control
		self.command = command
		self.shift = shift
		self.option = option
		self.capsLock = capsLock
		self.carbonFlags = carbonFlags
		self.characters = characters
		self.keyCode = keyCode
	}
	
    var description: String {
		
		//the reason why I have to make a copy of self.function is explained later on
//		var function = self.function
		
		
		
        var stringBuilder = ""
        
        if self.control {
			stringBuilder += modifierChars.control.rawValue
        }
        if self.option {
			stringBuilder += modifierChars.option.rawValue
        }
		if self.shift {
		   stringBuilder += modifierChars.shift.rawValue
	    }
        if self.command {
			stringBuilder += modifierChars.command.rawValue
        }
       
        if self.capsLock {
            stringBuilder += "⇪"
        }

		
		
		
		
        if var characters = self.characters {
			print(characters)
			let intKC = Int(keyCode)
			switch intKC {
			case 36:
				characters = "⏎"
			case 48:
				characters = "⇥"
			case 49:
				characters = "␣"
//				function = false
			case 51:
				characters = "⌫"
			case 115:
				characters = "↖"
			case 116:
				characters = "⇞"
			case 117:
				characters = "⌦"
//				function = false
			case 119:
				characters = "↘"
			case 121:
				characters = "⇟"
				
			//For some reason, when pressing an arrow key, it thinks that fn is being pressed, so we correct it. It's actually not possible to do fn+[arrow key] because it turns into one of the pgUp/pgDown/home/end keys listed above, so this shouldn't cause false positives.
			case 123:
				characters = "←"
//				function = false
			case 124:
				characters = "→"
//				function = false
			case 125:
				characters = "↓"
//				function = false
			case 126:
				characters = "↑"
//				function = false
			default: break
			}
			
            stringBuilder += characters.uppercased()

        }
		
//		if function {
//			stringBuilder = "Fn" + stringBuilder
//        }
        return "\(stringBuilder)"
    }
}

enum modifierChars: String {
	case command = "⌘"
	case option = "⌥"
	case control = "⌃"
	case shift = "⇧"
}
