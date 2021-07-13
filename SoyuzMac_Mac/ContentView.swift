//
//  ContentView.swift
//  Soyuz_Mac
//
//  Created by brad on 7/8/21.
//

import SwiftUI
import Foundation



struct ContentView: View {
    @State var isDebugMode = false
    @State var assetID = AssetIDData()
    @EnvironmentObject var observedObject : ObservedObjectes
    @State var isComplete = false
    @State var deviceDetails = DeviceDetail(serialnumber: "", contactEmail: "", created: 0, deviceDetailClass: "", deivceModel: "", ownerID: "", contactPhone: "", updated: "", deviceOwner: "", objectID: "")
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    let serialNumber = getMacSerialNumber().dropLast(2)
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                   Image("refresh")
                    .resizable()
                    .frame(width: 32, height:32).onTapGesture {
                        removeAssetTag(objectID: self.deviceDetails.objectID)
                    }
                    Spacer()
                Toggle("Test Mode", isOn: $isDebugMode)
                   
                } .padding()
                Spacer()
                
        VStack {
            Spacer()
              
            if isDebugMode {
               
                VStack {
                  //  Spacer()
                    Text("*** Test Mode ***")
                        Text("Uses a test serial in Mosyle. Ensure iOS companion device is running Production Mode.")
                        .frame(maxWidth: 400, maxHeight: 50)
                    Spacer()
                    Text("") .onReceive(timer) { time in
                        if isComplete == false {
                        checkForAssetID()
                        }
                    }
                    if self.isComplete == false  {
                    Image(nsImage: generateQR(serialNumber: "FVFZW4BDLYWJqr", backgroundColor: .red, foregroundColor: .black))
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 256, height: 256)
                        .aspectRatio(contentMode: .fill)
                        .offset(y: -50)
                    } else if self.isComplete == true  {
                        Text("Serial Number: FVFZW4BDLYWJ")
                            .font(.title)
                           
                        Image(nsImage: generateQR(serialNumber: "FVFZW4BDLYWJqr", backgroundColor: .green, foregroundColor: .black))
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 256, height: 256)
                            .aspectRatio(contentMode: .fill)
                         //   .offset(y: -50)
                            .onAppear() {
                               lookupDevice(serialNumber:"FVFZW4BDLYWJ")
                            }
                        Spacer()
                        Text("Asset Tag: \(self.deviceDetails.objectID)")
                            .font(.title)
                            .offset(y: -50)
                        Text("This will write the asset tag to the LHPS Mosyle instance to serial number FVFZW4BDLYWJ")
                            .font(.footnote)
                        Spacer()
                    }
                }
            } else  {
                
                if self.isComplete == false  {
                Text("Serial Number:   " + getMacSerialNumber().dropLast(2))
                    .font(.largeTitle)
                    Spacer()
                Image(nsImage: generateQR(serialNumber: "\(getMacSerialNumber())", backgroundColor: .red, foregroundColor: .black))
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 256, height: 256)
                    .aspectRatio(contentMode: .fill)
                    .offset(y: -50)
                } else if self.isComplete == true  {
                    Text("Serial Number:   " + getMacSerialNumber().dropLast(2))
                        .font(.title)
                       
                    Image(nsImage: generateQR(serialNumber: "\(getMacSerialNumber())", backgroundColor: .green, foregroundColor: .black))
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 256, height: 256)
                        .aspectRatio(contentMode: .fill)
                     //   .offset(y: -50)
                        .onAppear() {
                           lookupDevice(serialNumber: "\(serialNumber)")
                        }
                    Spacer()
                    Text("Asset Tag: \(self.deviceDetails.objectID)")
                        .font(.title)
                        .offset(y: -50)
                    Spacer()
                }
            }
        } .frame(minWidth: windowSize().minWidth, minHeight: windowSize().minHeight)
            .frame(maxWidth: windowSize().maxWidth, maxHeight: windowSize().maxHeight)
    }
    }
    }
    
    func checkForAssetID() {
        let serialNumber = getMacSerialNumber().dropLast(2)
        
        var request = URLRequest(url: URL(string: "https://api.backendless.com/6EF84867-8ADB-2546-FF2A-5A0750ACF600/106F8DA9-BA26-4AE6-BA92-4CA94B102A15/data/AssetID")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { ( data, _, _) in
            guard let data = data else { return }
            
            let responseString = String(data: data, encoding: .utf8)
            let assetData = try! JSONDecoder().decode(AssetID.self, from: data)
            print("Json: \(responseString)")
          //  print("Data \(responseString!)")
            DispatchQueue.main.async {
             //   lookupDevice(serialNumber: "\(serialNumber)")
                self.assetID = assetData[0]
                if isDebugMode {
                    if responseString!.contains("FVFZW4BDLYWJ") {
                        self.isComplete = true
                    }
                } else
                if responseString!.contains("\(serialNumber)") {
                   
                    self.isComplete = true
                    
                }
              
            }
     
        }.resume()
    }
    
    
    func lookupDevice(serialNumber: String) {
        
        
        print(serialNumber)
        guard let url = URL(string: "https://api.backendless.com/6EF84867-8ADB-2546-FF2A-5A0750ACF600/106F8DA9-BA26-4AE6-BA92-4CA94B102A15/data/AssetID?where=serialnumber%20%3D%20%27\(serialNumber)%27") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(request)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(DeviceDetails.self, from: data)
                    if jsonResponse.isEmpty{
                        print("No Data")
                        self.deviceDetails.objectID = "-"
                    } else {
                        DispatchQueue.main.async {
                            print("json: \(jsonResponse)")
                            self.deviceDetails = jsonResponse[0]
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            
            
        }.resume()
        
         
        
        
    }
    
    func removeAssetTag(objectID: String) {
        
        
        let parameters = "{\n  \"\(objectID)\":7771\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://api.backendless.com/6EF84867-8ADB-2546-FF2A-5A0750ACF600/106F8DA9-BA26-4AE6-BA92-4CA94B102A15/data/AssetID/\(objectID)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
      
            return
          }
          print(String(data: data, encoding: .utf8)!)
   
        }
        
        task.resume()
        self.isComplete = false
        
    }
    
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





/*
 //            guard let data = data else { return }
 //            let responseString = String(data: data, encoding: .utf8)
 //            print(responseString)
 //
 //            let deviceData = try! JSONDecoder().decode(DeviceDetails.self, from: data)
 //            DispatchQueue.main.async {
 //          print(deviceData)
 //                self.deviceDetails = deviceData[0]
 //           //     print(deviceDetails.objectID)
 //            }
 //        }.resume()
         
         
          
 */

/*
 Text("Your serial number is: " + getMacSerialNumber().dropLast(2))
 */
