//
//  ChartViewController.swift
//  MoodTracker
//
//  Created by axiom88 08/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import UIKit
import PNChartSwift

class ChartViewController: UIViewController {

    // Costants
    
    internal let PNLineColor = UIColor(red: 255.0 / 255.0 , green: 145.0 / 255.0, blue: 95.0 / 255.0, alpha: 1.0)
    internal let PNPieColor = UIColor(red: 232.0 / 255.0 , green: 121.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    
    // UI Outlets
    @IBOutlet var imvPortrait: UIImageView!
    @IBOutlet var chartView: UIView!
    @IBOutlet var lineChartView: UIView!
    @IBOutlet var piechartView: UIView!
    
    @IBOutlet var lblLeastActivity: UILabel!
    @IBOutlet var lblMostActivity: UILabel!
    
    @IBOutlet var segmentControl : ADVSegmentedControl!
    let lineChart:PNLineChart = PNLineChart(frame: CGRect(x: -10, y: 0, width: UIScreen.main.bounds.width, height: 200.0))
//    @IBOutlet var pieChart: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Load saved user's photo
        let filename = Utils.getTemporaryDirectory().appending("user.png")
        if let imageUser = UIImage(contentsOfFile: filename) {
            self.imvPortrait.image = imageUser
            PhotoManager.sharedInstance.savedList = uiRealm.objects(MTImage.self)
            PhotoManager.sharedInstance.savedList = PhotoManager.sharedInstance.savedList.sorted(byProperty: "time", ascending: true)
            print("Total Photos for Graph \(PhotoManager.sharedInstance.savedList.count)")
            if PhotoManager.sharedInstance.savedList.count == 0 {
                
                self.present(Utils.alertWithTitle("MoodTracker", message: "You're supposed to take any pictures to use this app."), animated: true, completion: nil)
            }
        }
        else{
            
            self.present(Utils.alertWithTitle("MoodTracker", message: "You're supposed to take a picture of your own, please choose correct one."), animated: true, completion: nil)

        }
        
        initUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func initUI(){
        
        //crete circular profile picture
        self.imvPortrait.setNeedsLayout()
        self.imvPortrait.layoutIfNeeded()
        self.imvPortrait.layer.cornerRadius = self.imvPortrait.frame.width/2
        self.imvPortrait.clipsToBounds = true
        self.imvPortrait.layer.borderWidth = 2.0
        self.imvPortrait.layer.borderColor = UIColor.white.cgColor
        self.imvPortrait.layer.masksToBounds = true
        
        segmentControl.items = ["DAILY", "MONTHLY", "YEARLY"]
        segmentControl.font = UIFont(name: "Helvetica Neue", size: 12)
        segmentControl.borderColor = UIColor.init(red: 247/255, green: 155/255, blue: 155/255, alpha: 1)

        segmentControl.selectedIndex = 0
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(sender:)), for: .valueChanged)
        initChart()
    }
    
    func initChart(){
        
        self.lineChartView.isHidden = false
        self.piechartView.isHidden = true
        
        // Draw PieChart
        

        
        // Draw LineChart
        
        lineChart.yLabelFormat = "%1.f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clear
        var tempList = [String]()
        for i in 0..<PhotoManager.sharedInstance.savedList.count {
            
            let photo = PhotoManager.sharedInstance.savedList[i]
            print("Time of Photo \(photo.time.toString())")
            tempList.append(photo.time.toString(.custom("yy/MM/dd")))
        }
        lineChart.xLabels = tempList as NSArray
        lineChart.showCoordinateAxis = true
        lineChart.showLabel = true
        
        self.lineChartView.addSubview(lineChart)
        
        // Line Chart Nr.1
        updateLineChart()
        
    }
    
    func updateLineChart(){
        
        // Line Chart Nr.1
        let data01:PNLineChartData = PNLineChartData()
        data01.color = PNLineColor
        data01.itemCount = PhotoManager.sharedInstance.savedList.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.pnLineChartPointStyleCycle
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = CGFloat((PhotoManager.sharedInstance.savedList[index].faces.first?.smile)!*10)
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        
        
    }
    
    func segmentValueChanged(sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            
            self.lineChartView.isHidden = false
            self.piechartView.isHidden = true
        }else{
            self.lineChartView.isHidden = true
            self.piechartView.isHidden = false
        }
        
        // draw chart again
        
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
