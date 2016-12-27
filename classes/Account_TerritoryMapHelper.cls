/**
 * 
 * 
 * @author :RAJ BEHURA
 * @description : This is helper class using in "AccountTriggerOperations" trigger .
    If the account ZIP code is matched  to the ZIP code in territory custom table , during creation and update
    then the acount  will be linked to the coresponding territory.
 */
public with sharing class Account_TerritoryMapHelper {
  
    public static Set <String> zipCodeList = new Set <String>();
    public static Set <String> updatedZipCodeList = new Set <String>();
    public static List <Account> updatedAccount = new List <Account>();
    public static List<Territory_Mapping__c>territoryList = new List <Territory_Mapping__c>();
    public static List<Territory_Mapping__c>updatedTerritoryList = new List <Territory_Mapping__c>();
    public static Map<String,List<Territory_Mapping__c>> zipTerritoryMap=new Map<String, List<Territory_Mapping__c>>();
    public static Map<String,String>accZipMap=new Map<String,String>();
    public static List<Account_Territory_Map__c>AccTerritoryList=new List<Account_Territory_Map__c>();
    public int a = 20;
    public int b = 20;
    public int c = 40;
    /**
    * @description :This method is called from the trigger after  any new account is created.
      Based on the zip code value for the Account, it creates the  related "AccountTerritory" record.
    * 
    * @param List Of Accouts which get Created(List<Account>)
    * 
    * @return Nothing (Void)
    */ 
 
    public static void AccountTerritoryMap(List<Account> accountList) {
      
     for(Account accnt : accountList)
        {
           if(accnt.BillingPostalCode != null){
                if(accnt.BillingPostalCode.contains('-'))
                {
                  Integer index = accnt.BillingPostalCode.indexOf('-');
                  String postalCodeSubString = accnt.BillingPostalCode.substring(0,index);
                  zipCodeList.add(postalCodeSubString.toUpperCase());
                  accZipMap.put(accnt.Id,postalCodeSubString.toUpperCase());
                }
                else if(accnt.BillingPostalCode.contains(' ')){
                    Integer index = accnt.BillingPostalCode.indexOf(' ');
                    String postalCodeSubString = accnt.BillingPostalCode.substring(0,index);
                    zipCodeList.add(postalCodeSubString.toUpperCase());
                    accZipMap.put(accnt.Id,postalCodeSubString.toUpperCase());
                }
                else{
                  zipCodeList.add(accnt.BillingPostalCode.toUpperCase());
                  accZipMap.put(accnt.Id,accnt.BillingPostalCode.toUpperCase());
                }
            }
        }
        territoryList = [select id,Geo_level_0__c,Territory_Name__c,Geo_Level_1__c,Geo_Level_2__c,Geo_Level_3__c,Geo_Level_4__c from Territory_Mapping__c where Geo_level_0__c IN : zipCodeList];
        //github comments
        for(Account accnt : accountList){
            zipTerritoryMap.clear();
        	for(Territory_Mapping__c tMap:territoryList)
        	{
           		if(zipTerritoryMap.containsKey(tMap.Geo_level_0__c))
           		{
                	zipTerritoryMap.get(tMap.Geo_level_0__c).add(tMap);
            	}else{
                	zipTerritoryMap.put(tMap.Geo_level_0__c,new List<Territory_Mapping__c>{tMap});
            	}
        	}
            List<Territory_Mapping__c>tMapList=new List<Territory_Mapping__c>();
            if(zipTerritoryMap.get(accZipMap.get(accnt.Id))!=null){
                tMapList=zipTerritoryMap.get(accZipMap.get(accnt.Id));
            }    
            if(!tMapList.isEmpty()){
                for(Territory_Mapping__c tm:tMapList){
                    Account_Territory_Map__c accTerritory=new Account_Territory_Map__c();
                    accTerritory.Account_Id__c=accnt.Id;
                    accTerritory.Territory__c=tm.Territory_Name__c;
                    accTerritory.Geo_level_0__c=tm.Geo_level_0__c;
                    accTerritory.Geo_Level_1__c=tm.Geo_Level_1__c;
                    accTerritory.Geo_Level_2__c=tm.Geo_Level_2__c;
                    accTerritory.Geo_Level_3__c=tm.Geo_Level_3__c;
                    accTerritory.Geo_Level_4__c=tm.Geo_Level_4__c;
                    AccTerritoryList.add(accTerritory);
                    
                }
            }    
            tMapList.clear();
        }
        try{
            if(!AccTerritoryList.isEmpty()){
                insert AccTerritoryList;
            }
        }
        catch(DMLException exe)
        {
            System.debug('Error Occured while creating Account Territory in Account_TerritoryMapHelper class :'+exe.getMessage());
            
            for(Account_Territory_Map__c accTerritory : AccTerritoryList ){
            	
            	accTerritory.addError(system.label.E3_TIS_ErrorMsg);
            }
        }
    }
    
    /**
    * @description :This method is called from the trigger after any Account get updated by it's zip code value. .
      Based on the zip code value for the Account, it updates the related "AccountTerritory" record.
    * 
    * @param List Of Accouts which get Updated and Map of AccountID with Old Accout Record(List<Account>,Map<Id,Account>)
    * 
    * @return Nothing (Void)
    */ 
    public static void AccountTerritoryMapUpdate(List<Account> accountList,Map<Id,Account> oldAccountMap) {
        List<Id> acctIdList= new List<Id>();
        for(Account accnt : accountList) 
        {
            if(accnt.BillingPostalCode != oldAccountMap.get(accnt.id).BillingPostalCode)
            {
                updatedAccount.add(accnt);
                acctIdList.add(accnt.Id);
                If(accnt.BillingPostalCode != null)	
				{
				   if(accnt.BillingPostalCode.contains('-'))
				  {
					Integer index = accnt.BillingPostalCode.indexOf('-');
					String postalCodeSubString = accnt.BillingPostalCode.substring(0,index);
					updatedZipCodeList.add(postalCodeSubString.toUpperCase());
					accZipMap.put(accnt.Id,postalCodeSubString.toUpperCase());
				  }
				  else if(accnt.BillingPostalCode.contains(' '))
					{
						Integer index = accnt.BillingPostalCode.indexOf(' ');
						String postalCodeSubString = accnt.BillingPostalCode.substring(0,index);
						updatedZipCodeList.add(postalCodeSubString.toUpperCase());
						accZipMap.put(accnt.Id,postalCodeSubString.toUpperCase());
					}
				  else{
					updatedZipCodeList.add(accnt.BillingPostalCode.toUpperCase());
					accZipMap.put(accnt.Id,accnt.BillingPostalCode.toUpperCase());
					}
				}
            }   
        }
        updatedTerritoryList = [select id,Geo_level_0__c,Territory_Name__c,Geo_Level_1__c,Geo_Level_2__c,Geo_Level_3__c,Geo_Level_4__c from Territory_Mapping__c where Geo_level_0__c IN : updatedZipCodeList];
        List<Account_Territory_Map__c> accTerriList=[Select id from Account_Territory_Map__c where Account_Id__c IN: acctIdList];
        
        for(Account accnt : accountList){
            zipTerritoryMap.clear();
        	for(Territory_Mapping__c tMap:updatedTerritoryList)
        	{
           		if(zipTerritoryMap.containsKey(tMap.Geo_level_0__c))
           		{
                	zipTerritoryMap.get(tMap.Geo_level_0__c).add(tMap);
            	}else{
                	zipTerritoryMap.put(tMap.Geo_level_0__c,new List<Territory_Mapping__c>{tMap});
            	}
        	}
            List<Territory_Mapping__c>tMapList=new List<Territory_Mapping__c>();
            if(zipTerritoryMap.get(accZipMap.get(accnt.Id))!=null){
                tMapList=zipTerritoryMap.get(accZipMap.get(accnt.Id));
            }    
            if(!tMapList.isEmpty()){
                for(Territory_Mapping__c tm:tMapList){
                    Account_Territory_Map__c accTerritory=new Account_Territory_Map__c();
                    accTerritory.Account_Id__c=accnt.Id;
                    accTerritory.Territory__c=tm.Territory_Name__c;
                    accTerritory.Geo_level_0__c=tm.Geo_level_0__c;
                    accTerritory.Geo_Level_1__c=tm.Geo_Level_1__c;
                    accTerritory.Geo_Level_2__c=tm.Geo_Level_2__c;
                    accTerritory.Geo_Level_3__c=tm.Geo_Level_3__c;
                    accTerritory.Geo_Level_4__c=tm.Geo_Level_4__c;
                    AccTerritoryList.add(accTerritory);
                    
                }
            }    
            tMapList.clear();
        }
        Savepoint spDelIns = Database.setSavepoint();
        try{
            if(!accTerriList.isEmpty())
            {
                delete accTerriList;
            }
        }
        catch(DMLException exe)
        {
        	Database.rollback(spDelIns);
        	System.debug('Error Occured while Deleting Account Territory in Account_TerritoryMapHelper class :'+exe.getMessage());
            for(Account_Territory_Map__c accTerritory : accTerriList )
            {
            	
            	accTerritory.addError(system.label.E3_TIS_ErrorMsg);
            }
        } 
        try{
        	 
            if(!AccTerritoryList.isEmpty())
            {
                insert AccTerritoryList;
            }
        }
        catch(DMLException exe)
        // github commetns 2
	{
            Database.rollback(spDelIns);
            System.debug('Error Occured while updating/Deleting Account Territory in Account_TerritoryMapHelper class :'+exe.getMessage());
            for(Account_Territory_Map__c accTerritory : AccTerritoryList )
            {
            	
            	accTerritory.addError(system.label.E3_TIS_ErrorMsg);
            }
        }
        
    }
    
    //autorabit changes.
}
//End of the class
