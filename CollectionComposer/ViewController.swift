//
//  ViewController.swift
//  TwitterDispatcher
//
//  Created by Holger Hinzberg on 29.04.18.
//  Copyright © 2018 Holger Hinzberg. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet var destinationPathTextfield: NSTextField!
    @IBOutlet var copyCounterLabel: NSTextField!
    @IBOutlet var copyButton: NSButton!
    @IBOutlet var numberOfFilestoCopyTextfield : NSTextField!
    @IBOutlet var keywordsTextfield : NSTextField!
    @IBOutlet weak var folderInfoTableView: NSTableView!
    @IBOutlet var deleteFilesCheckbox: NSButton!
    
    private let folderInfoRepository = FolderInfoRepository()
    private var sourceUrl : URL?
    private var destinationUrl : URL?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.copyCounterLabel.stringValue = ""
        self.LoadConfigAndUpdateView()
        
        self.folderInfoRepository.Load()
        self.ReloadFoldersTableView()
        
        if Config.deleteOriginalFiles == true
        {
            self.deleteFilesCheckbox.state = .on
        }
        else
        {
            self.deleteFilesCheckbox.state = .off
        }
        //getNumberOfImagefilesFromSourcePathAsync()
    }
    
    override var representedObject: Any?{
        didSet {
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func addSourceFolderButtonClicked(_ sender: Any)
    {
        self.addSourceFolder()
    }
    
    @IBAction func scanFolderContentButtonClicked(_ sender: Any)
    {
            self.scanFolderContent()
    }

    @IBAction func copyFilesButtonClicked(_ sender: NSButton)
    {
        self.copyFiles()
    }
    
    // MARK: - Button Actions Business Logic
    
    func addSourceFolder()
    {
        if let folderUrl = self.openFileDialog()
        {
            if folderUrl.path != ""
            {
                let fileHelper = HHFileHelper()
                let foldersInfo = FolderInfo()
                foldersInfo.Folder = folderUrl.path
                foldersInfo.FileCount = fileHelper.getFilesCount(folderPath: folderUrl.path)
                self.folderInfoRepository.Add(info: foldersInfo)
                self.folderInfoRepository.Save()
                self.ReloadFoldersTableView()
            }
        }
    }
    
    func scanFolderContent()
    {
        let filesHelper = HHFileHelper()
        let count = self.folderInfoRepository.GetCount()
        
        for index in 0..<count
        {
            let info = self.folderInfoRepository.GetItemAt(index: index)
            info.FileCount = filesHelper.getFilesCount(folderPath: info.Folder)
        }
        self.ReloadFoldersTableView()
    }
    
    func copyFiles()
    {
        self.UpdateConfigValuesAndSave()
        self.copyButton.isEnabled = false
        self.copyCounterLabel.stringValue = ""
        
        // Assign all the Files in the Folders to the FolderInfos
        let count = self.folderInfoRepository.GetCount()
        for index in 0..<count
        {
            let info = self.folderInfoRepository.GetItemAt(index: index)
            let url = URL(fileURLWithPath: info.Folder)
            info.FilesInFolder = self.getFilesURLFromFolder(url)
        }
        
        // Collect random URLs from the Folders
        var itemIndex = 0
        var randomFileUrls = [URL]()
        let keywords = Config.keywords.components(separatedBy: ",")
        let countNeeded = Int(Config.numberOfFilesToCopy)
        
        for _ in 0...countNeeded
        {
            let info = self.folderInfoRepository.GetItemAt(index: itemIndex)
            if let files = info.FilesInFolder
            {
                if files.count  > 0
                {
                    // Pick one random File
                    let randFiles = self.getRandomFileUrls(files, count: 1, containingKeywords: keywords)
                    randomFileUrls.append(contentsOf: randFiles)
                }
            }
            
            // The next FolderInfo
            itemIndex = itemIndex + 1
            if itemIndex == self.folderInfoRepository.GetCount()
            {
                itemIndex = 0
            }
        }
        
        // Copy the random Files to the Destination
        let fileHelper = HHFileHelper()
        let destinationUrl = URL(fileURLWithPath: Config.destinationPath);
        let copyCounter = fileHelper.copyFiles(sourceUrls: randomFileUrls, toUrl: destinationUrl)
        self.copyCounterLabel.stringValue = "\(copyCounter) files copied"
        self.copyButton.isEnabled = true
        
        // Delete original files
        if Config.deleteOriginalFiles == true
        {
            for url in randomFileUrls
            {
                let _ = fileHelper.deleteItemAtPath(sourcePath: url.path)
            }
        }
    }
    
    // MARK: - Checkbox Actions
    
    @IBAction func deleteCheckboxClicked(_ sender: Any)
    {
        self.UpdateConfigValuesAndSave()
    }
    
    // MARK: - Menu Actions
    
    func IndexesToProcessForContextMenu(tableView:NSTableView) -> IndexSet
    {
        var selectedIndexes:IndexSet = tableView.selectedRowIndexes
        let clickedRow = tableView.clickedRow
        
        if clickedRow != -1 && selectedIndexes.contains(clickedRow) == false
        {
            selectedIndexes = IndexSet(integer: clickedRow)
        }
        return selectedIndexes
    }
    
    @IBAction func deleteMenuItemClicked(_ sender: Any)
    {
        let selectedIndexes = self.IndexesToProcessForContextMenu(tableView: folderInfoTableView)
        for index in selectedIndexes
        {
            self.folderInfoRepository.removeItemAt(index: index)
        }
        
        self.ReloadFoldersTableView()
        self.folderInfoRepository.Save()
    }

    @IBAction func addSourceMenuItemClicked(_ sender: Any)
    {
        self.addSourceFolder()
    }
    
    func LoadConfigAndUpdateView()
    {
        Config.load()
        //self.sourcePathTextfield.stringValue = Config.sourcePath
        self.destinationPathTextfield.stringValue = Config.destinationPath
        self.keywordsTextfield.stringValue = Config.keywords
        self.numberOfFilestoCopyTextfield.intValue = Config.numberOfFilesToCopy
    }
    
    func UpdateConfigValuesAndSave()
    {
        //Config.sourcePath = self.sourcePathTextfield.stringValue
        Config.destinationPath = self.destinationPathTextfield.stringValue
        Config.keywords = self.keywordsTextfield.stringValue
        Config.numberOfFilesToCopy = self.numberOfFilestoCopyTextfield.intValue
        
        if self.deleteFilesCheckbox.state == .on
        {
            Config.deleteOriginalFiles = true
        }
        else
        {
            Config.deleteOriginalFiles = false
        }
        
        Config.save()
    }
    
    
    func getNumberOfImagefilesFromSourcePathAsync()
    {
        /*
        DispatchQueue.global(qos: .userInitiated).async
        {
                let fileHelper = HHFileHelper()
                let sourceUrl = URL(fileURLWithPath: Config.sourcePath);
                let count = fileHelper.getNumberOfImagefilesFromFolder(sourceUrl)
                
                DispatchQueue.main.async
                {
                    if count == 1
                    {
                        self.sourcePathFileCountLabel.stringValue = "1 file in selected source"
                    }
                    else
                    {
                        self.sourcePathFileCountLabel.stringValue = "\(count) files in selected source"
                    }
                }
        }
        */
    }
    
    @IBAction func destionationPathButtonClicked(_ sender: Any)
    {
        if let url = self.openFileDialog()
        {
            self.destinationUrl = url
            self.destinationPathTextfield.stringValue = url.path
            self.UpdateConfigValuesAndSave()
        }
    }
    
    func openFileDialog() -> URL?
    {
        let fileDialog = NSOpenPanel()
        fileDialog.canChooseFiles = false
        fileDialog.canChooseDirectories = true
        fileDialog.runModal()
        return fileDialog.url
    }
    
    private func getRandomFileUrls(_ fileURLs:[URL], count:Int, containingKeywords:[String]) -> [URL]
    {
        // You can not get more files than avalible
        var randomFilesCount = count
        if fileURLs.count < randomFilesCount
        {
            randomFilesCount = fileURLs.count
        }
        
        // Fill Dictionary with random entries
        var randomFileUrlsDict = [String:URL]()
        while randomFileUrlsDict.count < randomFilesCount
        {
            let randomPosition = arc4random_uniform( UInt32(fileURLs.count - 1))
            let url = fileURLs[Int(randomPosition)]
            
            var containingAllKeywords = true
            
            for keyword in containingKeywords
            {
                if url.path.caseInsensitiveContains(substring: keyword) == false && keyword != ""
                {
                    containingAllKeywords = false
                    break
                }
            }
            
            if containingAllKeywords == true
            {
                randomFileUrlsDict[url.path] = url
            }
        }
        
        // Transfer Dictionary Keys to Array
        let randomFileUrlsArray = Array(randomFileUrlsDict.values)
        return randomFileUrlsArray
    }
    
    private func getFilesURLFromFolder(_ folderURL: URL) -> [URL]?
    {
        let options: FileManager.DirectoryEnumerationOptions =
            [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
        
        let fileManager = FileManager.default
        let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey]
        
        guard let directoryEnumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: resourceValueKeys,
                                                               options: options, errorHandler: { url, error in
                                                                print("`directoryEnumerator` error: \(error).")
                                                                return true
        }) else { return nil }
        
        var urls: [URL] = []
        for case let url as URL in directoryEnumerator
        {
            do {
                let resourceValues = try (url as NSURL).resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard UTTypeConformsTo(fileType as CFString, "public.image" as CFString) else { continue }
                urls.append(url)
            }
            catch
            {
                print("Unexpected error occured: \(error).")
            }
        }
        return urls
    }
    
    // MARK: - TableView
    
    private func ReloadFoldersTableView()
    {
        self.folderInfoTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.folderInfoRepository.GetCount()
    }
    
    func tableView(_: NSTableView, objectValueFor: NSTableColumn?, row: Int) -> Any?
    {
        let folderInfo = self.folderInfoRepository.GetItemAt(index: row)
        let ident = objectValueFor?.identifier.rawValue
        
        if ident == "FolderColumn"
        {
            return folderInfo.Folder
        }
        else if ident == "FilesCountColumn"
        {
            return folderInfo.FileCount
        }
        
        return nil
    }
    
    
}

