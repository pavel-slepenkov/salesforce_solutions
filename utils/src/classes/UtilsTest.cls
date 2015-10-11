@isTest
private class UtilsTest {

    public static String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static String PROFILE_NAME_STANDARD_USER        = 'Standard User';
    public static String GUID_REGEX = '[A-Fa-f0-9]{8}(-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12}';

    public static User createUser(String profileName) {
        User u                      = new User();
        u.Username                  = 'test' + String.valueOf((Integer)(Math.random() * 1000000 + 1000000)) + '@dummyemail.com';
        u.Email                     = 'test.salesforce@dummyemail.com';
        u.Lastname                  = 'Test';
        u.Firstname                 = 'User';
        u.Alias                     = 'test';
        u.ProfileId                 = [SELECT Id FROM Profile WHERE Name = : profileName].Id;
        u.TimeZoneSidKey            = 'GMT';
        u.LocaleSidKey              = 'en_US';
        u.EmailEncodingKey          = 'ISO-8859-1';
        u.LanguageLocaleKey         = 'en_US';
        u.UserPermissionsMobileUser = false;
        return u;
    }

    public static User getAdminUser() {
        return createUser(PROFILE_NAME_SYSTEM_ADMINISTRATOR);
    }

    public static User getStandardUser() {
        return createUser(PROFILE_NAME_STANDARD_USER);
    }




    @isTest
    static void forAdminUser_isAdmin_shouldReturnTrue() {
        System.runAs(getAdminUser()) {
            System.assertEquals(true, Utils.isAdminUser());
        }
    }

    @isTest
	static void forNONAdminUser_isAdmin_shouldReturnFalse() {
        System.runAs(getStandardUser()) {
            System.assertEquals(false, Utils.isAdminUser());
        }
	}

    @isTest
    static void verify_isRecordId() {
        System.assertEquals(true, Utils.isRecordId('00661000004d55Y'));
        System.assertEquals(true, Utils.isRecordId('00161000005sZim'));
        System.assertEquals(true, Utils.isRecordId('00561000000rHF1'));
        System.assertEquals(false, Utils.isRecordId('006610000;04d55'));
        System.assertEquals(false, Utils.isRecordId('0066100004d555'));
        System.assertEquals(false, Utils.isRecordId('0066100004d55'));
        System.assertEquals(false, Utils.isRecordId('0066100004d5'));
        System.assertEquals(false, Utils.isRecordId('00661000555'));
        System.assertEquals(false, Utils.isRecordId('006610000_4d55;'));
        System.assertEquals(false, Utils.isRecordId('00661000--4d55;'));
        System.assertEquals(false, Utils.isRecordId('hha-hahha2313h-asdasd-asdasd'));
        System.assertEquals(false, Utils.isRecordId('_______asdasd;'));
        System.assertEquals(false, Utils.isRecordId('01p61000003ndTv verifyingId'));
    }

    @isTest
    static void verify_generateRandomGUID() {
        Pattern id = Pattern.compile(GUID_REGEX);
        for (Integer i = 0; i < 2000; i++) {
            Matcher matcher = id.matcher(Utils.generateRandomGUID());
            System.assertEquals(true, matcher.find());
        }
    }

}