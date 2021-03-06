//
//  SGKeychainExampleTests.m
//  SGKeychainExampleTests
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

#import "SGKeychainExampleTests.h"
#import "SGKeychain.h"

@interface SGKeychainExampleTests ()
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *expectedPassword;
@end

@implementation SGKeychainExampleTests

@synthesize username;
@synthesize service;
@synthesize expectedPassword;

- (void)setUp
{
    [super setUp];
    self.username = @"justin";
    self.service = @"com.secondgear.testapp";
    self.expectedPassword = @"testpassword";    
}

- (void)tearDown
{
    [super tearDown];
    // Delete the keychain password before each test.
    [SGKeychain deletePasswordForUsername:self.username serviceName:self.service error:nil];
    
    self.username = nil;
    self.service = nil;
    self.expectedPassword = nil;
}

- (void)testPasswordIsSuccessfullyCreated
{
    NSString *password = @"testpassword";
    BOOL successfullyCreated = [SGKeychain setPassword:password username:self.username serviceName:self.service updateExisting:NO error:nil];
    STAssertTrue(successfullyCreated, @"create password failed");    
    STAssertEqualObjects(password, self.expectedPassword, @"Incorrect password fetched");
}

- (void)testErrorReturnedWhenPassingNilValuesOnCreate
{
    NSError *error = nil;
    BOOL successfullyCreated = [SGKeychain setPassword:nil username:self.username serviceName:self.service updateExisting:NO error:&error];
    STAssertFalse(successfullyCreated, @"create password didn't fail as expected");    
    
    STAssertTrue([error code] == -666, @"Error code received not as expected");
}

- (void)testExistingPasswordRecordSuccessfullyUpdated
{
    NSString *oldPassword = @"oldpassword";
    NSString *newPassword = @"newpassword";
    BOOL successfullyCreated = [SGKeychain setPassword:oldPassword username:self.username serviceName:self.service updateExisting:NO error:nil];
    STAssertTrue(successfullyCreated, @"create password failed");    
    
    BOOL successfullyUpdated = [SGKeychain setPassword:newPassword username:self.username serviceName:self.service updateExisting:YES error:nil];
    STAssertTrue(successfullyUpdated, @"updating an existing password failed");
    
    NSString *password = [SGKeychain passwordForUsername:self.username serviceName:self.service error:nil];    
    STAssertEqualObjects(password, newPassword, @"Incorrect password fetched after update");
}

- (void)testPasswordIsSuccessfullyFetched
{
    NSString *testpassword = @"testpassword";
    [SGKeychain setPassword:testpassword username:self.username serviceName:self.service updateExisting:NO error:nil];
    
    NSString *password = [SGKeychain passwordForUsername:self.username serviceName:self.service error:nil];
    STAssertEqualObjects(password, expectedPassword, @"Expected password not fetched from keychain.");
}

- (void)testPasswordsAreSuccessfullyFetchedFromSameAccessGroup
{
    NSString *accessGroup = @"com.secondgear";
    
    // Add a password for justin and justinw to the access group
    NSString *firstpassword = @"firstpassword";
    [SGKeychain setPassword:firstpassword username:self.username serviceName:self.service accessGroup:accessGroup updateExisting:NO error:nil];

    NSString *secondpassword = @"secondpassword";
    [SGKeychain setPassword:secondpassword username:@"justinw" serviceName:self.service accessGroup:accessGroup updateExisting:NO error:nil];
    
    
    // Ensure that the passwords can be retrieved
    NSString *password1 = [SGKeychain passwordForUsername:self.username serviceName:self.service accessGroup:accessGroup error:nil];
    STAssertEqualObjects(password1, firstpassword, @"Expected password for justin not fetched from keychain access group.");    
    
    NSString *password2 = [SGKeychain passwordForUsername:@"justinw" serviceName:self.service accessGroup:accessGroup error:nil];
    STAssertEqualObjects(password2, secondpassword, @"Expected password for justinw not fetched from keychain access group.");    
    
    // Delete the passwords
    [SGKeychain deletePasswordForUsername:self.username serviceName:self.service accessGroup:accessGroup error:nil];
    [SGKeychain deletePasswordForUsername:@"justinw" serviceName:self.service accessGroup:accessGroup error:nil];
}

- (void)testErrorReturnedWhenPassingNilValuesOnFetch
{
    NSError *error = nil;
    NSString *password = [SGKeychain passwordForUsername:nil serviceName:self.service error:&error];
    STAssertNil(password, @"didn't expect to get a password back");    
    
    STAssertTrue([error code] == -666, @"Error code received not as expected");
}


- (void)testPasswordIsSuccessfullyDeleted
{
    NSString *testpassword = @"testpassword";
    [SGKeychain setPassword:testpassword username:self.username serviceName:self.service updateExisting:NO error:nil];

    BOOL successfullyDeleted = [SGKeychain deletePasswordForUsername:self.username serviceName:self.service error:nil];
    STAssertTrue(successfullyDeleted, @"deleting an existing password failed");
}

- (void)testErrorReturnedWhenPassingNilValuesOnDelete
{
    NSError *error = nil;
    [SGKeychain deletePasswordForUsername:nil serviceName:self.service error:&error];    
    STAssertTrue([error code] == -666, @"Error code received not as expected");
}

@end
