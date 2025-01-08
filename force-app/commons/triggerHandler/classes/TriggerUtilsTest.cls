@isTest
private class TriggerUtilsTest {
    @isTest
    static void myUnitTest() {
        List<SObject> records = new List<SObject>{
            new Account(Name = 'Test Account', Id = TestFactory.getFakeId(Schema.Account.SObjectType)),
            new Account(Name = 'Test Account 2', Id = TestFactory.getFakeId(Schema.Account.SObjectType))
        };

        Map<Id, SObject> oldMap = new Map<Id, SObject>(records.deepClone(true));
        ((Account) oldMap.get(records[0].Id)).Name = 'Test Account Updated';

        Test.startTest();
        TriggerUtils.logRecordUpdates(records, oldMap);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assert(logs.size() > 0, 'No logs were created');
    }
}
