//
//  TouristAttractionsViewController.swift
//  explore-ios
//
//  Created by Andra on 08/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import PromiseKit
import FirebaseAuth
import UserNotifications

class TouristAttractionsViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var pickerView: UIPickerView?
    let attrRef = Database.database().reference(withPath: "touristAttractions")
    
    @IBOutlet weak var headerView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupData()
        pickerView = UIPickerView()
        if UserDefaults.standard.string(forKey: "role")! == "ADMIN" {
            setupViewsForAdmin()
        }
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        
        Database.database().reference().observe(.value, with: { snapshot in
            self.setupData()
        })
        notificationSetup()
    }
    
    func notificationSetup() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                center.requestAuthorization(options: options) {
                    (granted, error) in
                    if !granted {
                        print("Something went wrong")
                    }
                }
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Checkout the new destinations"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400,
                                                        repeats: true)
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }
    
    func setupData() {
        TouristAttractions.shared.loadAttractionsFromFirebase()
            .then {
                entities -> Void in
                if (TouristAttractions.shared.attractionsList.count > 0 && ((self.countryTextField.text?.isEmpty)!) || !(self.countryTextField.text?.isEmpty)! && !TouristAttractions.shared.getCountries().contains(self.countryTextField.text!)) {
                        self.countryTextField.text = TouristAttractions.shared.getCountries()[0]
                        self.countryTextField.inputView = self.pickerView
                }
                
                self.tableView.reloadData()
            }.catch {
                error in
                print(error)
        }
    
    }
    
    func setupViews() {
        let nibName = UINib(nibName: "TouristAttractionCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "touristAttractionCell")
        self.tableView.separatorStyle = .none
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        headerView.backgroundColor = .white
        let button = UIButton(type: .system)
        button.setTitle("Statistics", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.seeStatistics), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        self.title = "Tourist Attractions"
    }
    func setupViewsForAdmin() {
        let addBtn = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(addTouristAttraction))
        self.navigationItem.rightBarButtonItem  = addBtn
    }
    @objc func addTouristAttraction() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = mainStoryboard.instantiateViewController(withIdentifier: "attractionDetailsViewController") as? TouristAttractionDetailsViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    @objc func seeStatistics() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = mainStoryboard.instantiateViewController(withIdentifier: "touristAttractionStatisticsViewController") as? TouristAttractionStatisticsViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return  TouristAttractions.shared.getAttractions(fromCountry: countryTextField.text!).count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView()
        sectionHeader.backgroundColor = .clear
        return sectionHeader
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "touristAttractionCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TouristAttractionCell  else {
            fatalError("The dequeued cell is not an instance of TouristAttractionCell.")
        }

        cell.selectionStyle = .none
        let attraction = TouristAttractions.shared.getAttractions(fromCountry: countryTextField.text!)[indexPath.section]
        cell.touristAttraction = attraction
        cell.nameLabel.text = attraction.name
        cell.attractionImageView.image = attraction.image
        UserDataManager.shared.getRatingFor(attractionId: attraction.Id!).then {
            rating -> Void in
            if let rat = rating {
                cell.ratingControl.rating = rat
            } else {
                cell.ratingControl.rating = 0
            }

        }.catch {
            error in
            print(error)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = mainStoryboard.instantiateViewController(withIdentifier: "attractionDetailsViewController") as? TouristAttractionDetailsViewController {
            controller.touristAttraction = TouristAttractions.shared.getAttractions(fromCountry: countryTextField.text!)[indexPath.section]
            controller.attractionIndex = indexPath.section
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}



extension TouristAttractionsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TouristAttractions.shared.getCountries().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TouristAttractions.shared.getCountries()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if TouristAttractions.shared.attractionsList.count > 0 {
            countryTextField.text = TouristAttractions.shared.getCountries()[row]
        }
        countryTextField.resignFirstResponder()
        tableView.reloadData()
    }
}


