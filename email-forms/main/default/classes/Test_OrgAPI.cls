@IsTest
public inherited sharing class Test_OrgAPI {
  @IsTest
  static void itGetsObjectsInOrg() {
    Test.startTest();
    List<Map<String, String>> objects = OrgAPI.getObjectsInOrg();
    System.assert(objects.size() > 0);
    Test.stopTest();
  }
  @IsTest
  static void itGetsPicklistOptions() {
    Test.startTest();
    Map<String, List<Map<String, String>>> picklistOptions = OrgAPI.getPicklistOptionsForObject(
      'Email_Form__c'
    );
    System.assert(picklistOptions.get('Type__c').size() > 0);
    Test.stopTest();
  }
}
