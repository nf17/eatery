import UIKit
import WebKit
import Crashlytics

struct HistoryEntry {
    var description: String = ""
    var timestamp: String = ""
}

struct AccountBalance {
    var brbs: String = ""
    var cityBucks: String = ""
    var laundry: String = ""
    var swipes: String = "0"
}

enum Stages {
    case loginScreen
    case loginFailed
    case transition
    case fundsHome
    case diningHistory
    case finished
}

protocol BRBConnectionDelegate {
    func updateHistory(with entries: [HistoryEntry])
    func loginFailed(with error: String)
}

class BRBConnectionHandler: WKWebView, WKNavigationDelegate {
    
    var stage: Stages = .loginScreen
    var accountBalance: AccountBalance!
    var diningHistory: [HistoryEntry] = []
    let loginURLString = "https://get.cbord.com/cornell/full/login.php"
    let fundsHomeURLString = "https://get.cbord.com/cornell/full/funds_home.php"
    let diningHistoryURLString = "https://get.cbord.com/cornell/full/history.php"
    let updateProfileURLString = "https://get.cbord.com/cornell/full/update_profile.php"
    var loginCount = 0
    var netid: String = ""
    var password: String = ""
    var delegate: BRBConnectionDelegate?
    
    init() {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    //MARK: Connection Handling
    
    /**
     
     - Gets the HTML for the current web page and runs block after loading HTML into a string
     
     */
    func getHTML(block: @escaping (NSString) -> ()){
        evaluateJavaScript("document.documentElement.outerHTML.toString()",
                           completionHandler: { (html: Any?, error: Error?) in
                            if error == nil {
                                block(html as! NSString)
                            }
        })
    }
    
    /**
     
     - Loads login web page
     
     */
    func handleLogin() {
        loginCount = 0
        stage = .loginScreen
        let loginURL = URL(string: loginURLString)!
        load(URLRequest(url: loginURL))
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 1
    }
    
    /**
     
     - Fetches the HTML for the currently displayed web page and instantiates an DiningHistory array
     using the history information on the page.
     
     - Does not guarantee that the javascript has finished executing before trying to get dining history.
     
     */
    func getDiningHistory() {
        getHTML { (html: NSString) in
            let tableHTMLRegex = "(<tr class=\\\"(?:even|odd|odd first-child)\\\"><td class=\\\"first-child account_name\\\">(.*?)<\\/td><td class=\\\"date_(and_|)time\\\"><span class=\\\"date\\\">(.*?)<\\/span><\\/td><td class=\\\"activity_details\\\">(.*?)<\\/td><td class=\\\"last-child amount_points (credit|debit)\\\" title=\\\"(credit|debit)\\\">(.*?)<\\/td><\\/tr>)"
            
            let regex = try? NSRegularExpression(pattern: tableHTMLRegex, options: .useUnicodeWordBoundaries)
            if let matches = regex?.matches(in: html as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds , range: NSMakeRange(0, html.length))
            {
                for match in matches
                {
                    var entry = HistoryEntry()
                    
                    let htmlEntry = html.substring(with: match.range) as NSString
                    
                    //let accountName = self.findEntryValue(htmlEntry, fieldName: "account_name")
                    let transDate = self.findEntryValue(htmlEntry, fieldName: "\"date")
                    let transTime = self.findEntryValue(htmlEntry, fieldName: "\"time")
                    let amount = self.findEntryValue(htmlEntry, fieldName: "it")
                    let location = self.findEntryValue(htmlEntry, fieldName: "details")
                    
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "MMMM d, yyyy h:mma"
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/d 'at' h:mm a"
                    entry.description = location

                    if transDate.lengthOfBytes(using: .ascii) > 0 && transTime.lengthOfBytes(using: .ascii) > 0 {
                        if let date = formatter1.date(from: transDate + " " + transTime) {
                            entry.description += "\n " + formatter.string(from: date)
                        } else {
                            entry.description += "\n \(transDate) at \(transTime)"
                        }
                    }

                    entry.timestamp = amount.contains("$") ? amount : amount + " swipe"
                    
                    self.diningHistory.append(entry)
                }
            }

            self.delegate?.updateHistory(with: self.diningHistory)
        }
    }
    /**
     
     - Finds the value that is surrounded by the HTML tag ending with [fieldName">]
     
     */
    func findEntryValue(_ htmlEntry : NSString, fieldName : String) -> String {
        let fieldRange = htmlEntry.range(of: fieldName + "\">")
        var curIndex: Int = fieldRange.location + fieldRange.length
        
        var value = ""
        
        while curIndex < htmlEntry.length && htmlEntry.substring(with: NSMakeRange(curIndex, 1)) != "<"
        {
            value += htmlEntry.substring(with: NSMakeRange(curIndex, 1))
            curIndex += 1
        }
        
        return value
    }
    /**
     
     - Fetches the HTML for the currently displayed web page and instantiates a new AccountBalance object
     using the account information on the page.
     
     - Does not guarantee that the javascript has finished executing before trying to get account info.
     
     */
    func getAccountBalance() {
        getHTML { (html: NSString) -> () in
            self.accountBalance = AccountBalance()
            let brbHTMLRegex = "<td class=\\\"first-child account_name\\\">BRB.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let cityHTMLRegex = "<td class=\\\"first-child account_name\\\">CB.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let laundryHTMLRegex = "<td class=\\\"first-child account_name\\\">LAU.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let swipesHTMLRegex = "<td class=\\\"first-child account_name\\\">.*0.*<\\/td><td class=\\\"last-child balance\">[1-9]*[0-9]<\\/td>"
            
            let moneyRegex = "[0-9]+(\\.)*[0-9][0-9]"
            let swipesRegex = ">[1-9]*[0-9]<"
            
            if self.stage == .fundsHome {
                let brbs = self.parseHTML(html, brbHTMLRegex, moneyRegex)
                let city = self.parseHTML(html, cityHTMLRegex, moneyRegex)
                let laundry = self.parseHTML(html, laundryHTMLRegex, moneyRegex)
                let swipes = self.parseHTML(html, swipesHTMLRegex, swipesRegex)
                
                if brbs == "" {
                    self.getAccountBalance()
                    return
                }
                
                self.accountBalance.brbs = brbs != "" ? brbs : "0.00"
                self.accountBalance.cityBucks = city != "" ? city : "0.00"
                self.accountBalance.laundry = laundry != "" ? laundry : "0.00"
                self.accountBalance.swipes = swipes != "" ? String(swipes[swipes.index(after: swipes.startIndex)..<swipes.index(before: swipes.endIndex)]) : "Unlimited"

                let historyURL = URL(string: self.diningHistoryURLString)!
                self.load(URLRequest(url: historyURL))
            }
        }
    }
    
    /**
     * Makes two passes on an html string with two different
     * regular expressions, returning the inner result
     */
    func parseHTML(_ html: NSString, _ regex1: String, _ regex2: String) -> String
    {
        let firstPass = self.getFirstRegexMatchFromString(regexString: regex1 as NSString, str: html)
        let result = self.getFirstRegexMatchFromString(regexString: regex2 as NSString, str: firstPass as NSString)
        return result;
    }
    
    /**
     
     - Given a regex string and and a string to match on, returns the first instance of the regex
     string or an empty string if regex cannot be matched.
     
     */
    func getFirstRegexMatchFromString(regexString: NSString, str: NSString) -> String {
        let regex = try? NSRegularExpression(pattern: regexString as String, options: .useUnicodeWordBoundaries)
        if let match = regex?.firstMatch(in: str as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds , range: NSMakeRange(0, str.length)) {
            return str.substring(with: match.range(at: 0)) as String
        }
        return ""
    }
    
    func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(netid)';document.getElementsByName('password')[0].value = '\(password)';document.forms[0].submit();"
        
        evaluateJavaScript(javascript){ (result: Any?, error: Error?) -> Void in
            if let error = error {
                self.delegate?.loginFailed(with: error.localizedDescription)
            } else {
                if self.failedToLogin() {
                    if self.url?.absoluteString == self.updateProfileURLString {
                        self.delegate?.loginFailed(with: "Account needs to be updated")
                    }
                    self.delegate?.loginFailed(with: "Incorrect netid and/or password")
                }
            }
            self.loginCount += 1
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.getStageAndRunBlock {
            switch self.stage {
            case .loginFailed:
                self.delegate?.loginFailed(with: "Incorrect netid and/or password")
            case .loginScreen:
                if self.loginCount < 1 { self.login() }
            case .fundsHome:
                self.getAccountBalance()
            case .diningHistory:
                self.getDiningHistory()
            default: break
            }
        }
    }
    
    /**
     
     - Gets the stage enum for the currently displayed web page and runs a block after fetching
     the HTML for the page.
     
     - Does not guarantee Javascript will finish running before the block
     is executed.
     
     */
    func getStageAndRunBlock(block: @escaping () -> ()) {
        getHTML(block: { (html: NSString) -> () in
            if self.failedToLogin() {
                self.stage = .loginFailed
            } else if self.url!.absoluteString.contains(self.updateProfileURLString) {
                self.stage = .loginFailed
            } else if html.contains("<h1>CUWebLogin</h1>") {
                self.stage = .loginScreen
            } else if self.url!.absoluteString == self.fundsHomeURLString {
                self.stage = .fundsHome
            } else if self.url!.absoluteString == self.diningHistoryURLString {
                self.stage = .diningHistory
            } else {
                self.stage = .transition
            }
            
            //run block for stage
            block()
        })
    }
}
