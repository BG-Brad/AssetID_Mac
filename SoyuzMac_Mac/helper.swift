//
//  Helpers.swift
//  Soyuz_Mac
//
//  Created by brad on 7/8/21.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI


let context = CIContext()
let filter = CIFilter.qrCodeGenerator()



class ObservedObjectes : ObservableObject {
    
    @Published var isAuthenticatedUser = false
    @Published var apiToken = "5842d2ddc1165ddc55a44cc60105486ad052a829952ca82d4a8101a5c1845921"

    @Published var showProgressView = false

    @Published var addAsset = false
    @Published var serialNumber = ""
    @Published var deviceUUID = ""
    @Published var checkinDate = ""
    @Published var macQRSerial = ""
    @Published var assetTagBarcode = ""
    @Published var backendAppId = "6EF84867-8ADB-2546-FF2A-5A0750ACF600"
    @Published var backendAPIKey  = "106F8DA9-BA26-4AE6-BA92-4CA94B102A15"
    @Published var refreshView = false
}


struct AssetIDData : Codable, Hashable {
    var serialnumber: String?
    var contactEmail: String?
    var created: Int?
    var assetIDClass: String?
    var deivceModel, ownerID, contactPhone, updated: String?
    var objectID: String?
    var shouldRefresh: Bool?
    
    enum CodingKeys: String, CodingKey {
          case serialnumber, contactEmail, created
          case assetIDClass = "___class"
          case deivceModel = "deivce_model"
          case ownerID = "ownerId"
          case contactPhone, updated
          case objectID = "objectId"
          case shouldRefresh
      }
  }

  typealias AssetID = [AssetIDData]




func getMacSerialNumber() -> String {
    var serialNumber: String? {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
        
        guard platformExpert > 0 else {
            return nil
        }
        
        guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return nil
        }
        
        IOObjectRelease(platformExpert)

        return serialNumber+"qr"
    }
    
    return serialNumber ?? "Unknown"
    

}

func generateQR(serialNumber: String, backgroundColor: CIColor, foregroundColor: CIColor) -> NSImage {
  var nsImage:NSImage!
  
  // Convert String to Data
  let codeData = serialNumber.data(using: String.Encoding.isoLatin1)
  
  // Create CIFilter object for CIQRCodeGenerator
  guard let qrFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator") else { return nsImage }

  // Set the inputMessage for the codeData
  qrFilter.setValue(codeData, forKey: "inputMessage")
  
  // Create another CIFilter for setting foreground and background color
  guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nsImage }
  colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
  colorFilter.setValue(backgroundColor, forKey: "inputColor1") // Background color
  colorFilter.setValue(foregroundColor, forKey: "inputColor0") // Foreground color
  
  // Create an affine transformation for scaling the generated image
  let transform = CGAffineTransform(scaleX: 10, y: 10)
  if let output = colorFilter.outputImage?.transformed(by: transform) {
    let rep = NSCIImageRep.init(ciImage: output)
    nsImage = NSImage(size: output.extent.size)
    nsImage.addRepresentation(rep)
  }

  // Return the created image
  return nsImage
}

struct windowSize {
let minWidth : CGFloat = 600
let minHeight : CGFloat = 600
let maxWidth : CGFloat = 600
let maxHeight : CGFloat = 600
}

// MARK: - DeviceDetail
struct DeviceDetail : Codable, Hashable {
    var serialnumber: String
    var contactEmail: String?
    var created: Int?
    var deviceDetailClass: String?
    var deivceModel, ownerID, contactPhone, updated: String?
    var deviceOwner: String?
    var objectID: String
    enum CodingKeys: String, CodingKey {
        case serialnumber, contactEmail, created
        case deviceDetailClass = "___class"
        case deivceModel = "deivce_model"
        case ownerID = "ownerId"
        case contactPhone, updated
        case deviceOwner = "device_owner"
        case objectID = "objectId"
    }
}

typealias DeviceDetails = [DeviceDetail]
