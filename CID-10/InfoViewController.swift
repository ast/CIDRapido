//
//  InfoViewController.swift
//  CID-10
//
//  Created by Albin Stigo on 27/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit
import WebKit
import Social
import MessageUI
import CustomViews

private let kScreenName = "Info"

class InfoViewController: UIViewController, WKNavigationDelegate, MFMessageComposeViewControllerDelegate {

    private var webView: WKWebView?
    
    func shareButton(fontAwesome: FontAwesome) -> FABarButtonItem {
        let item = FABarButtonItem(fontAwesome: fontAwesome)
        item.target = self
        item.action = Selector("shareButtonClicked:")
        return item
    }
    
    lazy var hasEmail : Bool = {
        return MFMailComposeViewController.canSendMail()
    }()
    
    lazy var hasTwitter : Bool = {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }()
    
    /*
    lazy var hasFacebook : Bool = {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    }()
    */
    
    override func loadView() {
        webView = WKWebView()
        webView?.navigationDelegate = self
        
        view = webView
    }
    
    // WKWebView delegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let app = UIApplication.sharedApplication()
        
        switch (navigationAction.request.URL?.scheme, navigationAction.request.URL) {
        case (.Some("file"), _):
            decisionHandler(.Allow)
        case let (.Some("mailto"), .Some(url)) where app.canOpenURL(url):
            app.openURL(url)
            decisionHandler(.Cancel);
        default:
            break
        }
        
    }
    
    lazy var infoLabel : UILabel = {
        let label = UILabel()
        
        var text = NSMutableAttributedString(string: "\u{f0f8} Info")
        
        // Stethoscope
        text.addAttribute(NSFontAttributeName,
            value: UIFont(name: "FontAwesome", size: 22.0)!,
            range: NSMakeRange(0, 1))
        
        // Text font
        text.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Titillium-Semibold", size: 22.0)!,
            range: NSMakeRange(1, 5))
        
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        label.shadowOffset = CGSizeMake(1, 1)
        
        label.attributedText = text
        label.sizeToFit()
        
        return label
    }()
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareButtonClicked(sender: FABarButtonItem) {
        
        var controller: UIViewController? = nil
        
        let shareSubject = "CIDRapdio"
        let shareText = "\nhttp://appstore.com/cidrapido"
        
        switch sender.fontAwesome! {
            
        case .Email:
            let mc = MFMessageComposeViewController()
            mc.subject = shareSubject
            mc.body = shareText
            mc.messageComposeDelegate = self
            controller = mc
        /*
        case .Facebook:
            let fbc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbc.setInitialText(shareText)
            controller = fbc
        */
        case .Twitter:
            let twc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twc.setInitialText(shareText)
            controller = twc
            
        default:
            assertionFailure("Unknown social network.")
        }
        
        if let controller = controller {
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSBundle.mainBundle().URLForResource("index", withExtension: "html", subdirectory: "html")!
        let baseURL = url.URLByDeletingLastPathComponent!
        
        webView!.loadFileURL(url, allowingReadAccessToURL: baseURL)
        
        navigationItem.titleView = infoLabel
        
        var items = [UIBarButtonItem]()
        
        hasEmail ? items.append(shareButton(.Email)) : ()
        hasTwitter ? items.append(shareButton(.Twitter)) : ()
        //hasFacebook ? items.append(shareButton(.Facebook)) : ()
        
        navigationItem.rightBarButtonItems = items
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Google Analytics
        // Put it at the end of the main que
        dispatch_async(dispatch_get_main_queue(), {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: kScreenName)
            tracker.send( GAIDictionaryBuilder.createScreenView().build() as NSDictionary as [NSObject : AnyObject])
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
