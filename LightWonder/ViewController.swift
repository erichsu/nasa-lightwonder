//
//  ViewController.swift
//  LightWonder
//
//  Created by 許庭耀 on 2017/4/27.
//  Copyright © 2017年 許庭耀. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import Kingfisher
import Floaty
import Alamofire
import XCGLogger

class ViewController: UIViewController {
    @IBOutlet weak var cover: UIView!

    @IBOutlet weak var beachLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var waveLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var dateMenu: UICollectionView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var optionsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeMenu: Floaty!
    @IBOutlet weak var mars: UIImageView!
    
    @IBOutlet weak var temperatureIcon: UIImageView!
    @IBOutlet weak var waveIcon: UIImageView!
    @IBOutlet weak var humidityIcon: UIImageView!
    
    
    var search: UISearchBar!
    
    var locationManager: CLLocationManager!
    
    let beachLocations = [
        ["title": "恩納村", "subtitle": "Sun Marina海灘", "latitude": 26.460852, "longitude": 127.810528, "wave": "Lv2", "temperature": "28.7°C", "humidity": "42%"],
        ["title": "宮古島", "subtitle": "與那霸前濱", "latitude": 24.734154, "longitude": 125.262794, "wave": "Lv2", "temperature": "28.3°C", "humidity": "65%"],
        ["title": "夏威夷", "subtitle": "威基基", "latitude": 21.281039, "longitude": -157.839038, "wave": "Lv3", "temperature": "29.3°C", "humidity": "20%"],
        ["title": "墾丁", "subtitle": "白沙灣", "latitude": 21.934455, "longitude": 120.717451, "wave": "Lv2", "temperature": "28.8°C", "humidity": "75%"],
        ["title": "墾丁", "subtitle": "墾丁海水浴場", "latitude": 21.943973, "longitude": 120.795837, "wave": "Lv1", "temperature": "28.8°C", "humidity": "75%"],
        ["title": "Mars", "subtitle": "Endeavour", "latitude": 9999, "longitude": 9999, "wave": "Lv∞", "temperature": "--°C", "humidity": "--%"]
    ]
    var currentLocation = 0
    let regionRadius: CLLocationDistance = 1000
    var selectedType = ""
    var searchController: UISearchController!
    
    let domain = "http://ec2-35-160-185-126.us-west-2.compute.amazonaws.com:8080"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        randomLocation(self)
//        let beach = beachLocations[currentLocation]
//        if let lat = beach["latitude"] as? Double,
//            let long = beach["longitude"] as? Double,
//            let title = beach["title"] as? String,
//            let subtitle = beach["subtitle"] as? String {
//            let location = CLLocation(latitude: lat, longitude: long)
//            centerMapOnLocation(location: location)
//            
//            beachLabel.text = "\(subtitle)"
//        }
        
        for beach in beachLocations {
            if let lat = beach["latitude"] as? Double,
                let long = beach["longitude"] as? Double,
                let title = beach["title"] as? String,
                let subtitle = beach["subtitle"] as? String {
                let annotation = MKPointAnnotation()
                annotation.title = title
                annotation.subtitle = subtitle
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                mapView.addAnnotation(annotation)
            }
            
        }
        

        let handleMenuSelected: (FloatyItem) -> Void = {
            item in
            guard let type = item.title else { return }
            self.selectedType = type
            
            switch type {
            case "Surf":
                self.typeMenu.buttonImage = UIImage(named: "surfing")?.kf.resize(to: CGSize(width: 60, height: 60))
                break
            case "Swim":
                self.typeMenu.buttonImage = UIImage(named: "swimming")?.kf.resize(to: CGSize(width: 60, height: 60))
                break
            case "Dive":
                self.typeMenu.buttonImage = UIImage(named: "diving")?.kf.resize(to: CGSize(width: 60, height: 60))
                break
            case "Sunbath":
                self.typeMenu.buttonImage = UIImage(named: "sunbath")?.kf.resize(to: CGSize(width: 60, height: 60))
                break
            default:
                break
            }
        }
        typeMenu.buttonImage = UIImage(named: "surfing")?.kf.resize(to: CGSize(width: 60, height: 60))
        typeMenu.itemButtonColor = UIColor(red: 44/255.0, green: 105/255.0, blue: 134/255.0, alpha: 1.0)
        
        typeMenu.addItem("Surf", icon: UIImage(named: "surfing"), handler: handleMenuSelected)
        typeMenu.addItem("Swim", icon: UIImage(named: "swimming"), handler: handleMenuSelected)
        typeMenu.addItem("Dive", icon: UIImage(named: "diving"), handler: handleMenuSelected)
        typeMenu.addItem("Sunbath", icon: UIImage(named: "sunbath"), handler: handleMenuSelected)

        typeMenu.itemSize = 60
        
        let resultsController = UITableViewController(style: .plain)
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.isHidden = true
        search = searchController.searchBar
        view.addSubview(search)
        
        temperatureIcon.image = UIImage(named: "temp_01")?.withRenderingMode(.alwaysTemplate)
        waveIcon.image = UIImage(named: "wave_01")?.withRenderingMode(.alwaysTemplate)
        humidityIcon.image = UIImage(named: "algea_01")?.withRenderingMode(.alwaysTemplate)
        
//        let url = URL(string: "https://placehold.it/150x100")
//        weatherImage.kf.setImage(with: url)
//        let url = URL(string: "\(domain)/GetSolarInsolation/fuck/120/21")
//        Alamofire.request(url!, method: .get, parameters: nil).responseString { (string) in
//            print(string)
//        }
//        
//        let url2 = URL(string: "\(domain)/GetOceanSurfaceTemp/ones0318/121.1234/20.98765")
//        Alamofire.request(url2!, method: .get, parameters: nil).responseString { (string) in
//            print(string)
//        }
//        
//        
//        let url3 = URL(string: "\(domain)/GetChlorophyll/20170328/121.34567/23.9876")
//        Alamofire.request(url3!, method: .get, parameters: nil).responseString { (string) in
//            print(string)
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // 取得定位服務授權
            locationManager.requestWhenInUseAuthorization()
            
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止定位自身位置
        locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func pickDay(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            let color = self.dateMenu.isHidden ? self.view.tintColor: UIColor.gray
            self.dayButton.setTitleColor(color, for: .normal)
            self.optionsViewBottomConstraint.constant = self.dateMenu.isHidden ? 0: -50
            self.dateMenu.isHidden = !self.dateMenu.isHidden
            
            if !self.timeSlider.isHidden {
                self.timeSlider.isHidden = true
                self.timeButton.setTitleColor(UIColor.gray, for: .normal)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func pickTime(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            let color = self.timeSlider.isHidden ? self.view.tintColor: UIColor.gray
            self.timeButton.setTitleColor(color, for: .normal)
            self.optionsViewBottomConstraint.constant = self.timeSlider.isHidden ? 0: -50
            self.timeSlider.isHidden = !self.timeSlider.isHidden

            if !self.dateMenu.isHidden {
                self.dateMenu.isHidden = true
                self.dayButton.setTitleColor(UIColor.gray, for: .normal)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func randomLocation(_ sender: Any) {
        currentLocation = (currentLocation >= beachLocations.count - 2) ? 0 : currentLocation + 1
        
        let beach = beachLocations[currentLocation]
        if let lat = beach["latitude"] as? Double,
            let long = beach["longitude"] as? Double,
            let title = beach["title"] as? String,
            let subtitle = beach["subtitle"] as? String,
            let temperature = beach["temperature"] as? String,
            let wave = beach["wave"] as? String,
            let humidity = beach["humidity"] as? String {
            let location = CLLocation(latitude: lat, longitude: long)
            centerMapOnLocation(location: location)
            
            temperatureLabel.text = temperature
            humidityLabel.text = humidity
            waveLabel.text = wave
            mapView.isHidden = false
            
            beachLabel.text = "\(subtitle)"
            cover.backgroundColor = UIColor(colorLiteralRed: 29/255.0, green: 186/255.0, blue: 217/255.0, alpha: 1.0)
        }
    }
    
    
    @IBAction func unwindToMain(_ : UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        switch id {
            case "segueInfo":
                let dest = segue.destination as! InfoViewController
                if let subtitle =  self.beachLocations[self.currentLocation]["subtitle"] as? String {
                    dest.title = subtitle
                    dest.selectedType = self.selectedType
                }
                
            break
            default:
            break
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func showSearch(_ sender: Any) {

        search.isHidden = !search.isHidden
        search.becomeFirstResponder()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        print("\(currentLocation.coordinate.latitude)")
        print(", \(currentLocation.coordinate.longitude)")
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCollectionCell

        cell.textLabel.text = "May \(indexPath.row + 1)"
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! DateCollectionCell
        cell.backgroundColor = UIColor.gray
        dayButton.setTitle(cell.textLabel.text, for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
}


extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        XCGLogger.debug()
        if let resultsView = searchController.searchResultsController as? UITableViewController {
            resultsView.tableView.reloadData()
        }
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        XCGLogger.debug()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        XCGLogger.debug()
    }
}

extension ViewController: UISearchControllerDelegate {
    
}

extension ViewController: UITableViewDataSource, UIGestureRecognizerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beachLocations.count - 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let beach = beachLocations[indexPath.row]
        cell.textLabel?.text = "?? km - \(beach["title"] as! String), \(beach["subtitle"] as! String)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UITableViewHeaderFooterView()
        footer.addSubview(SearchFooter())
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        footer.addGestureRecognizer(tapRecognizer)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        print("Tapped Mars")
        searchController.searchResultsController?.dismiss(animated: true, completion: { 
            self.search.isHidden = true
            self.mapView.isHidden = true
            
            self.currentLocation = self.beachLocations.count - 1
            XCGLogger.debug("goto MARS \(self.currentLocation)")
            
            let beach = self.beachLocations[self.currentLocation]
            if let subtitle = beach["subtitle"] as? String,
                let temperature = beach["temperature"] as? String,
                let wave = beach["wave"] as? String,
                let humidity = beach["humidity"] as? String {
                
                self.temperatureLabel.text = temperature
                self.humidityLabel.text = humidity
                self.waveLabel.text = wave
                self.beachLabel.text = "\(subtitle)"
                self.cover.backgroundColor = UIColor(colorLiteralRed: 16/255.0, green: 37/255.0, blue: 63/255.0, alpha: 1.0)
                
 
            }
            
        })
    }
}

extension ViewController: UITableViewDelegate {
    
}

