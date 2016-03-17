//
//  ViewController.swift
//  Interlocutor
//
//  Created by Paul Agron on 3/15/16.
//  Copyright © 2016 Paul Agron. All rights reserved.
//

import Cocoa

let skip = regex("\\s*")
let name = regex("[A-Za-z]+") ~> skip
let obj = const("type") ~> skip
let ocurly = const("{") ~> skip
let ccurly = const("}") ~> skip
let comma = const(",") ~> skip
let collon = const(FieldKind.Optional.definingSeparator) | const(FieldKind.Many.definingSeparator) | const(FieldKind.Plain.definingSeparator)
let pair = name ~>~ collon ~> skip ~>~ name |> FieldDef.make
let objectDef = obj >~ name ~> ocurly ~>~ sepby(pair, sep: comma) ~> skip ~> ccurly |> TypeDef.make


enum FieldKind : String {
  case Plain
  case Optional
  case Many
  
  var definingSeparator:String {
    switch self {
    case .Plain:     return ":"
    case .Optional:  return ":?"
    case .Many:      return "::"
    }
  }
  
  var arrowPic:String {
    switch self {
    case .Plain:       return "⟼"
    case .Many:        return "⟾"
    case .Optional:    return "⟿"
    }
  }
}

struct FieldDef : CustomStringConvertible {
  let key:String
  let kind:FieldKind
  let value:String
  
  var description:String {
    return "\(key)\(kind.arrowPic)\(value)"
  }
  
  static func make(input:((String,String),String))->FieldDef {
    let ((a,k),b) = input
    var kind:FieldKind
    switch k {
    case FieldKind.Optional.definingSeparator : kind = .Optional
    case FieldKind.Many.definingSeparator : kind = .Many
    default: kind = .Plain
    }
    return FieldDef(key: a, kind: kind, value: b)
  }
}

struct TypeDef : CustomStringConvertible {
  let name:String
  let fields:[FieldDef]
  
  var description:String {
    let body = fields.map { "  " + $0.key + " \($0.kind.arrowPic) " + $0.value }.joinWithSeparator("\n")
    return "class \(name) {\n\(body)\n}\n"
  }
  
  static func make(input:(String,[FieldDef]))->TypeDef {
    let (a,b) = input
    return TypeDef(name: a, fields: b)
  }
}


class ViewController: NSViewController {
  @IBOutlet var leftArea:NSTextView!
  @IBOutlet var rightArea:NSTextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let a = "type Jamba { ping : Jamba, fig :: Stick, bam : Float }"
    
    let b = "type Mamba { ping :? Jamba, fig :: Stick, bam : String }"
    
    let c = "type Link { a :? Boolean, b :? Integer, c : Float, d :: Mamba }"

    leftArea.string = [a,b,c].joinWithSeparator("\n")
    // Do any additional setup after loading the view.
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  var model:Model = Model([])
  
  @IBAction func generate(sender:AnyObject!) {

    let pp = many(objectDef)
    let s = leftArea.string ?? ""
    let stream = CharStream(str: s)
    
    if let target = pp.parse(stream) {
      model = Model(target)
    } else {
      print("parse error")
    }
    
    rightArea.string = ""
    rightArea.textStorage?.appendAttributedString(model.asAttributedString())
    
//    func convert()->String {
//      if let t:[TypeDef] = target {
//        let tmp = t.map { String($0) }
//        return tmp.joinWithSeparator("\n\n")
//      }
//    
//      return "???"
//    }
//    
//    rightArea.string = convert()
  }


}

