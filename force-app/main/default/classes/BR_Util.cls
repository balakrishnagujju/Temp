public with sharing class BR_Util{

public BR_Util()
{}

public static Boolean checkCreateUpdateAccess(String objectName, String commaSeparatedFieldList, String permissionType)
{
    System.debug('objectName = ' + objectName);
    System.debug('commaSeparatedFieldList = ' + commaSeparatedFieldList);
    System.debug('permissionType = ' + permissionType);

    String objectNameWithNS = '';
    String fieldNameWithNS = '';
    String NSPrefix ='';
    System.debug('NSPrefix = ' + NSPrefix);
    
    if (objectName.right(3).equalsIgnoreCase('__c') && String.isNotEmpty(NSPrefix)) {
        // if is a custom object and there is a namespace defined in custom settings
        if (!(objectName.left(NSPrefix.length() + 2).equalsIgnoreCase(NSPrefix + '__') && (objectName.length() > NSPrefix.length() + 5))) {
            // if doesn't already have NAMESPACE__ at the beginning
            objectNameWithNS = NSPrefix + '__' + objectName;
        } else {
            objectNameWithNS = objectName;
        }
    } else {
        objectNameWithNS = objectName;
    }
    System.debug('objectNameWithNS = ' + objectNameWithNS);
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectNameWithNS).getDescribe().fields.getMap();
    boolean permissionFlag;
    List<String> fieldList = commaSeparatedFieldList.split('[ ,]+');

    for (String fieldToCheck : fieldList) 
    {
       System.debug('-->fieldToCheck:'+ fieldToCheck);
        
       if (fieldToCheck.right(3).equalsIgnoreCase('__c') && String.isNotEmpty(NSPrefix)) {
        // if is a custom field and there is a namespace defined in custom settings
           if (!(fieldToCheck.left(NSPrefix.length()+2).equalsIgnoreCase(NSPrefix + '__') && (fieldToCheck.length() > NSPrefix.length()+5))) 
           {
            // if doesn't already have NAMESPACE__ at the beginning
            fieldNameWithNS = NSPrefix + '__' + fieldToCheck;
            } 
           else 
            {
                fieldNameWithNS = fieldToCheck;
            }
        } 
        else 
        {
            System.debug('First if was false');
            fieldNameWithNS = fieldToCheck;
        }

      // Check if the user has CRU access on the each field
      if(permissionType == 'create')
        {
              if (!fieldMap.get(fieldNameWithNS).getDescribe().isCreateable()) 
              {
                permissionFlag = false;
                break;
              }
              else
                permissionFlag = true;
        }
        else if(permissionType == 'update')
        {
            if (!fieldMap.get(fieldNameWithNS).getDescribe().isUpdateable()) 
              {
                permissionFlag = false;
                break;
              }
              else
                permissionFlag = true;
        }
        else
        {   
            return permissionFlag;
        }

    }// End of For loop

    System.debug('--> permissionFlag:'+permissionFlag);
    return permissionFlag;
}

public static string getAccessibleFields(String objectName, String commaSeparatedFieldList)
{
    System.debug('objectName = ' + objectName);
    System.debug('commaSeparatedFieldList = ' + commaSeparatedFieldList);

    String objectNameWithNS = '';
    String fieldNameWithNS = '';
    String NSPrefix = '';
    System.debug('NSPrefix = ' + NSPrefix);
    
    if (objectName.right(3).equalsIgnoreCase('__c') && String.isNotEmpty(NSPrefix)) {
        // if is a custom object and there is a namespace defined in custom settings
        if (!(objectName.left(NSPrefix.length() + 2).equalsIgnoreCase(NSPrefix + '__') && (objectName.length() > NSPrefix.length() + 5))) {
            // if doesn't already have NAMESPACE__ at the beginning
            objectNameWithNS = NSPrefix + '__' + objectName;
        } else {
            objectNameWithNS = objectName;
        }
    } else {
        objectNameWithNS = objectName;
    }
    System.debug('objectNameWithNS = ' + objectNameWithNS);
    
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectNameWithNS).getDescribe().fields.getMap();
    List<String> fieldList = commaSeparatedFieldList.split('[ ,]+');
    String accessibleFieldNames = '';
    Pattern matchChildReference = Pattern.compile('^([^\\.]+)\\.(.+)');
    
    Pattern matchSpecialFields = Pattern.compile('(?i)^CreatedBy\\.|^LastModifiedBy\\.|^Name$|^Owner\\.|^RecordType\\.');
    
    // If 'Name' field is not accessible then we assume the entire table (object) is not accessible
    if (!fieldMap.get('Id').getDescribe().isAccessible()) {
        System.debug('Check for object accessability using Name field returned false so returning \'\'');
        return '';
    }   
    
    for(String fieldName: fieldList){
        Matcher childFieldMatch = matchChildReference.matcher(fieldName);
        Matcher specialCaseMatch = matchSpecialFields.matcher(fieldName);

        if (fieldName.right(3).equalsIgnoreCase('__c') && String.isNotEmpty(NSPrefix)) {
            // if is a custom field and there is a namespace defined in custom settings
            if (!(fieldName.left(NSPrefix.length()+2).equalsIgnoreCase(NSPrefix + '__') && (fieldName.length() > NSPrefix.length()+5))) {
                // if doesn't already have NAMESPACE__ at the beginning
                fieldNameWithNS = NSPrefix + '__' + fieldName;
            } else {
                fieldNameWithNS = fieldName;
            }
        } else {
            System.debug('First if was false');
            fieldNameWithNS = fieldName;
        }
        
        if (specialCaseMatch.find()) {
             if(accessibleFieldNames == '') {
                 accessibleFieldNames = fieldName;
             } else {
                 accessibleFieldNames = accessibleFieldNames + ',' + fieldName;
             }
        } else if(childFieldMatch.matches() && String.isNotEmpty(childFieldMatch.group(2))) {
            String childReference = childFieldMatch.group(1);
            String childsFieldName = childFieldMatch.group(2);
            String childObjectName = '';
            if (childReference.right(3).equalsIgnoreCase('__r')) {
                childObjectName = childReference.left(childReference.length()-3) + '__c';
                if (NSPrefix != null && !(childObjectName.left(NSPrefix.length()+2).equalsIgnoreCase(NSPrefix + '__') && (childObjectName.length() > NSPrefix.length()+5)) && String.isNotEmpty(NSPrefix)) {
                    childObjectName = NSPrefix + '__' + childObjectName;
                }
            } else {
                childObjectName = childReference;
            }
            childObjectName = fieldMap.get(childObjectName).getDescribe().getReferenceTo().get(0).getDescribe().getName();
            if(String.isNotEmpty(getAccessibleFields(childObjectName, childsFieldName))) {
                 if(accessibleFieldNames == '') {
                     accessibleFieldNames = fieldName;
                 } else {
                     accessibleFieldNames = accessibleFieldNames + ',' + fieldName;
                 }
            }
        } else if (fieldMap.get(fieldNameWithNS).getDescribe().isAccessible()) {
             if(accessibleFieldNames == '') {
                 accessibleFieldNames = fieldName;
             } else {
                 accessibleFieldNames = accessibleFieldNames + ',' + fieldName;
             }
        }
    }
    
    System.debug('-->> original   Field Names ' + commaSeparatedFieldList );
    System.debug('-->> accessible Field Names ' + accessibleFieldNames );
    return accessibleFieldNames;
}
    public static sObject getRecord(id recordid){        
        sobject record;
        string fieldsToReturn='';
        Schema.SObjectType token = recordid.getSObjectType();
        system.debug('inside getRecord '+token);
        system.debug('inside getRecord '+string.valueOf(token));
        
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(string.valueOf(token) ).getDescribe().fields.getMap();
        for( String fieldName : fieldMap.keySet() ) {
            if(fieldsToReturn != '') {
                fieldsToReturn += ', ';
            }
            fieldsToReturn += fieldName;
            Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
            String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
            if (relationshipName != null && relationshipName.endsWith('__r')) {
                fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
            }
        }
        
        fieldsToReturn += ', Owner.Name, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
        
        // Build query string
        String query = '';
        query += 'select ' + fieldsToReturn + ' from '+string.valueOf(token)+' where id = \'' + recordid + '\' limit 1';
        system.debug('Query is: ' + query);
        record = database.query(query);        
        return record;
        
    }

    public static boolean BR_setPermissionSetAssignment(id myPermissionSetId,id myAssigneeId){ 
        PermissionSetAssignment psa = new PermissionSetAssignment
        (PermissionSetId = myPermissionSetId, AssigneeId = myAssigneeId);
        insert psa;
        return true;
    }  
    public static boolean BR_revokePermissionSetAssignment(id myPermissionSetId,id myAssigneeId){ 
        PermissionSetAssignment psa = [select id from PermissionSetAssignment where PermissionSetId=: myPermissionSetId And AssigneeId=: myAssigneeId];
        delete psa;
        return true;
    }      
}