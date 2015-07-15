trigger Task on Task (after insert, after update, after delete) {
    TriggerManager.invoke(TaskTriggerHandler.class);
}