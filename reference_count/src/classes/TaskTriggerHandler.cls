public class TaskTriggerHandler extends TriggerManager.TriggerHandler {


    private static final String CONTACT_RECORDS_PREFIX = '003';
    private static final String LOG_A_CALL_TYPE = 'Call';


    // Event handlers --------------------------------------------------------------------------------------------------
    /* - UNCOMMENT THESE METHODS IF NEEDED
    public override void onBeforeInsert(List<sObject> newRecords) {}

    public override void onBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap) {}

    public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
    */
    public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
        increaseReferenceCount(newRecords);
    }

    public override void onAfterUpdate(List<sObject> oldRecords,
                                       List<sObject> newRecords,
                                       Map<ID, sObject> oldRecordsMap,
                                       Map<ID, sObject> newRecordsMap) {
        decreaseReferenceCountOnTaskTypeChange(newRecords, oldRecordsMap);
    }


    public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
       decreaseReferenceCountOnTaskTypeChange(oldRecords, null);
    }


    // HANDLERS methods ------------------------------------------------------------------------------------------------

    private static void increaseReferenceCount(List<sObject> newRecords) {
        List<sObject> taskRelatedToContact = new List<sObject>();
        for (SObject obj : newRecords) {
            if (((String)obj.get('WhoId')).startsWith(CONTACT_RECORDS_PREFIX) && ((String)obj.get('Type')) == LOG_A_CALL_TYPE) {
                taskRelatedToContact.add(obj);
            }
        }
        updateReferenceCountField(taskRelatedToContact, true);
    }


    private static void decreaseReferenceCountOnTaskTypeChange(List<sObject> newRecords, Map<ID, sObject> oldRecordsMap) {
        List<sObject> taskToDecreaseCount = new List<sObject>();
        for (SObject obj : newRecords) {
            if (Trigger.isUpdate) {
                if (((String)obj.get('WhoId')).startsWith(CONTACT_RECORDS_PREFIX)
                    && ((String)obj.get('Type')) != LOG_A_CALL_TYPE
                    && ((String)(oldRecordsMap.get((Id)obj.get('Id'))).get('Type')) == LOG_A_CALL_TYPE) {
                    taskToDecreaseCount.add(obj);
                }
            } else if (Trigger.isDelete  && ((String)obj.get('Type')) == LOG_A_CALL_TYPE ) {
                taskToDecreaseCount.add(obj);
            }
        }
        updateReferenceCountField(taskToDecreaseCount, false);
    }

    private static void updateReferenceCountField(List<sObject> tasks, Boolean isIncrement) {
        Map<Id, List<sObject>> tasksByContact = ILC_Utils.splitListBySpecialKey(tasks, 'WhoId');
        List<Contact> relatedContactsForUpdateCountField = [SELECT Id, Reference_Count__c, AccountId
                                                            FROM Contact
                                                            WHERE Id IN: tasksByContact.keySet()];
        updateAccounts(relatedContactsForUpdateCountField, tasksByContact, isIncrement);
        updateContacts(relatedContactsForUpdateCountField, tasksByContact, isIncrement);
    }

    private static void updateAccounts(List<Contact> relatedContactsForUpdateCountField,
                                       Map<Id, List<sObject>> tasksByContact,
                                       Boolean isIncrement) {
        // ContactId, Account
        Map<Id,Id> contactIdByAccountId = new Map<Id,Id>();
        for (Contact cont: relatedContactsForUpdateCountField) {
            contactIdByAccountId.put(cont.AccountId, cont.Id);
        }
        List<Account> accountsRelatedToContactsForUpdate = [SELECT Id, Reference_Count__c
                                                            FROM Account
                                                            WHERE Id IN: contactIdByAccountId.keySet()];

        for (Account acc: accountsRelatedToContactsForUpdate) {
            if (acc.Reference_Count__c != null) {
                if (isIncrement) {
                    acc.Reference_Count__c += tasksByContact.get(contactIdByAccountId.get(acc.Id)).size();
                } else {
                    acc.Reference_Count__c -= tasksByContact.get(contactIdByAccountId.get(acc.Id)).size();
                }
            } else {
                acc.Reference_Count__c = tasksByContact.get(contactIdByAccountId.get(acc.Id)).size();
            }
        }
        update accountsRelatedToContactsForUpdate;
    }

    private static void updateContacts(List<Contact> relatedContactsForUpdateCountField,
                                       Map<Id, List<sObject>> tasksByContact,
                                       Boolean isIncrement) {
        for (Contact cont: relatedContactsForUpdateCountField) {
            Integer amountOfNewTasks = tasksByContact.get(cont.Id).size();
            if (amountOfNewTasks > 0) {
                if (cont.Reference_Count__c != null) {
                    if (isIncrement) {
                        cont.Reference_Count__c += amountOfNewTasks;
                    } else {
                        cont.Reference_Count__c -= amountOfNewTasks;
                    }
                } else {
                    cont.Reference_Count__c = amountOfNewTasks;
                }
            }
        }
        update relatedContactsForUpdateCountField;
    }

}