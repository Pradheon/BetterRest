//
//  ContentView.swift
//  JoshanRai-BetterRest
//
//  Created by Joshan Rai on 2/15/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    init() { // This stuff made with help from: https://stackoverflow.com/questions/56505528/swiftui-update-navigation-bar-title-color
        UITableView.appearance().backgroundColor = .clear
        
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    //@State private var alertTitle = ""
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
                //  Wakeup schedule
                Section {
                    DatePicker("Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .foregroundColor(Color.black)
                } header: {
                    Text("Your Wakeup Time")
                        .font(.headline)
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }.headerProminence(.increased)
                
                //  Desired sleep amount
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .foregroundColor(Color.black)
                } header: {
                    Text("Your Desired Amount of Sleep")
                        .font(.headline)
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }.headerProminence(.increased)
                
                //  Coffee intake amount
                Section {
                    //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    Picker("Coffee Amount (in cups)", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text($0 == 1 ? "1 cup" : "\($0) cups")
                        }
                    }
                    .foregroundColor(Color.black)
                } header: {
                    Text("Your Daily Coffee Intake")
                        .font(.headline)
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }.headerProminence(.increased)
                
                //  Recommended bedtime UI
                Section {
                    Text(calculateBedtime())
                        .foregroundColor(Color.black)
                } header: {
                    Text("Your Ideal Bedtime")
                        .font(.headline)
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }.headerProminence(.increased)
            }
            .navigationTitle("BetterRest")
            .background(
                Image("nightSky")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 3)
            )
            .foregroundColor(.white)
            /*.toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $displayAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }*/
        }
    }
    
    func calculateBedtime() -> String{
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            //alertTitle = "Your ideal bedtime is..."
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            //alertTitle = "Error"
            return "Sorry. Something went wrong on our end." // Error calculating bedtime for user
        }
        
        //displayAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
