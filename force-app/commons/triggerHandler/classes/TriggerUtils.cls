public class TriggerUtils {
    private static Set<String> ignoreFields = new Set<String>{
        'CreatedById',
        'CreatedDate',
        'LastModifiedById',
        'LastModifiedDate',
        'SystemModstamp'
    };

    private static final String BEFORE_PREFIX = '▶️ ';
    private static final String AFTER_PREFIX = '🏁 ';

    private static Boolean isLoggingEnabled {
        get {
            if (isLoggingEnabled == null) {
                TriggerLogging__c settings = TriggerLogging__c.getInstance();
                isLoggingEnabled = settings?.EnableLogging__c == true;
            }
            return isLoggingEnabled;
        }
        private set;
    }

    public static void logRecordInserts(List<SObject> newRecords, Boolean isBefore) {
        if (!isLoggingEnabled) return;
        
        String prefix = isBefore ? BEFORE_PREFIX : AFTER_PREFIX;
        for (SObject newRecord : newRecords) {
            Map<String, Object> fields = newRecord.getPopulatedFieldsAsMap();
            fields.keySet().removeAll(ignoreFields);

            List<String> values = new List<String>();
            for (String field : fields.keySet()) {
                Object value = fields.get(field);
                if (value != null) {
                    values.add(field + '\n' + String.valueOf(value) + '\n');
                }
            }
            
            if (!values.isEmpty()) {
                String message = prefix + '➕ New record values:\n\n' + String.join(values, '\n');
                Logger.info(message, newRecord);
            }
        }
        Logger.saveLog();
    }

    public static void logRecordUpdates(List<SObject> newRecords, Map<Id, SObject> existingRecords, Boolean isBefore) {
        if (!isLoggingEnabled) return;
        
        String prefix = isBefore ? BEFORE_PREFIX : AFTER_PREFIX;
        for (SObject newRecord : newRecords) {
            Id recordId = newRecord.Id;
            SObject oldRecord = existingRecords.get(recordId);

            Set<String> allFields = new Set<String>();
            allFields.addAll(newRecord.getPopulatedFieldsAsMap().keySet());
            allFields.addAll(oldRecord.getPopulatedFieldsAsMap().keySet());
            allFields.removeAll(ignoreFields);

            List<String> changes = new List<String>();
            for (String field : allFields) {
                Object newValue = newRecord.get(field);
                Object oldValue = oldRecord.get(field);

                if (newValue != oldValue) {
                    changes.add(field + '\n' + String.valueOf(oldValue) + ' => ' + String.valueOf(newValue) + '\n');
                }
            }
            
            if (!changes.isEmpty()) {
                String message = prefix + '✍🏻 Field changes:\n\n' + String.join(changes, '\n');
                Logger.info(message, newRecord);
            }
        }
        Logger.saveLog();
    }

    public static void logRecordDeletes(List<SObject> deletedRecords, Boolean isBefore) {
        if (!isLoggingEnabled) return;
        
        String prefix = isBefore ? BEFORE_PREFIX : AFTER_PREFIX;
        for (SObject record : deletedRecords) {
            Map<String, Object> fields = record.getPopulatedFieldsAsMap();
            fields.keySet().removeAll(ignoreFields);

            List<String> values = new List<String>();
            for (String field : fields.keySet()) {
                Object value = fields.get(field);
                if (value != null) {
                    values.add(field + '\n' + String.valueOf(value) + '\n');
                }
            }
            
            if (!values.isEmpty()) {
                String message = prefix + '❌ Deleted record values:\n\n' + String.join(values, '\n');
                Logger.info(message, record);
            }
        }
        Logger.saveLog();
    }
}
