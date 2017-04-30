//
//  InfoViewController.swift
//  LightWonder
//
//  Created by TingYao Hsu on 2017/4/29.
//  Copyright © 2017年 許庭耀. All rights reserved.
//

import UIKit

import Charts

class InfoViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var highTemperaturLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedType = ""
    var infoCards = [
        ["title": "Wave", "titleImage": "title_wave", "contentText": "Long", "contentImage": "wave", "detail": "5"],
        ["title": "Algae", "titleImage": "title_algae", "contentText": "Safe", "contentImage": "algae_0"],
        ["title": "Wind", "titleImage": "title_wind", "contentText": "WSW", "contentImage": "wind_SW", "detail": "2"],
        ["title": "Sun", "titleImage": "title_sun", "contentText": "Cloudy", "contentImage": "UV_icon", "detail": "7"],
        ["title": "Dive", "titleImage": "title_dive", "contentText": "<10M", "contentImage": "icon_look_throgh"],
        ["title": "Weather", "titleImage": "title_wthr", "contentText": "30°C", "contentImage": "icon_WaterTemp"],
    ]
    
    var currentDetail: DetailCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let title = title {
            backButton.setTitle("⬅︎ \(title)", for: .normal)
        }
        

        let range: UInt32 = 5
        var values: [ChartDataEntry] = []
        for i in 0..<10 {
            let val = arc4random_uniform(range) + 3
            values.append(ChartDataEntry(x: Double(i), y: Double(val)))
            
        }
        
        let dataset = LineChartDataSet(values: values, label: "Label1")
        dataset.drawFilledEnabled = true
        dataset.mode = .cubicBezier
//        let gradientColors = [UIColor.cyan.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let gradientColors = [UIColor(red: 29/255.0, green: 186/255.0, blue: 217/255.0, alpha: 1.0).cgColor, UIColor(red: 40/255.0, green: 106/255.0, blue: 135/255.0, alpha: 1.0).cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        dataset.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradie
        
        let chartdata = LineChartData(dataSets: [dataset])
        lineChart.data = chartdata
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.drawLabelsEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.legend.enabled = false
        lineChart.chartDescription?.text = ""
        lineChart.minOffset = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InfoViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! InfoCardCell
        let card = infoCards[indexPath.row]
        if let title = card["title"],
            let titleImage = card["titleImage"],
            let contentText = card["contentText"],
            let contentImage = card["contentImage"] {
            
            
            cell.titleText.text = title
            cell.titleImage.image = UIImage(named: titleImage)
            cell.contentText.text = contentText
            cell.contentImage.image = UIImage(named: contentImage)
        }
        if let detail = card["detail"] {
            cell.detail.text = detail
            if card["title"] == "Wave" {
                cell.detail.textColor = UIColor(colorLiteralRed: 29/255.0, green: 186/255.0, blue: 217/255.9, alpha: 1.0)
            }
        }
        return cell
    }
}

extension InfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let from = collectionView.cellForItem(at: indexPath) as! InfoCardCell
        let style = from.titleText.text == "Algae" ? DetailCardStyle.algae : DetailCardStyle.sun
        let to = DetailCard(style, frame: collectionView.frame)
        
        UIView.transition(from: from, to: to, duration: 0.3, options: [.curveEaseInOut, .transitionFlipFromLeft]) { res in
            self.currentDetail = to
            self.view.addSubview(to)
            self.collectionView.reloadData()
        }
        
    }
}

