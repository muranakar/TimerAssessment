//
//  EditFIMTableViewCell.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/29.
//

import UIKit

final class EditFIMTableViewCell: UITableViewCell {
    @IBOutlet weak private var label: UILabel!
    @IBOutlet weak private var textField: UITextField! {
        didSet {
            textField.inputView = pickerView
        }
    }

    let pickerView = UIPickerView()
    private let fimNumber = [Int](1...7)

    private var updateFIMNumHandler: (_ element: Int) -> Void = { _  in }

    required init?(coder: NSCoder) {
         super.init(coder: coder)
         pickerView.delegate = self
         pickerView.dataSource = self
     }

    func configue(labelText: String, textFieldText: String, updateFIMNumHandler: @escaping(Int) -> Void) {
        label.text = labelText
        textField.text = textFieldText
        self.updateFIMNumHandler = updateFIMNumHandler
    }
}

extension EditFIMTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView {
            textField.text = fimNumber.map { String($0) }[row]
            updateFIMNumHandler(fimNumber[row])
        }

        textField.resignFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        fimNumber.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let string = fimNumber.map { String($0) }[row]
        return string
    }
}
