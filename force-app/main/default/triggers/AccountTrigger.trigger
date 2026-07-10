trigger AccountTrigger on Account (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        AccountTriggerHandler.beforeUpdate(
            Trigger.new,
            Trigger.oldMap
        );
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountTriggerHandler.afterUpdate(
            Trigger.new,
            Trigger.oldMap
        );
    }
}