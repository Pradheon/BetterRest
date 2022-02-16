//
//  ContentView.swift
//  JoshanRai-BetterRest
//
//  Created by Joshan Rai on 2/15/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var displayAlert = false
    
    static var defaultWakeTime: Date {
        var componenets = DateComponents()
        componenets.hour = 7
        componenets.minute = 0
        return Calendar.current.date(from: componenets) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your Wakup Schedule")
                        .font(.headline)
                    
                    DatePicker("Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your Desired Amount of Sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your Daily Coffee Intake")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? " 1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $displayAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry. Something went wrong on our end." // Error calculating bedtime for user
        }
        
        displayAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
