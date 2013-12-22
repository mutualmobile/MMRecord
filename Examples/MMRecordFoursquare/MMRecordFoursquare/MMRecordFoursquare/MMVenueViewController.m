//
//  MMVenueViewController.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 12/21/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMVenueViewController.h"

#import "Contact.h"
#import "Location.h"
#import "Menu.h"
#import "Venue.h"

@interface MMVenueViewController ()

@property (nonatomic, weak) IBOutlet UILabel *venueNameLabel;
@property (nonatomic, weak) IBOutlet UITextView *addressTextView;
@property (nonatomic, weak) IBOutlet UITextView *phoneTextView;
@property (nonatomic, weak) IBOutlet UILabel *menuLabel;
@property (nonatomic, weak) IBOutlet UITextView *menuLinkTextView;

@end

@implementation MMVenueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.title = @"Venue";
    
    self.venueNameLabel.text = self.venue.name;
    
    NSString *addressText = [NSString stringWithFormat:@"%@ \n%@, %@ %@", self.venue.location.address, self.venue.location.city, self.venue.location.state, self.venue.location.postalCode];
    self.addressTextView.text = addressText;

    self.phoneTextView.text = self.venue.contact.formattedPhone;
    self.menuLabel.text = self.venue.menu.label;
    self.menuLinkTextView.text = self.venue.menu.url;
}

@end
