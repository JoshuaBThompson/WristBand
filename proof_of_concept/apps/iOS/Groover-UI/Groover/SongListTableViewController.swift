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
    var selectedSongNum: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "fullBackgroundBlur"))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.loadSavedSongs()
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
        selectedSong = GlobalAttributes.song.getSongName(song_num: num)
        //delegate?.setSongName(name: selectedSong, num: num)
        GlobalAttributes.songViewController.setSongName(title: selectedSong)
        GlobalAttributes.songViewController.setSong(song_num: num)
        
    }
    
    //MARK: Delete saved song from database
    func deleteSong(num: Int){
        print("deleting song \(num)")
        //Need to impliment iOS standard delete functionality
        //GlobalAttributes.songViewController.deleteSong(num: num)
    }
    
    
    func loadSavedSongs() {
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
                let name = songsDatabase[i].name //String(format: "Song \(i)" ) //songsDatabase[i].name!
                let dummySong = SongTemplate(name: name!, num: i)!
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
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print("deleting song \(indexPath.row)")
            songs.remove(at: indexPath.row)
            GlobalAttributes.song.deleteSong(num: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
    

    
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("!!selected \(indexPath.row)")
        selectedSongNum = Int(indexPath.row)
        if(selectedSongNum != nil){
            print("selectSong \(selectedSongNum)")
            let songNum = selectedSongNum
            self.selectSong(num: songNum!)
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     // Get the new view controller using segue.destinationViewController.
        if(segue.destination == GlobalAttributes.songViewController){
            let current_song_name = GlobalAttributes.song.current_song.name
            GlobalAttributes.songViewController.setSongName(title: current_song_name!)
            
        }
     // Pass the selected object to the new view controller.
     
     print("Send data from song table controller to view controller!")
     
     }
 
    
    
}
