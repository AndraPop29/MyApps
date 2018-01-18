//
//  TouristAttractionStatisticsViewController.swift
//  explore-ios
//
//  Created by Andra on 15/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit
import Charts
class TouristAttractionStatisticsViewController: UIViewController {
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var pieView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDataManager.shared.calculateRatingAverage().then {
            attr -> Void in
            self.setChart(attractions: attr)
            }.catch {
                error in
                print(error)
        }
    }
    
  
    func setChart(attractions: [TouristAttraction]) {
        
        let chart = PieChartView(frame: self.pieView.frame)
        // 2. generate chart data entries
       
        let attractions = attractions
        var track : [String] = []
        var money : [Double] = []
        for attraction in attractions {
            track.append(attraction.name)
            money.append(attraction.ratingAverage)
        }
        
        var entries = [PieChartDataEntry]()
        for (index, value) in money.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = track[index]
            entries.append(entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet(values: entries, label: "stars given")
        // this is custom extension method. Download the code for more details.
        var colors: [UIColor] = []
        
        for _ in 0..<money.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = PieChartData(dataSet: set)
        chart.data = data
        chart.noDataText = "No data available"
        // user interaction
        chart.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = "Rating chart"
        chart.chartDescription = d
        chart.holeRadiusPercent = 0.2
        chart.transparentCircleColor = UIColor.clear
        self.view.addSubview(chart)
    }
}
