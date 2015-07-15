@isTest
private class TaskTriggerTest {

    @isTest
    static void smokeTest() {
        ILC_TestDataHelper.initTestEnv();
        Contact cont = ILC_TestDataHelper.createContact();
        Task t1 = new Task(Type = 'Call', Subject = 'Call', WhoId = cont.Id);
        insert t1;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
        Task t2 = new Task(Type = 'Call', Subject = 'Call', WhoId = cont.Id);
        insert t2;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
        Task t3 = new Task(Type = 'Demo', Subject = 'Demo', WhoId = cont.Id);
        insert t3;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
        t3.Subject = 'Demo2';
        update t3;
        delete t3;
    }

    @isTest
    static void verifyDecrement() {
        ILC_TestDataHelper.initTestEnv();
        Contact cont = ILC_TestDataHelper.createContact();
        Task t1 = new Task(Type = 'Call', Subject = 'Call', WhoId = cont.Id);
        insert t1;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
        Task t2 = new Task(Type = 'Call', Subject = 'Call', WhoId = cont.Id);
        insert t2;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
        t2.Type = 'Demo';
        update t2;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact][0].Reference_Count__c);
    }

    @isTest
    static void verifyAccountReferenceFieldCalculation() {
        ILC_TestDataHelper.initTestEnv();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accId = [SELECT Id FROM Account LIMIT 1][0].Id;
        Contact contact1 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact2;
        Task t1 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t1;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(1, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t2 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact2.Id);
        insert t2;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=:contact2.Id][0].Reference_Count__c);
        System.assertEquals(2, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t3 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t3;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(3, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
    }

    @isTest
    static void verifyAccountContactReferenceFieldCalculationAfterDelete() {
        ILC_TestDataHelper.initTestEnv();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accId = [SELECT Id FROM Account LIMIT 1][0].Id;
        Contact contact1 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact2;
        Task t1 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t1;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(1, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t2 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact2.Id);
        insert t2;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=:contact2.Id][0].Reference_Count__c);
        System.assertEquals(2, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t3 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t3;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(3, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        delete t3;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=:contact2.Id][0].Reference_Count__c);
        System.assertEquals(2, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
    }

    @isTest
    static void verifyAccountContactReferenceFieldCalculationAfterUpdate() {
        ILC_TestDataHelper.initTestEnv();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accId = [SELECT Id FROM Account LIMIT 1][0].Id;
        Contact contact1 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = accId);
        insert contact2;
        Task t1 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t1;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(1, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t2 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact2.Id);
        insert t2;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=:contact2.Id][0].Reference_Count__c);
        System.assertEquals(2, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        Task t3 = new Task(Type = 'Call', Subject = 'Call', WhoId = contact1.Id);
        insert t3;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(3, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        t3.Type = 'Demo';
        update t3;
        System.assertEquals(1, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(2, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
        t3.Type = 'Call';
        update t3;
        System.assertEquals(2, [SELECT Reference_Count__c FROM Contact WHERE Id=: contact1.Id][0].Reference_Count__c);
        System.assertEquals(3, [SELECT Reference_Count__c FROM Account][0].Reference_Count__c);
    }
}