//
//  ZDViewController.swift
//  MapDemo
//
//  Created by qizidong on 2017/9/27.
//  Copyright © 2017年 zidong. All rights reserved.
//

import UIKit

class ZDViewController: UIViewController {

    
    @IBOutlet weak var mapView: MAMapView!
    var search: AMapSearchAPI!
    var locationManager: AMapLocationManager!
    var isLocated = false
    
    fileprivate var searchPoiList = [AMapPOI]()
    fileprivate var currentAddress: String? //当前位置
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.zoomLevel = 15
        mapView.isShowsUserLocation = true    //显示用户位置
        mapView.distanceFilter = 100.0      //定位位移（位移超过100米使能）
        mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters  //定位精度100m
        
        search = AMapSearchAPI()
        search.delegate = self
        
        
//        locationManager = AMapLocationManager()
//        locationManager.delegate = self
//        //一次还不错的定位，偏差在百米左右，超时时间设置在2s-3s左右即可。
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        
//        locationManager.locationTimeout = 2
//        
//        locationManager.reGeocodeTimeout = 2
        
        //可以获取精度很高的一次定位，偏差在十米左右，超时时间请设置到10s，如果到达10s时没有获取到足够精度的定位结果，会回调当前精度最高的结果。
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.locationTimeout = 10
//        locationManager.reGeocodeTimeout = 10
        
        //请求定位并拿到结果
        //
//        locationManager.requestLocation(withReGeocode: false) { (location, reGeocode, error) in
//            if let error = error {
//                let error = error as NSError
//                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
//                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
//                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
//                    return
//                }else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
//                    || error.code == AMapLocationErrorCode.timeOut.rawValue
//                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
//                    || error.code == AMapLocationErrorCode.badURL.rawValue
//                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
//                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
//                    
//                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
//                    print("逆地理错误： \(error.localizedDescription)")
//                }
//            }
//            if let location = location {
//                print("-----------location:\(location)")
////                self.mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)
//            }
//            
//            if let reGeocode = reGeocode {
//                print("-----------reGeocode:\(reGeocode)")
//            }
//        }
        
    }
    
    func searchAround(at coordinate: CLLocationCoordinate2D) {
        let POIRequset = AMapPOIAroundSearchRequest()
        POIRequset.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        POIRequset.sortrule = 0
        POIRequset.radius = 1000
        self.search.aMapPOIAroundSearch(POIRequset)
        
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        request.requireExtension = true
        self.search.aMapReGoecodeSearch(request)
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

extension ZDViewController: MAMapViewDelegate {
    /* 定位回调中进行逆地理和周边poi查询. */
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !updatingLocation {
            return
        }
        if userLocation.location.horizontalAccuracy < 0 {
            return
        }
        //这里只第一次定位后执行
        if !self.isLocated {
            self.isLocated = true
            self.mapView.setCenter(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude), animated: true)
            self.searchAround(at: mapView.userLocation.coordinate)
        }
    }
    /* 地图移动回调 */
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        self.searchAround(at: mapView.centerCoordinate)
    }
}

extension ZDViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return searchPoiList.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        if indexPath.section == 0 {
            cell!.textLabel?.text = "[当前位置]";
            cell!.detailTextLabel?.text = self.currentAddress
            
        }else {
            if searchPoiList.count > 0 {
                let poi = searchPoiList[indexPath.row]
                cell?.textLabel?.text = poi.address
                cell?.detailTextLabel?.text = poi.address
            }
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ZDViewController: AMapSearchDelegate{
    /* POI 搜索回调 */
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        searchPoiList.removeAll()
        
        searchPoiList.append(contentsOf: response.pois)
        tableView.reloadData()
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            self.currentAddress = response.regeocode.formattedAddress
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("error :\(error)")
    }
}

extension ZDViewController: AMapLocationManagerDelegate {
    
}


