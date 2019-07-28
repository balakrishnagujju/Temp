@isTest
private class BR_Util_Test{

  static @TestSetup void setup(){
      //setup method
  }

  static testMethod void test_checkCreateUpdateAccess_UseCase1(){
    BR_Util obj01 = new BR_Util();
    BR_Util.checkCreateUpdateAccess('test data','test data','test data');
  }
  static testMethod void test_getAccessibleFields_UseCase1(){
    BR_Util obj01 = new BR_Util();
    BR_Util.getAccessibleFields('test data','test data');
  }
  static testMethod void test_getRecord_UseCase1(){
    BR_Util obj01 = new BR_Util();
    BR_Util.getRecord('01p90000006uk2w');
  }
}