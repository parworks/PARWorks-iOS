Welcome to the PARWorks iOS SDK.
=========

For full API documentation of the SDK, download the [Xcode .docset](raw/master/Documentation/com.parworks.ios.PARWorks-iOS-SDK-Documentation.docset.zip)!


The iOS SDK provides a native Objective-C interface to the PARWorks API, so you can dive right in and build great apps on top of the technology. We've built the SDK to eliminate the need for manually managing device location, augmentation jobs, image processing, and more. The SDK provides model objects for working with sites, augmented images, and overlays, and UIKit views that make it easy to present overlays within your app, leveraging matrix math, CoreAnimation and more. 

The iOS SDK also comes with several sample applications:

- EasyPar: Demonstrates basic use of the SDK to take a photo with the iPhone camera and augment it. The user takes a photo with the iPhone camera and the photo breaks apart into tiny pieces which fly off the screen as the image is "scanned" for overlays. When the result comes back from the server, the pieces fly back together and the image is shown with overlays drawn directly on to it. 
Other fun stuff: A complex animation that is great for impressive demos. Uses GCD and blocks to rapidly process image "shreds" on one processor while playing the animation on the other one.

- GraffitiDemo: Demonstrates how to use the SDK to augment photos taken with the iPhone's camera, process them on the server, and display custom overlays. In this app, users are meant to explore their city, taking photos of specific walls. Each time they take a photo of an augmented wall, digital graffiti is displayed on top of the photo directly on the wall, and they can tap to enlarge and edit it, leaving their contribution for others to see when they photograph the wall.
Other fun stuff: UIView subclass for CoreGraphics drawing, code for CALayer transitions along a path

- PARWorks Administration App: The management app allows you to create sites, view existing sites, add images to sites, augment images taken with the phone or in the photo library, and view overlays in augmented photos. We developed this app to test the functionality in the SDK, and it utilizes nearly every feature available. It's an easy way to create sites on the go, and allows you to quickly try out sites that you've created without having to create your own app.
**Note: When you use the PARWorks Administration app, make sure you update the API key located in ARAppDelegate.h! Otherwise you will not be able to manage sites in your account.**

Getting Started with the SDK
=========

Adding Files:
------------

To use the SDK, download the SDK package and drag the HDAR-SDK.framework into your application.  Click your application in the left-hand sidebar and click the "Build Phases" tab. Scroll to the "Link Binary with Libraries" section and add the following Frameworks. Note that adding frameworks doesn't increase the size of your application binary:

- CoreLocation.framework
- QuartzCore.framework
- MobileCoreServices.framework
- SystemConfiguration.framework
- CFNetwork.framework
- libz.dylib

Setting your API key:
------------

Add the line below to the beginning of your application delegate's application:didFinishLaunchingWithOptions: function. Replace "MY APP ID" with the app ID you were given on the PARWorks developer portal.

    [[ARManager shared] setApiKey: @"<MY API KEY>" andSecret: @"<MY API SECRET>"];

Registering for Location Support
------------

The iOS SDK provides built-in support for finding sites near the device's current location. This is great for creating apps that use the iPhone's camera and plan to augment sites at different physical locations. To use the ARManager's findNearbySites:withCompletionBlock: function, and other location-based methods in the SDK, you must enable location services in the app delegate by  calling:

    [[ARManager shared] setLocationEnabled: YES];

Note: Each site you create on the PARWorks platform has latitude and longitude information. If you create the site using the iOS management app, the geolocation information is added automatically. If you use the PARWorks website or the API directly, you need to add this information manually for the site to be included in calls to findNearbySites:withCompletionBlock:


Digging Deeper
=========

The Model Notifications Architecture
------------

The ARSite and ARAugmentedPhoto models in the iOS SDK follow a notifications architecture commonly used in iOS development prior to the introduction of blocks. Model objects send NSNotifications when asynchronous tasks complete so that views, controllers, and other objects displaying these models can listen for updates about them. For example, if you create an ARSite and call augmentImage:, an ARAugmentedPhoto is returned immediately. Registering for an NOTIF_AUGMENTED_PHOTO_UPDATED notification on this object allows you to receive an update when processing has advanced or completed.

Customizing the Appearance of Overlays
------------

After you submit a photo to be augmented and get an ARAugmentedPhoto object representing the processing job, you can use the ARAugmentedView to display the overlays within the photo. The ARAugmentedView and it's child AROverlayView's are meant to provide an attractive, out-of-the-box method for displaying the output of the PARWorks API. There are many ways to customize the appearance of the overlays, and we've designed the SDK to make it easy to extend the overlay classes and create custom experiences:

To customize appearance, make your view controller the delegate of the ARAugmentedView and implement the delegate function: 
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay;

This function allows you to map overlay objects to overlay views. You could use properties of the overlay, such as the description or JSON metadata to decide which type of view to return, and return a custom view based on the overlay content.

There are three basic ways to use this function to customize your app:

Method 1: Attachment styles
The AROverlayView class has an attachmentStyle property, which can be any of the values in AROverlayAttachmentStyle. This allows you to customize how overlays are drawn over your image with very little effort.

