

Write-Output "##################################################" 
Write-Output "###                                            ###" 
Write-Output "### InPop Tool - A Population / Connector tool ###" 
Write-Output "###                                            ###" 
Write-Output "##################################################" 


# Method to connect to Oracle
function Get-OLEDBData ($connectstring, $sql) {            
   $OLEDBConn = New-Object System.Data.OleDb.OleDbConnection($connectstring)            
   $OLEDBConn.open()            
   $readcmd = New-Object system.Data.OleDb.OleDbCommand($sql,$OLEDBConn)            
   $readcmd.CommandTimeout = '300'            
   $da = New-Object system.Data.OleDb.OleDbDataAdapter($readcmd)            
   $dt = New-Object system.Data.datatable            
   [void]$da.fill($dt)           
   $OLEDBConn.close()            
   return $dt            
}


# Actual beginning of custom code !


#=======>Environment Definition #

	Write-Host "================ Environment ================"
    
    Write-Host "1: Press '1' for Production"
    Write-Host "2: Press '2' for Staging"

$environment = Read-Host "Please make a selection"

switch ($environment)
{
    '1'{
			$environment = 'PROD'
			$OKCconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			Write-Host "We're on Production !"
		}
	
	'2'{
			$environment = 'STAGING'
			$OKCconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			Write-Host "We're on Staging !"
		}
	default{
			Write-Host "That's not 1 or 2.  Exiting !!!"
			Pause
			Exit
	}		

}

#=======>Connector Definition #

$OK_ConnectorID = Read-Host 'On which connector are we working?'

#Check if connector exist and is active
$qry_C_ACTIVE= "select count(*) from <<TABLE>> where cis_id='$OK_ConnectorID' and inactive='0'"
$result = Get-OLEDBData $OKCconnString $qry_C_ACTIVE
if ( $result.Item(0) -eq "0")
{
		Write-Output "This connector is inactive or doesn't exist. End of the program."
		Pause
		Exit
}
else
{
		Write-Output "Connector is active."
}

Write-Output " 											" 
Write-Output "We will analyse connector $OK_ConnectorID content !" 
Write-Output " 											" 

#ConnectorName
$qry_NAME= "select name from <<TABLE>> where cis_id='$OK_ConnectorID'"		
$C_Name = Get-OLEDBData $OKCconnString $qry_NAME
Write-Output "NAME: 		$($C_Name.Item(0))							" 
#Environment reminder
Write-Output "PLATFORM:	$environment								" 
#Codebase
$qry_CODEBASE= "select LISTAGG(a.cg_code,',') as Codebase from <<TABLE>> p, <<TABLE>> map, <<TABLE>> a where p.cis_id='$OK_ConnectorID' and p.cp_id=map.cp_id and a.map_id=map.map_id and map.name='country2codebase' order by 1 asc"		
$C_Codebase = Get-OLEDBData $OKCconnString $qry_CODEBASE
Write-Output "CODEBASE(S):	$($C_Codebase.Item(0)) 											"
#Countries
$qry_COUNTRIES= "select LISTAGG(a.client_code,',') as Codebase from <<TABLE>> p, <<TABLE>> map, <<TABLE>> a where p.cis_id='$OK_ConnectorID' and p.cp_id=map.cp_id and a.map_id=map.map_id and map.name='country2codebase' order by 1 asc"		
$C_Countries = Get-OLEDBData $OKCconnString $qry_COUNTRIES
Write-Output "COUNTR(Y/IES):	$($C_Countries.Item(0))											" 

$OK_ID = Read-Host 'Which key are we looking after in this connector ? '

		# We now validate it is a valid <> key format record.
		# Should be of format <Codebase><Letter><8chars> or <Codebase><Letter><10chars>
		
	if ($OK_ID -notmatch "^W[A-Z]{3}[0-9]{8}$|W[A-Z]{3}[0-9]{10}$")
		{
			Write-Output " 											" 
			Write-Output "Incorrect key format ! -- !!! KO !!! --"
			Write-Output " Should be of format <Codebase><Letter><8chars> or <Codebase><Letter><10chars>"
			Write-Output " 											" 
			pause
			exit
		}
	else
		{
			Write-Output " 											" 
			Write-Output "<> key format is valid ! -- OK ! --"
			Write-Output " 											" 
		}


### To which codebase belongs this ID ? ###

# 1-We first extract codebase from the Key...
$Codebase = $OK_ID.Substring(0,3)
Write-Output "Codebase of this key is $Codebase"

# 2-...And the relative DB

switch ($Codebase)
{
	WFR{
		Write-Output "This is RAR_FRANCE 	"
		$Refer_Area_EID = "RAR_FRANCE"
			if ($environment = "PROD")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}
			elseif ($environment = "STAGING")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}	
		}
	WEG{
		Write-Output "This is RAR_EGYPT 	"
		$Refer_Area_EID = "RAR_EGYPT"
			if ($environment = "PROD")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}
			elseif ($environment = "STAGING")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}	
		}
	WIT{
		Write-Output "This is RAR_ITALY 	"
		$Refer_Area_EID = "RAR_ITALY"
			if ($environment = "PROD")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(<<>>)));Provider=OraOLEDB.Oracle"
			}
			elseif ($environment = "STAGING")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}	
		}
	WMX{
		Write-Output "This is RAR_MEXICO 	"
		$Refer_Area_EID = "RAR_MEXICO"
			if ($environment = "PROD")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}
			elseif ($environment = "STAGING")
			{
				$OKEconnString = "Password=<<>>;User ID=<<>>;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<<>>)(PORT=1521))(CONNECT_DATA=(SID=<<>>)));Provider=OraOLEDB.Oracle"
			}	
		}			
	
}


# 3-...And finally the type of key

	if ($OK_ID -match "W[A-Z]{3}[0-9]{10}$")
		{
			Write-Output " 											" 
			Write-Output "$OK_ID - This is an Activity key..." 
			Write-Output " 											" 
			
		$KeyType = "ACTIVITY"	
			
		}
	elseif ($OK_ID -match "W[A-Z]{2}[A,C,D,I,K,M,O,P,R,S,T,U,V,W,Z]{1}[0-9]{8}$")
		{
			Write-Output " 											" 
			Write-Output "$OK_ID - This is an Individual key..." 
			Write-Output " 											" 
			
		$KeyType = "INDIVIDUAL"	
			
		}
	else
		{
			Write-Output " 											" 
			Write-Output "$OK_ID - This is a Workplace key..." 
			Write-Output " 											" 
			
		$KeyType = "WORKPLACE"	
		
		}
		
### Let's check if key is part of the Client population ! ###

switch ($KeyType)
{
	ACTIVITY{
		
		$qry= "select count(a.act_id) inPopulation from <<TABLE>> a, <<TABLE>> ex, <<TABLE>> l, <<TABLE>> c where a.client_id = '$OK_ConnectorID' and a.refer_area_eid = '$Refer_Area_EID' and a.act_id = ex.act_id and ex.ext_key_type_cod = c.cod_id and c.lis_id = l.lis_id and c.cod_eid = 'A0' and l.lis_eid = 'REX' and ex.act_eid='$OK_ID'"
		
	}
	INDIVIDUAL{

		$qry= "select count(i.ind_id) inPopulation from <<TABLE>> i, <<TABLE>> ex, <<TABLE>> l, <<TABLE>> c where i.client_id = '$OK_ConnectorID' and i.refer_area_eid = '$Refer_Area_EID' and i.ind_id = ex.ind_id and ex.ext_key_type_cod = c.cod_id and c.lis_id = l.lis_id and c.cod_eid = 'I0' and l.lis_eid = 'REX' and ex.ind_eid='$OK_ID'"		
	}
	WORKPLACE{

		$qry= "select count(w.wkp_id) inPopulation from <<TABLE>> w, <<TABLE>> ex, <<TABLE>> l, <<TABLE>> c where w.client_id = '$OK_ConnectorID' and w.refer_area_eid = '$Refer_Area_EID' and w.wkp_id = ex.wkp_id and ex.ext_key_type_cod = c.cod_id and c.lis_id = l.lis_id and c.cod_eid = 'E0' and l.lis_eid = 'REX' and ex.wkp_eid='$OK_ID'"		
		
	}
}




# Question DB: Is this record part of the actual Connector Population ?
$result = Get-OLEDBData $OKEconnString $qry

if ( $result.Item(0) -eq "1")
{
		Write-Output "This record is actually in Population. Check delivery layer or integration issue on client side."
		Pause
		Exit
}
else
{
		Write-Output "Key is not in population. Research will continue !"
}


# Question DB: Is this record private ?
### Let's check if key is private ! ###

switch ($KeyType)
{
	ACTIVITY{
		
		$qry= "select count(p.act_id) isPrivate from <<TABLE>> p, <<TABLE>> a, <<TABLE>> s where a.act_id = p.act_id and a.refer_area_eid = '$Refer_Area_EID' and s.act_id = a.act_id and s.act_eid = '$OK_ID'"
		
	}
	INDIVIDUAL{

		$qry= "select count(p.act_id) isPrivate from <<TABLE>> p, <<TABLE>> i, <<TABLE>> s, ok_activity a where i.refer_area_eid= '$Refer_Area_EID' and s.ind_id = i.ind_id and s.ind_eid='$OK_ID' and a.ind_id = i.ind_id and p.act_id = a.act_id"		
	}
	WORKPLACE{

		$qry= "select count(p.wkp_id) isPrivate from <<TABLE>> p, <<TABLE>> w, <<TABLE>> s where w.wkp_id = p.wkp_id and w.refer_area_eid = '$Refer_Area_EID' and s.wkp_id = w.wkp_id and s.wkp_eid='$OK_ID'"		
		
	}
}

$result = Get-OLEDBData $OKEconnString $qry
if ( $result.Item(0) -eq "0")
{		
		Write-Output " ################################### "
		Write-Output "Key is public ! Nothing to do with Private CODE related aspect"
		Write-Output " ################################### "
		Write-Output ""
}
else
{
		Write-Output " ################################### "
		Write-Output ">>>>>Some occurences of the Key are private, check Private CODE related aspects !"
		Write-Output " ################################### "
		Write-Output ""
}


# Question DB: Is this record force deleted ?
### Let's check if key (or relative) is force deleted ! ###

switch ($KeyType)
{
	ACTIVITY{
		
		$qry= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='A' and s.key='$OK_ID'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, pr_connection_point p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='A' and i.key='$OK_ID'and i.codbase='$Codebase') order by 2 desc"
			
	}
	INDIVIDUAL{

		$qry= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='I' and s.key='$OK_ID'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, pr_connection_point p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='I' and i.key='$OK_ID'and i.codbase='$Codebase') order by 2 desc"
	}
	WORKPLACE{

		$qry= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='E' and s.key='$OK_ID'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, pr_connection_point p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='E' and i.key='$OK_ID'and i.codbase='$Codebase') order by 2 desc"
		
	}
}

$result = Get-OLEDBData $OKCconnString $qry

if ( $result -eq $null)
{
		Write-Output " ################################### "
		Write-Output "No direct key forcing for this record $OK_ID.A relative key force deleted ?  We will check that next"
		Write-Output " ################################### "
}
elseif ($result[0][0] -eq "DEL")
{
		Write-Output " ################################### "
		Write-Output "Some key forcing occured. Last occurence is a key force deletion. >>>Key force insert is needed."
		Write-Output " ################################### "
		Pause
		Exit
}
elseif ($result[0][0] -eq "INS")
{
		Write-Output " ################################### "
		Write-Output "Some key forcing occured. Last occurence is a key force insertion.Quite possible that a relative key is force deleted also !  We will check that next"
		Write-Output " ################################### "
		
}


# Question DB: Is this record as a relative key force deleted ?
### Let's check if a relative key is force deleted ! ###

# Method to check Wkp relations
function inHerit ($wkp_to_check)
{
		$key_sql = "select exw.wkp_eid from <<TABLE>> w2w, <<TABLE>> lc, <<TABLE>> exw where w2w.wkp_son_id in (select wkp_id from <<TABLE>> where wkp_eid='$wkp_to_check') and w2w.link_cod=lc.cod_id and exw.wkp_id=w2w.wkp_father_id and lc.cod_eid='HIE' and exw.ext_key_type_cod in (select cod_id from <<TABLE>> where cod_eid='E0')"
		$resultW = Get-OLEDBData $OKEconnString $key_sql
		if ( $resultW -eq $null)
		{
			Write-Output "The said workplace $wkp_to_check doesn't have a managing workplace."
			$script:wkp_to_check = $null
			
		}
		else {
			$OKC_Check= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='E' and s.key='$($resultW.Item(0))'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, <<TABLE>> p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='E' and i.key='$($resultW.Item(0))'and i.codbase='$Codebase') order by 2 desc"
			$result = Get-OLEDBData $OKCconnString $OKC_Check
				if ( $result -eq $null)
				{
					Write-Output "$wkp_to_check has for parent $($resultW.Item(0))"
					Write-Output "$($resultW.Item(0)) wasn't forced."
					Write-Output "We will check if $($resultW.Item(0)) has a parent."
					Write-Output ""
					$script:wkp_to_check = $resultW.Item(0)
				}
				elseif ($result[0][0] -eq "DEL")
				{
					Write-Output "Some key forcing occured for $($resultW.Item(0)). Last occurence is a key force deletion. >>>Key force insert is needed for $($resultW.Item(0))"
					Pause
					Exit
				}
				elseif ($result[0][0] -eq "INS")
				{
					Write-Output "Some key forcing occured on $($resultW.Item(0)). Last occurence is a key force insertion."
		
				}
			
		}
}


#First we identify the relative keys
switch ($KeyType)
{
	ACTIVITY{
		
		# The logic consist here in checking if the individual was key force deleted. If not, we check all related workplaces
		
		$IndividualIdentification = "select exi.ind_eid from <<TABLE>> exa,<<TABLE>> exi, <<TABLE>> i, <<TABLE>> a where exa.act_eid='$OK_ID' and exa.act_id =a.act_id and a.ind_id = i.ind_id and exi.ind_id = i.ind_id and exi.ext_key_type_cod in (select cod_id from <<TABLE>> where cod_eid='I0')"
		$getIND = Get-OLEDBData $OKEconnString $IndividualIdentification
		Write-Output "$($getIND.Item(0)) is the Individual linked to $OK_ID."
		$OKC_IND_Checkup = "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='I' and s.key='$($getIND.Item(0))'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, <<TABLE>> p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='I' and i.key='$($getIND.Item(0))'and i.codbase='$Codebase') order by 2 desc"
		
		if ( $result -eq $null)
		{
			Write-Output "No direct key forcing for this record $($getIND.Item(0)). We will check workplace(s) next."
		}
		elseif ($result[0][0] -eq "DEL")
		{
			Write-Output "Some key forcing occured for $($getIND.Item(0)). Last occurence is a key force deletion. >>>Key force insert is needed."
			Pause
			Exit
		}
		elseif ($result[0][0] -eq "INS")
		{
			Write-Output "Some key forcing occured on $($getIND.Item(0)). Last occurence is a key force insertion.We still need to check Workplaces"
		
		}
		
		$WorkplaceIdentification = "select exw.wkp_eid from <<TABLE>> exa,<<TABLE>> exw, <<TABLE>> w, <<TABLE>> a where exa.act_eid='$OK_ID' and exa.act_id =a.act_id and a.wkp_id = w.wkp_id and exw.wkp_id = w.wkp_id and exw.ext_key_type_cod in (select cod_id from ok_list_code where cod_eid='E0')"	
		$getWKP = Get-OLEDBData $OKEconnString $WorkplaceIdentification
		Write-Output "Activity is directly linked to $($getWKP.Item(0))"
		$wkp_to_check = $getWKP.Item(0)
		inHerit $wkp_to_check
		while ($wkp_to_check -ne $null)
		{
			inHerit $wkp_to_check
		}
		Pause
		
	}
	INDIVIDUAL{
		# The logic consist here in checking if all activities of the individual are force deleted. If not, the same with all related workplaces.
		$ActivitiesIdentification= "select act.act_eid from <<TABLE>> a, <<TABLE>> ex, <<TABLE>> act where a.ind_id = ex.ind_id and act.act_id = a.act_id and ex.ind_eid='$OK_ID'"
		$getACT = Get-OLEDBData $OKEconnString $ActivitiesIdentification
		$getACT | ForEach-Object {
			
			$qry= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='A' and s.key='$($_.act_eid)'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, <<TABLE>> p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='A' and i.key='$($_.act_eid)'and i.codbase='$Codebase') order by 2 desc"
			$result = Get-OLEDBData $OKCconnString $qry

			if ( $result -eq $null)
				{
					Write-Output "$($_.act_eid) <==== No direct key forcing for this record.  "
				}
			elseif ($result[0][0] -eq "DEL")
				{
					Write-Output "$($_.act_eid) <====  Some key forcing deletion currently applies."
				Pause
				Exit
				}
			elseif ($result[0][0] -eq "INS")
				{
					Write-Output "$($_.act_eid) <=== Some key forcing applies."
		
				}
			}
			Write-Output ""
			Write-Output "If at least one Activity is either forced or without key forcing"
			Write-Output "Individual should be delivered logicially. Unless all worplaces are force deleted or country restriction applies."
			Write-Output ""
			Write-Output ""
			Pause
			Write-Output ""
			Write-Output "We will check now relative workplaces"
			Write-Output ""
			$WorkplaceIdentification= "select wkp.wkp_eid from <<TABLE>> a, <<TABLE>> ex, <<TABLE>> wkp where a.ind_id = ex.ind_id and wkp.wkp_id = a.wkp_id and ex.ind_eid='$OK_ID' and wkp.ext_key_type_cod in (select cod_id from <<TABLE>> where cod_eid='E0')"
			$getWKP = Get-OLEDBData $OKEconnString $WorkplaceIdentification
			$getWKP | ForEach-Object {
				$qry= "select type,processed_date from (select 'DEL' as type,s.processed_date from <<TABLE>> s, <<TABLE>> p where p.cp_id = s.cp_id and p.cis_id='$OK_ConnectorID' and s.entity_type='E' and s.key='$($_.wkp_eid)'and s.codbase='$Codebase' UNION ALL select 'INS' as type,i.processed_date from <<TABLE>> i, <<TABLE>> p where p.cp_id = i.cp_id and p.cis_id='$OK_ConnectorID' and i.entity_type='E' and i.key='$($_.wkp_eid)'and i.codbase='$Codebase') order by 2 desc"
				
				$result = Get-OLEDBData $OKCconnString $qry

					if ( $result -eq $null)
					{
						Write-Output "$($_.wkp_eid) <==== No direct key forcing for this record.  "
					}
					elseif ($result[0][0] -eq "DEL")
					{
						Write-Output "$($_.wkp_eid) <====  Some key forcing deletion currently applies."
						Pause
						Exit
					}
					elseif ($result[0][0] -eq "INS")
					{
						Write-Output "$($_.wkp_eid) <=== Some key forcing applies."
		
					}
					Write-Output " ################################### "
					Write-Output "--> Checking up $($_.wkp_eid) hierarchy  <--"
					Write-Output " ################################### "
					$wkp_to_check = $_.wkp_eid
					inHerit $wkp_to_check
						while ($wkp_to_check -ne $null)
							{
								inHerit $wkp_to_check
							}
					Write-Output " ################################### "
					Write-Output "--> End of Checking up $($_.wkp_eid) hierarchy  <--"
					Write-Output " ################################### "
					Write-Output ""
				}
			Write-Output "If at least one Workplace is either forced or without key forcing"
			Write-Output "Individual should be delivered logicially. Country restriction may applies, or basic segmentation should be reviewed."	

		Pause
	}
	WORKPLACE{
		# The logic consist here in checking if the related workplaces (hierarchy) above, have been force deleted
		$wkp_to_check = $OK_ID
		inHerit $wkp_to_check
		while ($wkp_to_check -ne $null)
		{
			inHerit $wkp_to_check
		}
		Pause
		
	}
}