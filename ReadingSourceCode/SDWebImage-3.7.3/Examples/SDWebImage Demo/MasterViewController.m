//
//  MasterViewController.m
//  SDWebImage Demo
//
//  Created by Olivier Poitrey on 09/05/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "MasterViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailViewController.h"

@interface MasterViewController () {
    NSArray *_objects;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"SDWebImage";
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Clear Cache"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(flushCache)];
        

        // HTTP NTLM auth example
        // Add your NTLM image url to the array below and replace the credentials
        [SDWebImageManager sharedManager].imageDownloader.username = @"httpwatch";
        [SDWebImageManager sharedManager].imageDownloader.password = @"httpwatch01";
        
        _objects = [NSArray arrayWithObjects:
                    @"http://www.httpwatch.com/httpgallery/authentication/authenticatedimage/default.aspx?0.35786508303135633",     // requires HTTP auth, used to demo the NTLM auth
                    @"http://assets.sbnation.com/assets/2512203/dogflops.gif",
                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/29/512429251713350_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450675479_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450731901_4.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450772668_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450790422_2.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450806057_3.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450822778_5.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450846813_6.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450866713_8.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/03/25/512132450880938_7.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/02/10/508413568149643_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946719410_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946770524_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946832013_2.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946878827_3.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946917861_4.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482946955758_5.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482947013793_6.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482947051864_7.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482947091465_8.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/04/502486280709437_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/04/502486280761875_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/04/502486280822142_2.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/04/502486280876362_3.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/10/503003472163935_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/10/503003472197959_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/16/503523949033054_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/16/503523949059133_2.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/16/503523949089655_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/12/16/503523949131784_3.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/01/04/505154790228188_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/01/20/506551827144070_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2017/02/10/508413568149643_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482889216922_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482889244941_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482889265553_2.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/22/501482889296575_3.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/20/501268556848571_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/18/501133002234031_0.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/18/501133002253052_1.png-q75",
                    @"http://f.yhres.com/share_webcastEKZlZmtlAQNkZwuinSx/2016/11/16/500931633220880_0.png-q75",
                    nil];
    }
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    return self;
}

- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}
							
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Image #%ld", (long)indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[_objects objectAtIndex:indexPath.row]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController)
    {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    NSString *largeImageURL = [[_objects objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"small" withString:@"source"];
    self.detailViewController.imageURL = [NSURL URLWithString:largeImageURL];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
