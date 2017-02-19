'===============================================================================
'
' This script demonstrates the addition of an Access Control Entry (ACE)
' to allow computers to write Trusted Platform Module (TPM) 
' recovery information to Active Directory.
'
' This script creates a SELF ACE on the top-level domain object, and
' assumes that inheritance of ACL's from the top-level domain object to 
' down-level computer objects are enabled.
'
' 
'
' Last Updated: 07/01/2006
' Last Reviewed: 09/19/2009
' Microsoft Corporation
'
' Disclaimer
' 
' The sample scripts are not supported under any Microsoft standard support program
' or service. The sample scripts are provided AS IS without warranty of any kind. 
' Microsoft further disclaims all implied warranties including, without limitation, 
' any implied warranties of merchantability or of fitness for a particular purpose. 
' The entire risk arising out of the use or performance of the sample scripts and 
' documentation remains with you. In no event shall Microsoft, its authors, or 
' anyone else involved in the creation, production, or delivery of the scripts be 
' liable for any damages whatsoever (including, without limitation, damages for loss 
' of business profits, business interruption, loss of business information, or 
' other pecuniary loss) arising out of the use of or inability to use the sample 
' scripts or documentation, even if Microsoft has been advised of the possibility 
' of such damages.
'
' Version 1.0.1 - Tested and re-released for Windows 7 and Windows Server 2008 R2

' 
'===============================================================================

' --------------------------------------------------------------------------------
' Access Control Entry (ACE) constants 
' --------------------------------------------------------------------------------

'- From the ADS_ACETYPE_ENUM enumeration
Const ADS_ACETYPE_ACCESS_ALLOWED_OBJECT      = &H5   'Allows an object to do something

'- From the ADS_ACEFLAG_ENUM enumeration
Const ADS_ACEFLAG_INHERIT_ACE                = &H2   'ACE can be inherited to child objects
Const ADS_ACEFLAG_INHERIT_ONLY_ACE           = &H8   'ACE does NOT apply to target (parent) object

'- From the ADS_RIGHTS_ENUM enumeration
Const ADS_RIGHT_DS_WRITE_PROP                = &H20  'The right to write object properties
Const ADS_RIGHT_DS_CREATE_CHILD              = &H1   'The right to create child objects

'- From the ADS_FLAGTYPE_ENUM enumeration
Const ADS_FLAG_OBJECT_TYPE_PRESENT           = &H1   'Target object type is present in the ACE 
Const ADS_FLAG_INHERITED_OBJECT_TYPE_PRESENT = &H2   'Target inherited object type is present in the ACE 

' --------------------------------------------------------------------------------
' TPM and FVE schema object GUID's 
' --------------------------------------------------------------------------------

'- ms-TPM-OwnerInformation attribute
SCHEMA_GUID_MS_TPM_OWNERINFORMATION = "{AA4E1A6D-550D-4E05-8C35-4AFCB917A9FE}"

'- ms-FVE-RecoveryInformation object
SCHEMA_GUID_MS_FVE_RECOVERYINFORMATION = "{EA715D30-8F53-40D0-BD1E-6109186D782C}"

'- Computer object
SCHEMA_GUID_COMPUTER = "{BF967A86-0DE6-11D0-A285-00AA003049E2}"

'Reference: "Platform SDK: Active Directory Schema"




' --------------------------------------------------------------------------------
' Set up the ACE to allow write of TPM owner information
' --------------------------------------------------------------------------------

Set objAce1 = createObject("AccessControlEntry")

objAce1.AceFlags = ADS_ACEFLAG_INHERIT_ACE + ADS_ACEFLAG_INHERIT_ONLY_ACE
objAce1.AceType = ADS_ACETYPE_ACCESS_ALLOWED_OBJECT
objAce1.Flags = ADS_FLAG_OBJECT_TYPE_PRESENT + ADS_FLAG_INHERITED_OBJECT_TYPE_PRESENT

objAce1.Trustee = "SELF"
objAce1.AccessMask = ADS_RIGHT_DS_WRITE_PROP 
objAce1.ObjectType = SCHEMA_GUID_MS_TPM_OWNERINFORMATION
objAce1.InheritedObjectType = SCHEMA_GUID_COMPUTER



' --------------------------------------------------------------------------------
' NOTE: BY default, the "SELF" computer account can create 
' BitLocker recovery information objects and write BitLocker recovery properties
'
' No additional ACE's are needed.
' --------------------------------------------------------------------------------


' --------------------------------------------------------------------------------
' Connect to Discretional ACL (DACL) for domain object
' --------------------------------------------------------------------------------

Set objRootLDAP = GetObject("LDAP://rootDSE")
strPathToDomain = "LDAP://" & objRootLDAP.Get("defaultNamingContext") ' e.g. string dc=fabrikam,dc=com

Set objDomain = GetObject(strPathToDomain)

WScript.Echo "Accessing object: " + objDomain.Get("distinguishedName")

Set objDescriptor = objDomain.Get("ntSecurityDescriptor")
Set objDacl = objDescriptor.DiscretionaryAcl

 
' --------------------------------------------------------------------------------
' Add the ACEs to the Discretionary ACL (DACL) and set the DACL
' --------------------------------------------------------------------------------

objDacl.AddAce objAce1

objDescriptor.DiscretionaryAcl = objDacl
objDomain.Put "ntSecurityDescriptor", Array(objDescriptor)
objDomain.SetInfo

WScript.Echo "SUCCESS!"
