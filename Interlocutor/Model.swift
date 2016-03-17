//
//  Model.swift
//  Interlocutor
//
//  Created by Paul Agron on 3/16/16.
//  Copyright © 2016 Paul Agron. All rights reserved.
//

import Foundation
import Cocoa

enum OrdinalType : String {
  case Boolean
  case Integer
  case FloatingPt = "Float"
  case String
  
  static let all:Set<OrdinalType> = [.Boolean, .Integer, .FloatingPt, .String]
}

enum LanguageType {
  case Ordinal(OrdinalType)
  case Undefined(String)
  case Defined(Node)
}


class Arrow {
  var key:String
  var kind:FieldKind
  var target:LanguageType
  
  init(def:FieldDef) {
    key = def.key
    kind = def.kind
    
    if let t = OrdinalType(rawValue: def.value) {
      target = .Ordinal(t)
    } else {
      target = .Undefined(def.value)
    }
  }
}

class Node {
  var name:String
  var arrows:[Arrow]
  
  init(_ def:TypeDef) {
    name = def.name
    arrows = def.fields.map(Arrow.init)
  }
}

class Model {
  var nodes:[String:Node] = [:]
  init(_ defs:[TypeDef]) {
    let ordinalTypeNames:Set<String> = Set(OrdinalType.all.map{$0.rawValue})
    for d in defs where !ordinalTypeNames.contains(d.name) {
      nodes[d.name] = Node(d)
    }
    
    for (_,n) in nodes {
      for arrow in n.arrows {
        if case .Undefined(let typeName) = arrow.target {
          if let targetNode = nodes[typeName] {
            arrow.target = .Defined(targetNode)
          } else {
            print("Unknown user defined type \(typeName)")
          }
        }
      }
    }
  }
  
  
  func coloredBoldString(string:String, color:NSColor)->NSAttributedString {
    let fontName = "Courier-Bold"
    // HelveticaNeue-Bold
    let font:NSFont = NSFont(name: fontName, size: 14)!
    let attributes = [
      NSForegroundColorAttributeName : color,
      NSFontAttributeName : font
    ]
    
    return NSAttributedString(string: string, attributes: attributes)
  }
  
  func coloredString(string:String, color:NSColor)->NSAttributedString {
    let font:NSFont = NSFont(name: "Courier", size: 14)!
    let attributes = [
      NSForegroundColorAttributeName : color,
      NSFontAttributeName : font
    ]
    
    return NSAttributedString(string: string, attributes: attributes)
  }
  
  
  func plain(string:String)->NSAttributedString {
    return coloredString(string, color: NSColor.blackColor())
  }
  
  func bold(string:String)->NSAttributedString {
    return coloredBoldString(string, color: NSColor.blackColor())
  }
  
  
  func asAttributedString()->NSAttributedString {
    let eol = "\n"
    let res = NSMutableAttributedString()
    
    func show(a:NSAttributedString) {
      res.appendAttributedString(a)
    }
    
    for (_,n) in nodes {
      show(bold(n.name))
      res.appendAttributedString(plain(eol))
      for arrow in n.arrows {
        show(plain("   \(arrow.key) "))
        show(coloredString("\(arrow.kind.arrowPic) ", color:NSColor.blueColor()))
        
        switch arrow.target {
        case .Undefined(let s):
          show(coloredBoldString(s, color:NSColor.redColor()))
        case .Defined(let targetNode):
          show(bold(targetNode.name))
        case .Ordinal(let ordinal):
          show(coloredBoldString(ordinal.rawValue, color:NSColor.blueColor()))
        }
        
        show(plain(eol))
      }
      show(plain(eol))
    }

    return res
  }
  
}

