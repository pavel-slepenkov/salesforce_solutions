public class TriggerManager {
    public interface ITriggerHandler {
        void onBeforeInsert(List<sObject> newRecords);
    }

    public abstract class TriggerHandler implements ITriggerHandler {
        public virtual void onBeforeInsert(List<sObject> newRecords) {}
        public virtual void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}

        public virtual void onBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap) {}
        public virtual void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}

        public virtual void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
        public virtual void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}

        private void invoke(
                Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete,
                List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap) {
            if (isBefore) {
                if (isInsert) onBeforeInsert(newRecords);
                if (isUpdate) onBeforeUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
                if (isDelete) onBeforeDelete(oldRecords, oldRecordsMap);
            } else if (isAfter) {
                if (isInsert) onAfterInsert(newRecords, newRecordsMap);
                if (isUpdate) onAfterUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
                if (isDelete) onAfterDelete(oldRecords, oldRecordsMap);
            }
        }
    }

    /*
    *  Invoke trigger handler by type
    *  Usage: in trigger make call like  TriggerManager.invoke(ContactTriggerhandler.class);
    */
    public static void invoke(Type type) {
        Object handler = type.newInstance();
        if (handler instanceof TriggerHandler) {
            invoke((TriggerHandler) handler);
        }
        else {
            System.debug(LoggingLevel.ERROR, type + ' type doesn\'t extend TriggerHandler class');
        }
    }

    /*
    *   Invoke trigger handler by existing instance.
    *   Usage: in trigger make call like TriggerManager.invoke(new ContactTriggerhandler());
    */
    public static void invoke(TriggerHandler handler) {
        handler.invoke(
            Trigger.isBefore,
            Trigger.isAfter,
            Trigger.isInsert,
            Trigger.isUpdate,
            Trigger.isDelete,
            Trigger.old,
            Trigger.new,
            Trigger.oldMap,
            Trigger.newMap);
    }
}