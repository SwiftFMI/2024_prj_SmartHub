//
//  ConsumtionChartView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 20.02.24.
//

import SwiftUI
import Charts

struct ConsumptionData: Identifiable {
    var id = UUID().uuidString
    var dayOfTheWeek: String
    var consumptionInWaths: Int
}

var data: [ConsumptionData] = [
    ConsumptionData(dayOfTheWeek:"Mon", consumptionInWaths:1),
    ConsumptionData(dayOfTheWeek:"Tue", consumptionInWaths:5),
    ConsumptionData(dayOfTheWeek:"Wed", consumptionInWaths:4),
    ConsumptionData(dayOfTheWeek:"Thu", consumptionInWaths:6),
    ConsumptionData(dayOfTheWeek:"Fri", consumptionInWaths:3),
    ConsumptionData(dayOfTheWeek:"Sat", consumptionInWaths:2),
    ConsumptionData(dayOfTheWeek:"Sun", consumptionInWaths:5)
]

struct ConsumtionChartView: View {
    @Binding var isPresented: Bool
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0)]),startPoint: .top, endPoint: .bottom)

    let averageConsumption = (data.reduce(0) { $0 + $1.consumptionInWaths }) / data.count
    
    var body: some View {
        VStack{
            Text("Device Consumption")
                .font(.title)
            Spacer()
            Chart {
                ForEach(data) { device in
                    LineMark(
                        x: .value("Day", device.dayOfTheWeek),
                        y: .value("Consumption", device.consumptionInWaths)
                    ).interpolationMethod(.catmullRom)
                }
                .interpolationMethod(.cardinal)
                .symbol(by: .value("Device", "Wats consumption"))
                
                RuleMark(y: .value("Average", averageConsumption))
                    .annotation(position: .bottom,
                                alignment: .bottomLeading) {
                        Text("average \(averageConsumption) wats")
                            .foregroundColor(.accentColor)
                    }
                
                ForEach(data) { device in
                    AreaMark(
                        x: .value("Day", device.dayOfTheWeek),
                        y: .value("Consumption", device.consumptionInWaths)
                    ).interpolationMethod(.catmullRom)
                }
                .foregroundStyle(linearGradient)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding()
            
            Spacer()
            Button("Cancel") {
                // Dismiss the sheet
                isPresented = false
            }
            .padding()
        }
        .padding()
    }
}


//#Preview {
//    ConsumtionChartView()
//}
