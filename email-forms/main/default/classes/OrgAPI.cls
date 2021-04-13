public with sharing class OrgAPI {
  @AuraEnabled(cacheable=true)
  public static List<Map<String, String>> getObjectsInOrg() {
    try {
      List<Map<String, String>> objects = new List<Map<String, String>>();
      List<Schema.SobjectType> sobjTypes = Schema.getGlobalDescribe().values();
      for (Schema.SobjectType objType : sobjTypes) {
        objects.add(
          new Map<String, String>{
            'label' => objType.getDescribe().getLabel(),
            'value' => objType.getDescribe().getName()
          }
        );
      }
      return objects;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  //modify to take
  @AuraEnabled(cacheable=true)
  public static Map<String, List<Map<String, String>>> getPicklistOptionsForObject(
    String objectApiName
  ) {
    try {
      Map<String, List<Map<String, String>>> fieldApiNameToOptions = new Map<String, List<Map<String, String>>>();
      Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
        .get(objectApiName)
        .getDescribe()
        .fields.getMap();
      for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult describe = field.getDescribe();
        String label = describe.label;
        if (describe.isUpdateable() && describe.isAccessible()) {
          Schema.DisplayType displayType = describe.getType();
          if (displayType.name() == 'PICKLIST') {
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Schema.PicklistEntry entry : describe.getPicklistValues()) {
              if (entry.isActive()) {
                options.add(
                  new Map<String, String>{
                    'label' => entry.getLabel(),
                    'value' => entry.getValue()
                  }
                );
              }
            }
            fieldApiNameToOptions.put(describe.name, options);
          }
        }
      }
      return fieldApiNameToOptions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
