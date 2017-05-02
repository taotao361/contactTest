//
//  ViewController.m
//  addressBook
//
//  Created by yangxutao on 17/4/28.
//  Copyright © 2017年 yangxutao. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

//ios9.0之后出的
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
@interface ViewController ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>

@end

@implementation ViewController

- (IBAction)buttonClick:(UIButton *)sender {
//    ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
//    nav.peoplePickerDelegate = self;
//    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
//    if (version >= 8.0) {
//        nav.predicateForEnablingPerson = [NSPredicate predicateWithValue:false];
//    }
//    [self presentViewController:nav animated:YES completion:nil];
    
    
     [self beforeIOS9];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];


    [self lookupContact];
    
}

//检索联系人
- (void)lookupContact {
    
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey]];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSLog(@"------ %@",contact);
    }];
    
}

- (void)addNewContact {
    //添加联系人对象
    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    mutableContact.givenName = @"黎明";
    mutableContact.nickname = @"liming";
    //新联系人电话属性
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:@"10000"]];
    CNLabeledValue *phoneNumber1 = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:@"13566666666"]];
    mutableContact.phoneNumbers = @[phoneNumber,phoneNumber1];
    
    //新联系人email属性
    CNLabeledValue *email1 = [CNLabeledValue labeledValueWithLabel:CNLabelEmailiCloud value:@"www.163.com"];
    mutableContact.emailAddresses = @[email1];
    
    
    //    mutableContact.postalAddresses 联系人 邮寄地址
    //    mutableContact.urlAddresses 联系人 URL地址
    //    mutableContact.contactRelations 联系人 关系人
    //    mutableContact.socialProfiles 联系人 生日 纪念日等
    //    mutableContact.instantMessageAddresses 联系人即时信息
    //    以上添加都可添加多个，集合
    
    
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    [request addContact:mutableContact toContainerWithIdentifier:nil];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    //获取权限
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusAuthorized) {
        NSError *error = nil;
        BOOL isSaved =  [store executeSaveRequest:request error:&error];
        NSLog(@"=========== %d",isSaved);
    }
}

- (void)beforeIOS9 {
    // 1.创建选择联系人的控制器
    CNContactPickerViewController *contactVc = [[CNContactPickerViewController alloc] init];
    
    // 2.设置代理
    contactVc.delegate = self;
    
    // 3.弹出控制器
    [self presentViewController:contactVc animated:YES completion:nil];
}






- (void)loadPerson {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
//            [hud turnToError:@"没有获取通讯录权限"];
        });
    }
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:textView];
    NSMutableString *mutableStr = [NSMutableString string];
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        //读取prefix前缀
        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        //读取suffix后缀
        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        //读取nickname呢称
        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        //读取firstname拼音音标
        NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        //读取lastname拼音音标
        NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        //读取middlename拼音音标
        NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        //读取jobtitle工作
        NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        //读取department部门
        NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        //读取birthday生日
        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        //读取note备忘录
        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        //第一次添加该条记录的时间
        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
        //最后一次修改該条记录的时间
        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);
        
        [mutableStr appendString:[NSString stringWithFormat:@"%@====%@====%@ \n  %@ \n    %@   \n %@   \n",firstName,lastName,middlename,prefix,suffix,nickname]];
        dispatch_async(dispatch_get_main_queue(), ^{
            textView.text = mutableStr;
        });
        
        
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            //获取email Label
            NSString* emailLabel =  (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
        }
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        int count = ABMultiValueGetCount(address);
        
        for(int j = 0; j < count; j++)
        {
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        }
        
        //获取dates多值
        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        int datescount = ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            //获取dates Label
            NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            //获取dates值
            NSString* datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
        }
        //获取kind值
        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            NSLog(@"it's a company\n");
        } else {
            // it's a person, resource, or room
            NSLog(@"it's a person, resource, or room\n");
        }
        
        
        //获取IM多值
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //获取IM Label
            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
        }
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            
        }
        
        //获取URL多值
        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            //获取电话Label
            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //获取該Label下的电话值
            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
        }
        
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

//- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
//    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
//    // 1.获取选中联系人的姓名
//    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
//    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
//    
//    // (__bridge NSString *) : 将对象交给Foundation框架的引用来使用,但是内存不交给它来管理
//    // (__bridge_transfer NSString *) : 将对象所有权直接交给Foundation框架的应用,并且内存也交给它来管理
//    NSString *lastname = (__bridge_transfer NSString *)(lastName);
//    NSString *firstname = (__bridge_transfer NSString *)(firstName);
//    
//    NSLog(@"%@ %@", lastname, firstname);
//    
//    // 2.获取选中联系人的电话号码
//    // 2.1.获取所有的电话号码
//    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
//    CFIndex phoneCount = ABMultiValueGetCount(phones);
//    
//    // 2.2.遍历拿到每一个电话号码
//    for (int i = 0; i < phoneCount; i++) {
//        // 2.2.1.获取电话对应的key
//        NSString *phoneLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
//        
//        // 2.2.2.获取电话号码
//        NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
//        
//        NSLog(@"%@ %@", phoneLabel, phoneValue);
//    }
//    
//    // 注意:管理内存
//    CFRelease(phones);
//}
//
//
//- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
//    
//}
//
//
//
//// Deprecated, use predicateForSelectionOfPerson and/or -peoplePickerNavigationController:didSelectPerson: instead.
//- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0) {
//    return YES;
//}
//
//// Deprecated, use predicateForSelectionOfProperty and/or -peoplePickerNavigationController:didSelectPerson:property:identifier: instead.
//- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0, 8_0) {
//    
//    return YES;
//}



#pragma mark - CNContactPickerDelegate


#pragma mark -单选
/*!
 * @abstract Invoked when the picker is closed.
 * @discussion The picker will be dismissed automatically after a contact or property is picked.
 */
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}

/*!
 * @abstract Singular delegate methods.
 * @discussion These delegate methods will be invoked when the user selects a single contact or property.
 */
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
//    // 1.获取联系人的姓名
//    NSString *lastname = contact.familyName;
//    NSString *firstname = contact.givenName;
//    NSLog(@"%@ %@", lastname, firstname);
//    
//    // 2.获取联系人的电话号码
//    NSArray *phoneNums = contact.phoneNumbers;
//    for (CNLabeledValue *labeledValue in phoneNums) {
//        // 2.1.获取电话号码的KEY
//        NSString *phoneLabel = labeledValue.label;
//        
//        // 2.2.获取电话号码
//        CNPhoneNumber *phoneNumer = labeledValue.value;
//        NSString *phoneValue = phoneNumer.stringValue;
//        
//        NSLog(@"%@ %@", phoneLabel, phoneValue);
//    }
//}


//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
//    
//}


#pragma mark -上边这两个方法，只会回调一个，如果实现第一个，则直接dismiss掉控制器；如果实现第二个则跳到详情；




#pragma mark -多选  如果单选多选都实现了代理方法，则优先显示多选；
/*!
 * @abstract Plural delegate methods.
 * @discussion These delegate methods will be invoked when the user is done selecting multiple contacts or properties.
 * Implementing one of these methods will configure the picker for multi-selection.
 */
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts {
//    
//}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty*> *)contactProperties {
//    
//}
























@end
