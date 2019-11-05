//
//  ViewController.swift
//  DHJsonToModel
//
//  Created by 候东辉 on 2019/9/23.
//  Copyright © 2019 候东辉. All rights reserved.
//

import Cocoa

enum CodeType {
    case CodeTypeForString,
    CodeTypeForBool,
    CodeTypeForInt,
    CodeTypeForDouble,
    CodeTypeForAny,
    CodeTypeForArray,
    CodeTypeForDictionary
}

class ViewController: NSViewController, NSTextFieldDelegate {
    
    static let tool : Tools = Tools()
    
    @IBOutlet weak var jsonField: NSTextField!
    @IBOutlet weak var propertyField: NSTextField!
    @IBOutlet weak var exchangeButton: NSButton!
    @IBOutlet weak var copyButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonField.becomeFirstResponder()
        jsonField.delegate = self
        propertyField.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    // 查看field输入的文字
    func controlTextDidChange(_ obj: Notification) {
        let field = obj.object as! NSTextField;
        if field == self.jsonField {
            let isjson = ViewController.tool.isjsonString(json: field.stringValue)
            self.exchangeButton.isEnabled = isjson
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector.description == "insertNewline:" {
            textView.insertNewlineIgnoringFieldEditor(self)
            return true
        }
        return false
    }
    
    
    // 转换
    @IBAction func exchangedAction(_ sender: NSButton) {
        // 获取粘贴进来的json数据
        let jsonString = self.jsonField.stringValue;
        // 转换成data
        let jsonData = jsonString.data(using: .utf8)
        do {
            // 尝试转化成json
            let json = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            let finishArr = _exchangeCode(data: json)
            // 先清空转换完成的
            propertyField.stringValue = ""
            for property in finishArr {
                propertyField.stringValue = "\(propertyField.stringValue)\n\(property)"
            }
            copyButton.isEnabled = Bool.init(truncating: NSNumber(value: propertyField.stringValue.count))
        } catch {
            self.presentError(error)
        }
    }
    
    // 转换成对应的属性代码
    private func _exchangeCode(data : Any!) -> Array<String> {
        var resArr = Array<String>.init()
        // 判断一下是个什么类型
        if data is Dictionary<String, Any> {
            let dataDict = data as! Dictionary<String, Any>
            _ = dataDict.split { (key, value) -> Bool in
                var type = CodeType.CodeTypeForAny
                if value is String {
                    let stringValue = value as! String
                    if stringValue == "YES" || stringValue == "yes" || stringValue == "NO" || stringValue == "no" || stringValue == "true" || stringValue == "false" || stringValue == "TRUE" || stringValue == "FALSE" {
                        type = .CodeTypeForBool
                    } else {
                        type = .CodeTypeForString
                    }
                } else if value is NSNull {
                    type = .CodeTypeForAny
                } else if value is Int {
                    type = .CodeTypeForInt
                } else if value is Double {
                    type = .CodeTypeForDouble
                } else if value is Bool {
                    type = .CodeTypeForBool
                } else if value is Array<Any> {
                    type = .CodeTypeForArray
                } else if value is Dictionary<String, Any> {
                    type = .CodeTypeForDictionary
                }
                resArr.append(_getCode(type: type, propertyName: key))
                return resArr.count == dataDict.count
            }
        } else if data is Array<Any> {
            let dataArray = data as! Array<Any>
            resArr = _exchangeCode(data: dataArray.first)
        } else {
            print("\(String(describing: data))")
        }
        return resArr
    }
    
    /// 把json转化成代码
    /// - Parameter type: 转化的类型
    /// - Parameter propertyName: 属性名字
    private func _getCode(type : CodeType, propertyName : String) -> String {
        var codeString = ""
        switch type{
        case CodeType.CodeTypeForString:
            var ignoneProperty = propertyName
            if ignoneProperty == "id" {
                ignoneProperty = "ID"
            }
            codeString = "@property (nonatomic, copy) NSString *\(ignoneProperty);"
            break
        case CodeType.CodeTypeForInt:
            codeString = "@property (nonatomic, assign) NSInteger \(propertyName);"
            break
        case CodeType.CodeTypeForDouble:
            codeString = "@property (nonatomic, assign) CGFloat \(propertyName);"
            break
        case CodeType.CodeTypeForBool:
            codeString = "@property (nonatomic, assign) BOOL \(propertyName);"
            break
        case CodeType.CodeTypeForAny:
            codeString = "@property (nonatomic, strong) id \(propertyName);"
            break
        case .CodeTypeForArray:
            codeString = "@property (nonatomic, strong) NSArray *\(propertyName);"
            break
        case .CodeTypeForDictionary:
            codeString = "@property (nonatomic, strong) NSDictionary *\(propertyName);"
            break
        }
        
        return codeString
    }
    
    // 复制
    @IBAction func copyButtonClick(_ sender: NSButton) {
        
        if propertyField.stringValue.count < 1 {
            let alert = NSAlert.init()
            alert.messageText = "字符为空"
            alert.addButton(withTitle: "确定")
            alert.alertStyle = .warning
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
        } else {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            let data = propertyField.stringValue.data(using: .utf8)
            let res = pasteboard.setData(data, forType: .string)
            if !res {
                let alert = NSAlert.init()
                alert.messageText = "复制失败"
                alert.addButton(withTitle: "好吧")
                alert.alertStyle = .warning
                alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
            }
        }
    }
}

