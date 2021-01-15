public with sharing class OrgAPI {
  @AuraEnabled(cacheable=true)
  public static List<SObject> exectureQueryString(String queryString) {
    try {
      return Database.query(queryString);
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

  @AuraEnabled
  public static Map<String, Object> describeObjectFields() {
    try {
      Map<String, Object> res = new Map<String, Object>();

      Map<String, Schema.SObjectField> fieldMap = Account.getSObjectType()
        .getDescribe()
        .fields.getMap();
      for (String field : fieldMap.keySet()) {
        Schema.SObjectField sObjectField = fieldMap.get(field);
        Schema.DescribeFieldResult describe = sObjectField.getDescribe();
        String label = describe.label;
        if (describe.isUpdateable() && describe.isAccessible()) {
          Schema.DisplayType displayType = describe.getType();
          String typeName = displayType.name();
          List<String> options = new List<String>();
          if (typeName == 'PICKLIST') {
            for (Schema.PicklistEntry entry : describe.getPicklistValues()) {
              if (entry.isActive()) {
                options.add(entry.getLabel());
              }
            }
          }
          Map<String, Object> values = new Map<String, Object>{
            'options' => options
          };
          values.put('type', typeName);
          values.put('label', label);
          res.put(label, values);
        }
      }
      return res;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
