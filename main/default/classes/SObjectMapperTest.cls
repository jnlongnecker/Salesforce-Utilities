@isTest
public class SObjectMapperTest {
    
    @testSetup
    private static void Setup() {
        List< Account > accList = new List< Account >();
        for ( Integer i = 0; i < 200; i++ ) {
            accList.add( new Account( name = 'TestAcc' + i ) );
        }
        Insert accList;

        List< Contact > contactList = new List< Contact >();
        for ( Account acc : accList ) {
            Integer numContacts = Integer.valueof( Math.random() * 2 ) + 1;
            for ( Integer i = 0; i < numContacts; i++ ) {
                contactList.add( new Contact( AccountId = acc.id, lastName = acc.name + '-' + i ) );
            }
        }
        Insert contactList;

        List< Campaign > campaignList = new List< Campaign >();
        for ( Integer i = 0; i < 50; i++ ) {
            campaignList.add( new Campaign( name = 'Test Campaign ' + i ) );
        }
        Insert campaignList;
    }

    @isTest
    private static void TP_GetSObjectResultFromSObject() {
        Schema.DescribeSObjectResult accountResult = Schema.getGlobalDescribe().get( 'Account' ).getDescribe();
        Account anAccount = [SELECT id FROM Account LIMIT 1];
        Schema.DescribeSObjectResult actualResult = SObjectMapper.GetSObjectResultFromSObject( anAccount );

        System.assertEquals( accountResult, actualResult );
    }

    @isTest
    private static void TN_GetSObjectResultFromSObject() {
        Schema.DescribeSObjectResult actualResult = SObjectMapper.GetSObjectResultFromSObject( null );
        System.assertEquals( null, actualResult );
    }

    @isTest
    private static void TP_GetMappingField() {
        Schema.DescribeSObjectResult accResult = Schema.getGlobalDescribe().get( 'Account' ).getDescribe();
        Schema.DescribeSObjectResult conResult = Schema.getGlobalDescribe().get( 'Contact' ).getDescribe();
        String actualName = SObjectMapper.GetMappingField( accResult, conResult );

        System.assertEquals( 'AccountId', actualName );
    }

    @isTest
    private static void TN_GetMappingField() {
        Schema.DescribeSObjectResult accResult = Schema.getGlobalDescribe().get( 'Account' ).getDescribe();
        Schema.DescribeSObjectResult conResult = Schema.getGlobalDescribe().get( 'Contact' ).getDescribe();
        Schema.DescribeSObjectResult campaignResult = Schema.getGlobalDescribe().get( 'Campaign' ).getDescribe();

        String actualName = SObjectMapper.GetMappingField( conResult, accResult );
        System.assertEquals( null, actualName );

        actualName = SObjectMapper.GetMappingField( accResult, campaignResult );
        System.assertEquals( null, actualName );
    }

    @isTest
    private static void TP_MapToChildren() {
        List< Account > accList = [SELECT id FROM Account];
        List< Contact > conList = [SELECT AccountId FROM Contact];

        Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, conList );
        for ( SObject key : objMap.keySet() ) {
            for ( SObject value : objMap.get( key ) ) {
                Contact currContact = (Contact) value;
                System.assertEquals( key.id, currContact.AccountId );
            }
        }

        objMap = SObjectMapper.MapToChildren( accList, 'Contact' );
        for ( SObject key : objMap.keySet() ) {
            for ( SObject value : objMap.get( key ) ) {
                Contact currContact = (Contact) value;
                System.assertEquals( key.id, currContact.AccountId );
            }
        }

        objMap = SObjectMapper.MapToChildren( 'Account', 'Contact' );
        for ( SObject key : objMap.keySet() ) {
            for ( SObject value : objMap.get( key ) ) {
                Contact currContact = (Contact) value;
                System.assertEquals( key.id, currContact.AccountId );
            }
        }
    }

    @isTest
    public static void TN_MapToChildren1() {
        List< SObject > accList = new List< SObject >();
        List< SObject > campaignList = new List< SObject >();
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents list cannot be empty', e.getMessage() );
        }

        accList = [SELECT id FROM Account];
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children list cannot be empty', e.getMessage() );
        }

        campaignList = [SELECT id FROM Campaign];
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents have no relationship to the input children.', e.getMessage() );
        }
    }

    @isTest
    public static void TN_MapToChildren2() {
        List< SObject > accList = new List< SObject >();
        String childName = 'Nothing';
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents list cannot be empty', e.getMessage() );
        }

        accList = [SELECT id FROM Account];
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input child name must be a valid SObject name', e.getMessage() );
        }

        childName = 'Campaign';
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( accList, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents have no relationship to input child to map to.', e.getMessage() );
        }
    }

    @isTest
    public static void TN_MapToChildren3() {
        String parentName = 'Nothing';
        String childName = 'Nothing';
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( parentName, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input parent name must be a valid SObject name', e.getMessage() );
        }

        parentName = 'Account';
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( parentName, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input child name must be a valid SObject name', e.getMessage() );
        }

        childName = 'Campaign';
        try {
            Map< SObject, List< SObject > > objMap = SObjectMapper.MapToChildren( parentName, childName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents have no relationship to input child to map to.', e.getMessage() );
        }
    }

    @isTest
    public static void TP_MapToParent() {
        List< Account > accList = [SELECT id FROM Account];
        List< Contact > conList = [SELECT AccountId FROM Contact];

        Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, accList );
        for ( SObject key : objMap.keySet() ) {
            Contact keyContact = (Contact)key;
            System.assertEquals( keyContact.AccountId, objMap.get( key ).id );
        }

        objMap = SObjectMapper.MapToParent( conList, 'Account' );
        for ( SObject key : objMap.keySet() ) {
            Contact keyContact = (Contact)key;
            System.assertEquals( keyContact.AccountId, objMap.get( key ).id );
        }

        objMap = SObjectMapper.MapToParent( 'Contact', 'Account' );
        for ( SObject key : objMap.keySet() ) {
            Contact keyContact = (Contact)key;
            System.assertEquals( keyContact.AccountId, objMap.get( key ).id );
        }
    }

    @isTest
    public static void TN_MapToParent1() {
        List< SObject > conList = new List< SObject >();
        List< SObject > campaignList = new List< SObject >();
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Parents list cannot be empty', e.getMessage() );
        }

        campaignList = [SELECT id FROM Campaign];
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children list cannot be empty', e.getMessage() );
        }

        conList = [SELECT id FROM Contact];
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, campaignList );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children have no relationship to the input parents.', e.getMessage() );
        }
    }

    @isTest
    public static void TN_MapToParent2() {
        List< SObject > conList = new List< SObject >();
        String parentName = 'Nothing';
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input parent name must be a valid SObject name', e.getMessage() );
        }

        parentName = 'Campaign';
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children list cannot be empty', e.getMessage() );
        }

        conList = [SELECT id FROM Contact];
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( conList, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children have no relationship to the input parents.', e.getMessage() );
        }
    }

    @isTest
    public static void TN_MapToParent3() {
        String childName = 'Nothing';
        String parentName = 'Nothing';
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( childName, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input parent name must be a valid SObject name', e.getMessage() );
        }

        parentName = 'Campaign';
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( childName, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Input child name must be a valid SObject name', e.getMessage() );
        }

        childName = 'Contact';
        try {
            Map< SObject, SObject > objMap = SObjectMapper.MapToParent( childName, parentName );
            System.assert( false );
        }
        catch ( IllegalArgumentException e ) {
            System.assertEquals( 'ERROR: Children have no relationship to the input parents.', e.getMessage() );
        }
    }
}
