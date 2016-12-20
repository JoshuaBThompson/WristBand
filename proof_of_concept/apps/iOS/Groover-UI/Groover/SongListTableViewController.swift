//
//  SongListTableViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/12/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

protocol SongTableProtocol: class {
    func setSongName(name: String, num: Int)
}

class SongListTableViewController: UITableViewController, SongCellDelegate {
    weak var delegate: SongTableProtocol?
    var songs = [SongTemplate]()
    var songsDatabase: [SongDatabase]!
    var selectedSong = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.loadSampleSongs()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: SongCellDelegate callbacks
    func selectSong(num: Int) {
        print("Song \(num) selected from song table view controller - \(num)")
        selectedSong = "Song \(num)"
        //delegate?.setSongName(name: selectedSong, num: num)
        GlobalAttributes.songViewController.setSongName(title: selectedSong)
        GlobalAttributes.songViewController.setSong(song_num: num)
        
    }
    
    func loadSampleSongs() {
        /*
         let song1 = DummySong(name: "Song1")!
         
         let song2 = DummySong(name: "Song2")!
         
         let song3 = DummySong(name: "Song3")!
         songs.append(song1)
         songs.append(song2)
         songs.append(song3)
         */
        if let savedSongs = loadSong(){
            songsDatabase = savedSongs
            for i in 0 ..< songsDatabase.count{
                let name = String(format: "Song \(i)" ) //songsDatabase[i].name!
                let dummySong = SongTemplate(name: name, num: i)!
                songs.append(dummySong)
                print("loaded song \(i)")
            }
        }
        
    }
    
    
    //MARK: Load saved songs from database
    func loadSong() -> [SongDatabase]?{
        print("Song database file path: \(SongDatabase.ArchiveURL.path)")
        return NSKeyedUnarchiver.unarchiveObject(withFile: SongDatabase.ArchiveURL.path) as? [SongDatabase]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SongListTableViewCell"
        
        // Fetches the appropriate meal for the data source layout.
        let song = songs[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SongListTableViewCell
        cell.delegate = self
        // Configure the cell...
        cell.songNameLabel.text = song.name //need to add nameLabel ui element to cell first
        cell.num = song.num
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     // Get the new view controller using segue.destinationViewController.
     let destViewController = segue.destination as! ViewController
     // Pass the selected object to the new view controller.
     destViewController.selectedSong = selectedSong
     
     print("Send data from song table controller to view controller!")
     
     }
     */
    
    
}
