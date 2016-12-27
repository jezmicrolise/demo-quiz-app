//
//  Created by Piyush Joshi on 12/24/16.
//  Copyright © 2016 Piyush Joshi. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet weak var lastScoreLabelField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Loads the player's current score
        getAndDisplayPlayerScore();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindtoCategories(sender: UIStoryboardSegue) {
        if sender.source is Question3ViewController {
            lastScoreLabelField.text = "Current score: " + String(MyGlobalVariables.playerScore);
            
            // Update this score in the backend also
            updatePlayerScore();
        }
    }
    
    func fetchAndDisplayLastPlayerScore() {
        let table = MyGlobalVariables.azureMobileClient.table(withName: "LastPlayedScore");
        
        table.read { (result2, error2) in
            if let err = error2 {
                print("ERROR ", err)
            } else if let items = result2?.items {
                for item in items {
                    print("Todo Item: ", item["score"]!)
                }
            }
        }
    }
    
    func getAndDisplayPlayerScore() {
        let table = MyGlobalVariables.azureMobileClient.table(withName: "LastPlayedScore");
        
        // Query if this player score exists
        // Create a predicate that finds items
        let userId = MyGlobalVariables.azureMobileClient.currentUser?.userId;
        let predicate =  NSPredicate(format: "userId == %@", userId!);
        
        // Query the LastPlayedScore table
        table.read(with: predicate) { (result, error) in
            if let err = error {
                print("Azure Mobile Apps: Error in connecting to the table: ", err)
            } else if (result?.items) != nil && (result?.items?.count)! > 0 {
                // If table access was succesful and an item was found
                let playerRecord = result?.items?[0];
                let playerLastScore = playerRecord!["score"];
                
                // Update
                self.lastScoreLabelField.text = playerLastScore as? String;
                
            } else {
                // No score found. Playing for the first time
                
                self.lastScoreLabelField.text = "All the best!";
            }
        }
    }
    
    func updatePlayerScore() {
        let table = MyGlobalVariables.azureMobileClient.table(withName: "LastPlayedScore");
        
        // Query if this player score exists
        // Create a predicate that finds items 
        let userId = MyGlobalVariables.azureMobileClient.currentUser?.userId;
        let predicate =  NSPredicate(format: "userId == %@", userId!);
        
        // Query the LastPlayedScore table
        table.read(with: predicate) { (result, error) in
            if let err = error {
                print("Azure Mobile Apps: Error in connecting to the table: ", err)
            } else if (result?.items) != nil && (result?.items?.count)! > 0 {
                // If table access was succesful and an item was found

                // Update
                print("Azure Mobile Apps: Player record exists. Updating it now.");
                
                let playerRecord = result?.items?[0];
                let playerRecordId = playerRecord?["id"];
                
                table.update(["id": playerRecordId!, "score": MyGlobalVariables.playerScore]) { (result, error) in
                    if let err = error {
                        print("Azure Mobile Apps: Error in updating player record: ", err);
                    } else if let item = result {
                        print("Azure Mobile Apps: Score updated to : ", item["score"]!);
                    }
                }
            } else {
                // Insert
                print("Azure Mobile Apps: Player record doesn't exist. Inserting new row.");
                
                let newItem = ["score": MyGlobalVariables.playerScore]
                table.insert(newItem) { (result, error) in
                    if let err = error {
                        print("Azure Mobile Apps: Error in inserting player record: ", err);
                    } else if let item = result {
                        print("Azure Mobile Apps: Score inserted : ", item["score"]!);
                    }
                }
            }
        }
    }
}
