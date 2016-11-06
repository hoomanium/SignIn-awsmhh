//
//  SignInViewController.swift
//  MySampleApp
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.4
//
//

import UIKit
// import AWSMobileHubHelper
import FBSDKLoginKit
import GoogleSignIn

class SignInViewController: UIViewController {
    @IBOutlet weak var anchorView: UIView!

    @IBOutlet weak var facebookButton: UIButton!

    @IBOutlet weak var googleButton: UIButton!

    @IBOutlet weak var customProviderButton: UIButton!
    @IBOutlet weak var customCreateAccountButton: UIButton!
    @IBOutlet weak var customForgotPasswordButton: UIButton!
    @IBOutlet weak var customUserIdField: UITextField!
    @IBOutlet weak var customPasswordField: UITextField!
    @IBOutlet weak var leftHorizontalBar: UIView!
    @IBOutlet weak var rightHorizontalBar: UIView!
    @IBOutlet weak var orSignInWithLabel: UIView!
    
    
    var didSignInObserver: AnyObject!
    var usernameText: String?

    var customForgotPasswordViewController:ForgotPasswordViewController!
    var customCreateAccountViewController:SignupViewController!
    
    // MARK: - View lifecycle
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        customUserIdField.text = usernameText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        didSignInObserver =  NSNotificationCenter.defaultCenter().addObserverForName(AWSIdentityManagerDidSignInNotification,
                object: AWSIdentityManager.defaultIdentityManager(),
                queue: NSOperationQueue.mainQueue(),
                usingBlock: {[weak self] (note: NSNotification) -> Void in
                    guard let strongSelf = self else { return }
                    // perform successful login actions here
                    if AWSIdentityManager.defaultIdentityManager().currentSignInProvider is AWSCUPIdPSignInProvider {
                        // only remember the name of the user if it is a CUPIdP name
                        strongSelf.usernameText = AWSIdentityManager.defaultIdentityManager().userName
                    }
            })

                // Facebook login permissions can be optionally set, but must be set
                // before user authenticates.
                AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
                
                // Facebook login behavior can be optionally set, but must be set
                // before user authenticates.
//                AWSFacebookSignInProvider.sharedInstance().setLoginBehavior(FBSDKLoginBehavior.Web.rawValue)
                
                // Facebook UI Setup
                facebookButton.addTarget(self, action: #selector(SignInViewController.handleFacebookLogin), forControlEvents: .TouchUpInside)
                let facebookButtonImage: UIImage? = UIImage(named: "FacebookButton")
                if let facebookButtonImage = facebookButtonImage{
                    facebookButton.setImage(facebookButtonImage, forState: .Normal)
                } else {
                     print("Facebook button image unavailable. We're hiding this button.")
                    facebookButton.hidden = true
                }
                view.addConstraint(NSLayoutConstraint(item: facebookButton, attribute: .Top, relatedBy: .Equal, toItem: anchorViewForFacebook(), attribute: .Bottom, multiplier: 1, constant: 8.0))

                // Google login scopes can be optionally set, but must be set
                // before user authenticates.
                AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
                
                // Sets up the view controller that the Google signin will be launched from.
                AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
                
                // Google UI Setup
                googleButton.addTarget(self, action: #selector(SignInViewController.handleGoogleLogin), forControlEvents: .TouchUpInside)
                let googleButtonImage: UIImage? = UIImage(named: "GoogleButton")
                if let googleButtonImage = googleButtonImage {
                    googleButton.setImage(googleButtonImage, forState: .Normal)
                } else {
                     print("Google button image unavailable. We're hiding this button.")
                    googleButton.hidden = true
                }
                view.addConstraint(NSLayoutConstraint(item: googleButton, attribute: .Top, relatedBy: .Equal, toItem: anchorViewForGoogle(), attribute: .Bottom, multiplier: 1, constant: 8.0))
                // Custom UI Setup
                customProviderButton.addTarget(self, action: #selector(SignInViewController.handleCustomLogin), forControlEvents: .TouchUpInside)
                customCreateAccountButton.addTarget(self, action: #selector(SignInViewController.handleCustomCreateAccount), forControlEvents: .TouchUpInside)
                customForgotPasswordButton.addTarget(self, action: #selector(SignInViewController.handleCustomForgotPassword), forControlEvents: .TouchUpInside)
                customProviderButton.setImage(UIImage(named: "LoginButton"), forState: .Normal)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(didSignInObserver)
    }
    
    func dimissController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Utility Methods
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        
        AWSIdentityManager.defaultIdentityManager().loginWithSignInProvider(signInProvider, completionHandler: {(result: AnyObject?, error: NSError?) -> Void in
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                dispatch_async(dispatch_get_main_queue(),{
                    self.navigationController!.popViewControllerAnimated(true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    self.showErrorDialog(AWSIdentityManager.defaultIdentityManager().providerKey(signInProvider), withError: error!)
                })
            }
            print("result = \(result), error = \(error)")
            
        })
    }
    
    func showAlert(titleText: String, message: String) {
        var alertController: UIAlertController!
        alertController = UIAlertController(title: titleText, message: message, preferredStyle: .Alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: "Label to cancel dialog box."), style: .Cancel, handler: nil)
        alertController.addAction(doneAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorDialog(loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        if let message = error.userInfo["message"] {
            showAlert(NSLocalizedString("\(loginProviderName) Sign-in Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("Sign in using \(loginProviderName) failed: \(message)", comment: "Sign-in message structure for sign-in failure."))
        } else if let message = error.userInfo["NSLocalizedDescription"]{
            showAlert(NSLocalizedString("\(loginProviderName) Sign-in Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("Sign in using \(loginProviderName) failed: \(message)", comment: "Sign-in message structure for sign-in failure."))
        } else {
            showAlert(NSLocalizedString("\(loginProviderName) Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."))
        }
    }
    

    // MARK: - IBActions
    func handleFacebookLogin() {
        handleLoginWithSignInProvider(AWSFacebookSignInProvider.sharedInstance())
    }
    
    
    func handleGoogleLogin() {
        handleLoginWithSignInProvider(AWSGoogleSignInProvider.sharedInstance())
    }
    
    // CUPIdP changes
    
    // Now facebook and Google prompt for UID password, but here we prompt
    // for them BEFORE calling handleLoginWithSignInProvider.
    // Best solution is probably to make CUPIdP login work just like Google
    // and Facebook and let it prompt for it's own password.  If we did that we could
    // just have a row of "login with..." buttons on the home screen that
    // would disappear upon successful login.
    
    func handleCustomLogin() {
        
        if (customUserIdField.text != nil) && (customPasswordField.text != nil) {
            
            let customSignInProvider = AWSCUPIdPSignInProvider.sharedInstance
            
            // Push userId and password to our AWSCUPIdPSignInProvider
            customSignInProvider.customUserIdField = customUserIdField.text
            customSignInProvider.customPasswordField = customPasswordField.text
            
            handleLoginWithSignInProvider(customSignInProvider)
        }
    }
    
    func handleCustomCreateAccount() {
        // Handle Create Account action for custom sign-in here.
        if customCreateAccountViewController == nil { // use the same one - or we get multiple observers there
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            customCreateAccountViewController = storyboard.instantiateViewControllerWithIdentifier("signUp") as! SignupViewController
        }
        customCreateAccountViewController.usernameText = self.usernameText
        navigationController!.pushViewController(customCreateAccountViewController, animated: true)
    }
    
    func handleCustomForgotPassword() {
        // Handle Forgot Password action for custom sign-in here.
        if customForgotPasswordViewController == nil { // use the same one - or we get multiple observers there
            let storyboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
            customForgotPasswordViewController = storyboard.instantiateViewControllerWithIdentifier("forgotPassword") as! ForgotPasswordViewController
            customForgotPasswordViewController.usernameText = self.usernameText
        }
        navigationController!.pushViewController(customForgotPasswordViewController, animated: true)
    }
    
 
    func anchorViewForFacebook() -> UIView {
            return orSignInWithLabel
    }
    
    func anchorViewForGoogle() -> UIView {
            return facebookButton
        
    }
}
