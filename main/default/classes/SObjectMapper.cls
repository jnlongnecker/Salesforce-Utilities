public class SObjectMapper {
    private static Map< String, Schema.SObjectType > objectMap;
    static {
        objectMap = Schema.getGlobalDescribe();
    }
    
    public static Map< SObject, List< SObject > > MapToChildren ( List<SObject> parents, List<SObject> children ) {

        // Ensure inputs are valid
        if ( parents.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Parents list cannot be empty' );
        }
        if ( children.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Children list cannot be empty' );
        }

        Schema.DescribeSObjectResult entityFromA = GetSObjectResultFromSObject( parents[0] );
        Schema.DescribeSObjectResult entityFromB = GetSObjectResultFromSObject( children[0] );
        String keyFieldName = GetMappingField( entityFromA, entityFromB );

        // Ensure parents have a relationship to children to map to
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Parents have no relationship to the input children.' );
        }

        // Map parents to child objects
        Map< SObject, List< SObject > > childMap = new Map< SObject, List< SObject > >();
        for ( SObject key : parents ) {
            List< SObject > valueList = new List< SObject >();
            for ( SObject value : children ) {
                if ( key.id == value.get( keyFieldName ) ) {
                    valueList.add( value );
                }
            }
            if ( valueList.size() > 0 )
                childMap.put( key, valueList );
        }

        return childMap;
    }

    public static Map< SObject, List< SObject > > MapToChildren( List< SObject > parents, String childName ) {

        // Ensure inputs are valid
        if ( parents.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Parents list cannot be empty' );
        }
        Schema.SObjectType childType = objectMap.get( childName );
        if ( childType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input child name must be a valid SObject name' );
        }

        Schema.DescribeSObjectResult entityFromA = GetSObjectResultFromSObject( parents[0] );
        Schema.DescribeSObjectResult childResult = childType.getDescribe();
        String keyFieldName = GetMappingField( entityFromA, childResult );

        // Ensure parents have a relationship to the input child name
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Parents have no relationship to input child to map to.' );
        }

        // Retrieve all child objects
        String dynamicQuery = 'SELECT ' + keyFieldName + ' FROM ' + childName;
        List< SObject > childList = Database.query( dynamicQuery );

        // Map parents to child objects
        Map< SObject, List< SObject> > childMap = new Map< SObject, List< SObject > >(); 
        for ( SObject key : parents ) {
            List< SObject > valueList = new List< SObject >();
            for ( SObject value : childList ) {
                if ( key.id == value.get( keyFieldName ) ) {
                    valueList.add( value );
                }
            }
            if ( valueList.size() > 0 )
                childMap.put( key, valueList );
        }

        return childMap;
    } 

    public static Map< SObject, List< SObject > > MapToChildren( String parentName, String childName ) {

        // Ensure inputs are valid
        Schema.SObjectType parentType = objectMap.get( parentName );
        if ( parentType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input parent name must be a valid SObject name' );
        }
        Schema.SObjectType childType = objectMap.get( childName );
        if ( childType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input child name must be a valid SObject name' );
        }

        Schema.DescribeSObjectResult parentResult = parentType.getDescribe();
        Schema.DescribeSObjectResult childResult = childType.getDescribe();
        String keyFieldName = GetMappingField( parentResult, childResult );

        // Ensure parents have a relationship to the input child name
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Parents have no relationship to input child to map to.' );
        }

        // Retrieve all parent and child objects
        String dynamicParentQuery = 'SELECT id FROM ' + parentName;
        List< SObject > parentList = Database.query( dynamicParentQuery );

        String dynamicChildQuery = 'SELECT ' + keyFieldName + ' FROM ' + childName;
        List< SObject > childList = Database.query( dynamicChildQuery );

        // Map objects together
        Map< SObject, List< SObject> > childMap = new Map< SObject, List< SObject > >(); 
        for ( SObject key : parentList ) {
            List< SObject > valueList = new List< SObject >();
            for ( SObject value : childList ) {
                if ( key.id == value.get( keyFieldName ) ) {
                    valueList.add( value );
                }
            }
            if ( valueList.size() > 0 )
                childMap.put( key, valueList );
        }

        return childMap;
    } 

    public static Map< SObject, SObject > MapToParent( List< SObject > children, List< SObject > parents ) {
        // Ensure inputs are valid
        if ( parents.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Parents list cannot be empty' );
        }
        if ( children.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Children list cannot be empty' );
        }

        Schema.DescribeSObjectResult entityFromA = GetSObjectResultFromSObject( parents[0] );
        Schema.DescribeSObjectResult entityFromB = GetSObjectResultFromSObject( children[0] );
        String keyFieldName = GetMappingField( entityFromA, entityFromB );

        // Ensure parents have a relationship to children to map to
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Children have no relationship to the input parents.' );
        }

        // Map parents to child objects
        Map< SObject, SObject > parentMap = new Map< SObject, SObject >();
        for ( SObject key : children ) {
            for ( SObject value : parents ) {
                if ( key.get( keyFieldName ) == value.id ) {
                    parentMap.put( key, value );
                }
            }
        }

        return parentMap;
    }

    public static Map< SObject, SObject > MapToParent( List< SObject > children, String parentName ) {
        // Ensure inputs are valid
        Schema.SObjectType parentType = objectMap.get( parentName );
        if ( parentType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input parent name must be a valid SObject name' );
        }
        if ( children.size() == 0 ) {
            throw new IllegalArgumentException( 'ERROR: Children list cannot be empty' );
        }

        Schema.DescribeSObjectResult parentResult = parentType.getDescribe();
        Schema.DescribeSObjectResult entityFromB = GetSObjectResultFromSObject( children[0] );
        String keyFieldName = GetMappingField( parentResult, entityFromB );

        // Ensure parents have a relationship to children to map to
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Children have no relationship to the input parents.' );
        }

        String dynamicParentQuery = 'SELECT id FROM ' + parentName;
        List< SObject > parentList = Database.query( dynamicParentQuery );

        // Map parents to child objects
        Map< SObject, SObject > parentMap = new Map< SObject, SObject >();
        for ( SObject key : children ) {
            for ( SObject value : parentList ) {
                if ( key.get( keyFieldName ) == value.id ) {
                    parentMap.put( key, value );
                }
            }
        }

        return parentMap;
    }

    public static Map< SObject, SObject > MapToParent( String childName, String parentName ) {
        // Ensure inputs are valid
        Schema.SObjectType parentType = objectMap.get( parentName );
        if ( parentType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input parent name must be a valid SObject name' );
        }
        Schema.SObjectType childType = objectMap.get( childName );
        if ( childType == null ) {
            throw new IllegalArgumentException( 'ERROR: Input child name must be a valid SObject name' );
        }

        Schema.DescribeSObjectResult parentResult = parentType.getDescribe();
        Schema.DescribeSObjectResult childResult = childType.getDescribe();
        String keyFieldName = GetMappingField( parentResult, childResult );

        // Ensure parents have a relationship to children to map to
        if ( keyFieldName == null ) {
            throw new IllegalArgumentException( 'ERROR: Children have no relationship to the input parents.' );
        }

        // Retrieve all parent and child objects
        String dynamicParentQuery = 'SELECT id FROM ' + parentName;
        List< SObject > parentList = Database.query( dynamicParentQuery );

        String dynamicChildQuery = 'SELECT ' + keyFieldName + ' FROM ' + childName;
        List< SObject > childList = Database.query( dynamicChildQuery );

        // Map parents to child objects
        Map< SObject, SObject > parentMap = new Map< SObject, SObject >();
        for ( SObject key : childList ) {
            for ( SObject value : parentList ) {
                if ( key.get( keyFieldName ) == value.id ) {
                    parentMap.put( key, value );
                }
            }
        }

        return parentMap;
    }

    // Retrieves the name of the field in a child object, B, that references the parent object, A
    @testVisible
    private static String GetMappingField ( Schema.DescribeSObjectResult A, Schema.DescribeSObjectResult B ) {
        List< Schema.ChildRelationship > aRelationships = A.getChildRelationships();
        for ( Schema.ChildRelationship relationship : aRelationships ) {
            if ( relationship.getChildSObject().getDescribe().getName() == B.getName() ) {
                return relationship.getField().getDescribe().getName();
            }
        }
        return null;
    }

    // Retrieves the SObjectResult from an input SObject; matching off of ID prefix
    @testVisible
    private static Schema.DescribeSObjectResult GetSObjectResultFromSObject( SObject sObj ) {
        String currPrefix;
        String objPrefix = null;
        if ( sObj != null && sObj.Id != null)
            objPrefix = String.valueOf( sObj.Id ).substring( 0, 3 );

        for( Schema.SObjectType objType : objectMap.values() ) {
            Schema.DescribeSObjectResult result = objType.getDescribe();
            currPrefix = result.getKeyPrefix();

            if ( currPrefix != null && currPrefix == objPrefix ) {
                return result;
            }
        }

        return null;
    }
}
