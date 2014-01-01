# GDIIndexBar

<table cellspacing="0" cellpadding="10px">
  <tr>
    <td>
      <img src="http://f.cl.ly/items/1a3Z0T3A2X1x0W023W2R/GDIIndexBar-1.png" alt="iOS7 Screenshot" width="320px">
    </td>
    <td>
      <img src="http://f.cl.ly/items/2x2H2x0A3T3k0i3y0p1i/GDIIndexBar-2.png" alt="iOS7 Screenshot" width="320px">
    </td>
  </tr>
</table>

`GDIIndexBar` is a component for navigating sections of a `UITableView`. It reproduces the index bar seen in the Contacts app on iOS and styled to match both iOS6 and iOS7 by default. `GDIIndexBar` can also be customized through the appearance protocol or by subclassing. 

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

The example project contains two example view controllers. One demonstrates a `UITableViewController` subclass, and the other is a `UIViewController` that manages a `UITableView` and `GDIIndexBar` as subviews of the main view. 

### Instantiation

`GDIIndexBar` can be instantiated through code or by setting outlets with Interface Builder. See the example project to view an example IB-only implementation. Below is an example of of instantiating an index bar from a view controller's `viewDidLoad` method:

    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:tableView];
    indexBar.delegate = self;
    [self.view addSubview:indexBar];
    
### Providing Data

To correctly display an index bar its delegate must implement the `numberOfIndexesForIndexBar:` and `stringForIndex:` methods. 

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