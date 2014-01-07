# GDIIndexBar - A custom index bar for iOS
[![Build Status](https://travis-ci.org/gdavis/GDIIndexBar.png?branch=master)](https://travis-ci.org/gdavis/GDIIndexBar)
[![Pod version](https://badge.fury.io/co/GDIIndexBar.png)](http://badge.fury.io/co/GDIIndexBar)

<table cellspacing="0" cellpadding="10px">
  <tr>
    <td>
      <img src="http://f.cl.ly/items/2c32450e1K3j2P1t242r/GDIIndexBar-3.png" alt="iOS7 Screenshot" width="320px">
    </td>
    <td>
      <img src="http://f.cl.ly/items/2x2H2x0A3T3k0i3y0p1i/GDIIndexBar-2.png" alt="iOS7 Screenshot" width="320px">
    </td>
  </tr>
</table>

`GDIIndexBar` is a component for navigating sections of a `UITableView`. It reproduces the index bar seen in the Contacts app on iOS and styled to match both iOS6 and iOS7 by default. `GDIIndexBar` can also be customized through the appearance protocol or by subclassing. 

`GDIIndexBar` behaves by automatically sizing and positioning itself on the right side of the provided `UITableView`. Subclasses can alter this by overriding the `layoutSubviews` method of the `GDIIndexBar`. `GDIIndexBar` provides automatic vertical adjustments for the index bar by setting a `GDIIndexBarAlignment` value. 

`GDIIndexBar` is supports being added directly to a `UITableView` as a child subview, or can exist in a different view than the table while still positioning automatically. *NOTE:* In order to correctly receive touch events as a subview of a `UITableView`, the `delaysContentTouches` property is automatically set to `NO`.

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

The example project contains two example view controllers. One demonstrates a `UITableViewController` subclass, and the other is a `UIViewController` that manages a `UITableView` and `GDIIndexBar` as subviews of the main view. 

### Instantiation

`GDIIndexBar` can be instantiated through code or by setting outlets with Interface Builder. See the example project for an IB-only implementation. Below is an example of of instantiating an index bar from a view controller's `viewDidLoad` method:

    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:tableView];
    indexBar.delegate = self;
    [self.view addSubview:indexBar];
    
### Providing Data

To correctly display an index bar its delegate must implement the `numberOfIndexesForIndexBar:` and `stringForIndex:` methods of the `<GDIIndexBarDelegate>` protocol. 

    - (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
    {
        return self.dataModel.sectionNames.count;
    }

    - (NSString *)stringForIndex:(NSUInteger)index
    {
        return [self.dataModel.sectionNames objectAtIndex:index];
    }
    
To respond to index bar touches, the delegate should implement the following delegate method and tell the table view to scroll sections:

    - (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
    
### Styling

`GDIIndexBar` can be customized by setting properties for the text font, text color, text shadow color, and the bar background color and width. A custom bar background view can also be provided using the `barBackgroundView` property. Offsets can also be provided for the text and bar background by setting the `textOffset` and `barBackgroundOffset` values, respectively. 

Below are examples of styling the index bar through the appearance protocol. 

    [[GDIIndexBar appearance] setTextColor:[UIColor redColor]];
    [[GDIIndexBar appearance] setTextShadowColor:[UIColor purpleColor]];
    [[GDIIndexBar appearance] setTextFont:[UIFont italicSystemFontOfSize:11.5];
    
For further customization, subclasses can override the `drawRect:` method of the GDIIndexBar to perform completely custom drawing. 

## Requirements

* iOS 6.0+

## Installation

GDIIndexBar is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "GDIIndexBar"

## Author

Grant Davis, grant@grantdavisinteractive.com

## License

GDIIndexBar is available under the MIT license. See the LICENSE file for more info.