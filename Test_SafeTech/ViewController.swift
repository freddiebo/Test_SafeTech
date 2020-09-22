//
//  ViewController.swift
//  Test_SafeTech
//
//  Created by  Vladislav Bondarev on 22.09.2020.
//

import UIKit

class ViewController: UIViewController {

    var key: SecKey?
    var cipherTextData: Data?
    @IBOutlet weak var enterText: UITextField!
    @IBOutlet weak var resultLable: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resultText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        key = KeyChainService.loadKey()
        if key == nil {
            do {
                key = try KeyChainService.createKey()
            } catch let error {
                errorLabel.text = error.localizedDescription
            }
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func onEncryptClick(_ sender: Any) {
        guard let publicKey = SecKeyCopyPublicKey(key!) else {
            errorLabel.text = "Error publicKey"
            return
        }
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            errorLabel.text = "Error SecKeyIsAlgorithmSupported"
            return
        }
        
        var error: Unmanaged<CFError>?
        let clearText = enterText.text
        if clearText == "" {
            errorLabel.text = "ERROR! Please enter text for encrypt."
            return
        }
        let plainText = clearText!.data(using: .utf8)!
        cipherTextData = SecKeyCreateEncryptedData(publicKey,
                                                         algorithm,
                                                         plainText as CFData,
                                                         &error) as Data?
        
        guard cipherTextData != nil else {
            errorLabel.text = error?.takeRetainedValue().localizedDescription
            return
        }
        
        resultText.text = cipherTextData?.base64EncodedString()
    }
    
    @IBAction func onDecryptClick(_ sender: Any) {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(self.key!, .decrypt, algorithm) else {
            errorLabel.text = "Error SecKeyIsAlgorithmSupported"
            return
        }
        var error: Unmanaged<CFError>?
        
        let cipherText = enterText.text
        if cipherText == "" {
            errorLabel.text = "ERROR! Please enter text for encrypt."
            return
        }
        
        let cipherTextData = Data(base64Encoded: cipherText!)

        let clearTextData = SecKeyCreateDecryptedData(self.key!,
                                                      algorithm,
                                                      cipherTextData! as CFData,
                                                      &error) as Data?
        
        guard cipherTextData != nil else {
            errorLabel.text = error?.takeRetainedValue().localizedDescription
            return
        }
        
        let clearText = String(decoding: clearTextData!, as: UTF8.self)
        resultText.text = clearText
    }    
}
