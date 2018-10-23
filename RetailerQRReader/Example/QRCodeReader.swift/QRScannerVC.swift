/*
 * QRCodeReader.swift
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import AVFoundation
import UIKit

class QRScannerViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = retailerToken
        print("Inside QRScannerVC, retailerToken: \(retailerToken)")
    }
  @IBOutlet weak var previewView: QRCodeReaderView! {
    didSet {
      previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
    }
  }
  lazy var reader: QRCodeReader = QRCodeReader()
  lazy var readerVC: QRCodeReaderViewController = {
    let builder = QRCodeReaderViewControllerBuilder {
      $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
      $0.showTorchButton         = true
      $0.preferredStatusBarStyle = .lightContent
      
      $0.reader.stopScanningWhenCodeIsFound = false
    }
    
    return QRCodeReaderViewController(builder: builder)
  }()

  // MARK: - Actions

  private func checkScanPermissions() -> Bool {
    do {
      return try QRCodeReader.supportsMetadataObjectTypes()
    } catch let error as NSError {
      let alert: UIAlertController

      switch error.code {
      case -11852:
        alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
          DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.openURL(settingsURL)
            }
          }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      default:
        alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      }

      present(alert, animated: true, completion: nil)

      return false
    }
  }

  @IBAction func scanInModalAction(_ sender: AnyObject) {
    guard checkScanPermissions() else { return }

    readerVC.modalPresentationStyle = .formSheet
    readerVC.delegate               = self

    readerVC.completionBlock = { (result: QRCodeReaderResult?) in
      if let result = result {
        print("Completion with result: \(result.value) of type \(result.metadataType)")
      }
    }

    present(readerVC, animated: true, completion: nil)
  }

  @IBAction func scanInPreviewAction(_ sender: Any) {
    guard checkScanPermissions(), !reader.isRunning else { return }

    reader.didFindCode = { result in
      print("Completion with result: \(result.value) of type \(result.metadataType)")
    }

    reader.startScanning()
  }
    
    // see: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

  // MARK: - QRCodeReader Delegate Methods

  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()
    
    struct ProcessCouponRequest: Encodable {
        var shopperID: Int
        var shopperToCouponID: Int
    }
    
    struct ProcessCouponResponse: Decodable {
        var id: Int
        var shopperID: Int
        var couponID: Int
        var timesProcessed: Int
    }
    
//    print("QR Scanner value: \(result.value)")
//    return

    let s = result.value
    let matched = matches(for: "[0-9]+", in: s)
    print(matched)
    
    var processCouponRequest: ProcessCouponRequest
    if matched.count == 2 {
        processCouponRequest = ProcessCouponRequest(shopperID: Int(matched[0]) ?? -1, shopperToCouponID: Int(matched[1]) ?? -1)
    } else {
        print("Error matching regex for shopperID and shopperToCouponID integers.")
        return
    }
    guard let uploadData = try? JSONEncoder().encode(processCouponRequest) else {
        return
    }
    
    let loginUrl = URL(string: "http://b795f5fb.ngrok.io/processCoupon")!
    //                    let loginUrl = URL(string: "http://localhost:8080/retailerLogin")!
    
    var request = URLRequest(url: loginUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(retailerToken)", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse
            //                            , (200...299).contains(response.statusCode)
            else {
                print("server error")
                return
        }
        
        var dataString = ""
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            dataString = String(data: data, encoding: .utf8) ?? ""
        }
        
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let processCouponResponse = try jsonDecoder.decode(ProcessCouponResponse.self, from: data)
                print("timesProcessed: \(processCouponResponse.timesProcessed)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { [weak self] in
                        let alert = UIAlertController(
                            title: "Coupon Processed!",
                            message: dataString,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Error decoding ProcessCouponResponse, actual response was: \(dataString)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { [weak self] in
                        let alert = UIAlertController(
                            title: "Error: Invalid QR Code",
                            message: dataString,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    task.resume()
    

//    dismiss(animated: true) { [weak self] in
//      let alert = UIAlertController(
//        title: "QRCodeReader",
//        message: String (format:"%@ (of type %@)", result.value, result.metadataType),
//        preferredStyle: .alert
//      )
//      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//
//      self?.present(alert, animated: true, completion: nil)
//    }
  }

  func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
  }

  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    reader.stopScanning()

    dismiss(animated: true, completion: nil)
  }
}