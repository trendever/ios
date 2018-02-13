//
//  ViewController.swift
//  Trendever
//
//  Created by Руслан on 14/06/16.
//  Copyright © 2016 Trendever. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    let wv = WKWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
    var authIsDoneTimer:NSTimer?
    var pushAlreadySended = false
    var isAuth = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wv.allowsBackForwardNavigationGestures = true
        
        wv.navigationDelegate = self
        wv.UIDelegate = self;
        wv.hidden = true;
        view.addSubview(wv)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.openURL), name: "openURL", object: nil);
        if (openURL() == false) {
            guard let url = NSURL(string: "https://www.trendever.com") else { return }
            wv.loadRequest(NSURLRequest(URL: url))
        }
       
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if (wv.hidden){
            wv.hidden = false
            authIsDoneTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.getAuthIsDone), userInfo: nil, repeats: true)
        }
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .LinkActivated  {
            if let newURL = navigationAction.request.URL,
                host = newURL.host where !host.containsString("www.trendever.com") &&
                UIApplication.sharedApplication().canOpenURL(newURL) {
                if UIApplication.sharedApplication().openURL(newURL) {
                    print(newURL)
                    print("Redirected to browser. No need to open it locally")
                    decisionHandler(.Cancel)
                } else {
                    print("browser can not url. allow it to open locally")
                    decisionHandler(.Allow)
                }
            } else {
                print("Open it locally")
                decisionHandler(.Allow)
            }
        } else {
            print("not a user click")
            print(navigationAction.request.URL)
            decisionHandler(.Allow)
        }
    }
    
    func loadUrl(link : String) -> Bool{
        guard let url = NSURL(string: link) else { return false }
        wv.loadRequest(NSURLRequest(URL: url))
        return true;
    }
    
    func hideWV() -> Bool{
        wv.hidden = true
        return true
    }
    
    func reloadVW() -> Bool{
        wv.reload();
        return true;
    }

    func startTimer() -> Bool{
        authIsDoneTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.getAuthIsDone), userInfo: nil, repeats: true)
        return true;
    }
    
    func openURL() -> Bool {
        if (PushManager.sharedInstance.remoteNotification != nil) {
            if let data = PushManager.sharedInstance.remoteNotification!["data"] as? NSDictionary {
                if let link = data["URL"] as? String {
                    guard let url = NSURL(string: link) else { return false }
                    wv.loadRequest(NSURLRequest(URL: url))
                    return true;
                }
            }
            PushManager.sharedInstance.remoteNotification = nil;
        }
        return false;
    }
    
    func getAuthIsDone() {
        wv.evaluateJavaScript("authIsDone()") { (result:AnyObject?, error:NSError?) in
            if (result != nil && result?.integerValue == 1) {
                self.registerTokenIfNeeded()
            }
            if (result == nil){
                authIsDoneTimer?.invalidate()
                self.wv.reload();
            }
        }
    }
    
    func registerTokenIfNeeded() {
        if PushManager.sharedInstance.pushToken != nil && !pushAlreadySended {
            print(PushManager.sharedInstance.pushToken)
            let method = String(format: "setUserToken(\"%@\", \"iphone\")", PushManager.sharedInstance.pushToken!)
            wv.evaluateJavaScript(method) { (result:AnyObject?, error:NSError?) in
                if (error == nil) {
                    self.pushAlreadySended = true
                }
            }
        }
    }

}

